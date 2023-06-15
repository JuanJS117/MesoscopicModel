"""

    MESOSCOPIC SIMULATOR - Brain Metastases version

    monitor.jl

    This module contains all functions related to system monitoring during time. Key variables,
    such as tumor volume and cell number, are tracked throughout simulation; however, as computations
    are expensive, they are only updated each N iterations.


    Designed and written by:
           Juan Jimenez Sanchez - Predoctoral researcher -  Juan.JSanchez@uclm.es

    Based on the original work of:
           Juan Jimenez Sanchez
           Alvaro Martinez Rubio - Predoctoral researcher -  alvaro.martinezrubio@uca.es
           Anton Popov - Predoctoral researcher - popovanton567@gmail.com

    Principal investigator:
           Victor M. Perez Garcia - Full Professor -   Victor.PerezGarcia@uclm.es

    For any questions on scientific topics, please contact Beatriz Ocaña Tienda: Beatriz.Ocana@uclm.es,
    the first author of the paper where this code has been used.

    For any questions related to model citation or collaborations, please contact Victor.

    For any inquiries related to model usage, performance or improvements, please address
    them to Juan.

"""


include("constants.jl")

mutable struct Monitor

    ################################################################################
    # MONITORED VARIABLES
    ################################################################################

    # All those arrays store corresponding variable value at succesive evaluation time steps

    totpop::Array{Float64, 1}       # Total cell number of whole tumor
    totnec::Array{Float64, 1}       # Total necrotic cells of whole tumor
    vol::Array{Float64, 1}          # Tumor volume (only voxels exceeding threshold number of cells)
    Rvol::Array{Float64, 1}         # Tumor volume (all voxels containing at least 1 cell)
    totnew::Array{Float64, 1}       # Total cell activity of whole tumor (only voxels exceeding threshold number of cells)
    Rtotnew::Array{Float64, 1}      # Total cell activity of whole tumor (all voxels containing at least 1 cell)
    Shannon::Array{Float64, 1}      # Shannon index
    Simpson::Array{Float64, 1}      # Simpson index
    pops::Array{Float64, 2}         # Total cell number of each clonal population
    popt::Array{Int64, 3}           # Total cell number per voxel
    Vol2::Array{Float64, 1}         # Alternative computation of tumor volume (based on occupied voxels' cartesian coordinates)


    ################################################################################
    # TIME CONTROL VARIABLES
    ################################################################################

    elapsed::Float64                # Time elapsed since 1st iteration
    evalstep::Int64                 # Current evaluation step. It is increased by 1 after each system evaluation
    t::Int64                        # Current iteration. It is increased by 1 after each time step taken


    ################################################################################
    # INITIALIZATION
    ################################################################################

    function Monitor(c::Constants)

        # Migrate key variables from 'constants' module to easily use them
        Neval = c.Neval
        N = c.N

        # Notice that Neval is fixed, but simulations may vary in extension. Due to this, arrays of monitored variables
        # may have empty slots at the end. Neval is always large enough to let this happen, instead of running out of
        # slots to store variables' info in arrays

        totpop = zeros(Neval)
        totpop[1] = c.P0                    # Initial cell number is assigned to 1st slot in 1st evaluation step
        totnec = zeros(Neval)
        vol = zeros(Neval)
        Rvol = zeros(Neval)
        Rvol[1] = 1                         # As central voxel contains initial population at 1st time step, Rvol will be equal to 1 in 1st evaluation step
        totnew = zeros(Neval)
        Rtotnew = zeros(Neval)
        Shannon = zeros(Neval)
        Simpson = zeros(Neval)
        Simpson[1] = 1                      # Simpson index for zero diversity is equal to 1, so 1st slot of this array will be equal to 1 in 1st evaluation step
        pops = zeros(2^c.alt, Neval)
        pops[1, 1] = c.P0                   # At 1st evaluation step, only clonal population with no alterations will contain cells
        popt = Array{Int64}(undef, N, N, N)
        popt[Int64(N / 2), Int64(N / 2), Int64(N / 2)] = c.P0   # At 1st evaluation step, only central voxel will contain cells
        Vol2 = zeros(Neval)
        elapsed = 0
        evalstep = 1
        t = 0

        new(totpop, totnec, vol, Rvol, totnew, Rtotnew, Shannon, Simpson, pops,
            popt, Vol2, elapsed, evalstep, t)
    end
end


################################################################################
# FUNCTIONS
################################################################################

function update_monitor_populations!(m::Monitor, c::Constants,
        G::Array{Float64, 4}, Nec::Array{Float64, 3}, Act::Array{Float64, 3},
        i::Int64, j::Int64, k::Int64)

    """
        This function updates all arrays storing monitored variables related to cells
    """

    m.totpop[m.evalstep + 1] = m.totpop[m.evalstep + 1] + sum(G[i, j, k, :])        # Sum all cell numbers from each voxel to get total cell number
    m.totnec[m.evalstep + 1] = m.totnec[m.evalstep + 1] + sum(Nec[i, j, k])         # Sum all necrotic cells from each voxel to get total necrotic cells
    m.Rtotnew[m.evalstep + 1] = m.Rtotnew[m.evalstep + 1] + sum(Act[i, j, k])       # Sum all newborn cells from each voxel to get total tumor activity 'Rtotnew'
    m.Rvol[m.evalstep + 1] = m.Rvol[m.evalstep + 1] + 1                             # Each time a voxel with cells is evaluated, add 1 to total tumor volume 'Rvol'

    for e = 1 : 2^c.alt
        m.pops[e, m.evalstep + 1] = m.pops[e, m.evalstep + 1] + G[i, j, k, e]       # Sum all cells from each clonal population to get total cell number per clonal pop
    end

    if sum(G[i, j, k, :])+Nec[i,j,k] > c.threshold                                  # This condition holds for variables considering only voxels that exceed a threshold of cells
        m.totnew[m.evalstep + 1] = m.totnew[m.evalstep + 1] + sum(Act[i, j, k])     # Sum all newborn cells from selected voxels to get total tumor activity 'totnew'
        m.vol[m.evalstep + 1] = m.vol[m.evalstep + 1] + 1                           # Each time a voxel with more than threshold number of cells is evaluated, add 1 to total tumor volume 'vol'
    end
end


function update_monitor_stats!(m::Monitor, c::Constants)

    """
        This function updates all arrays storing monitored variables related to heterogeneity.
        It is performed in a different function, as it requires cell-related monitored variables
        to be already calculated
    """

    # Clear slots to be calculated in current evaluation step
    m.Shannon[m.evalstep + 1] = 0
    m.Simpson[m.evalstep + 1] = 0

    # Get tumor volume 'Vol2' by counting how many voxels are occupied
    ROcc =  findall(x -> x > c.threshold, m.popt)
    m.Vol2[m.evalstep + 1] = size(ROcc, 1)
    ROcc = []

    # Diversity indexes depend on the number of clonal populations that can exist, so iterate along each one of them to check if they have any cell
    for e = 1 : 2^c.alt
        if m.pops[e, m.evalstep + 1] > 0    # Consider only populations with at least 1 cell for these calculations; otherwise, NaNs will appear
            m.Shannon[m.evalstep + 1] = m.Shannon[m.evalstep + 1] - (m.pops[e, m.evalstep + 1] / m.totpop[m.evalstep + 1]) * log(m.pops[e, m.evalstep + 1] / m.totpop[m.evalstep + 1])
            m.Simpson[m.evalstep + 1] = m.Simpson[m.evalstep + 1] + (m.pops[e, m.evalstep + 1] / m.totpop[m.evalstep + 1])^2
        end
    end

    # Retrieve elapsed time between evaluation steps
    m.elapsed = time() - c.TimeStart

    # Increase evaluation step by 1
    m.evalstep = m.evalstep + 1
end


function monitor2files(m::Monitor, subdir::String=string("Sim",string(ARGS[1]),"/"))

    """
        This function stores all monitored variables in files
    """

    dir_to_save = joinpath(@__DIR__, subdir)
    writedlm(joinpath(dir_to_save, string("Totpop.txt")), m.totpop)
    writedlm(joinpath(dir_to_save, string("Totnec.txt")), m.totnec)
    writedlm(joinpath(dir_to_save, string("VolPET.txt")), m.vol)
    writedlm(joinpath(dir_to_save, string("Vol_real.txt")), m.Rvol)
    writedlm(joinpath(dir_to_save, string("ActPET.txt")), m.totnew)
    writedlm(joinpath(dir_to_save, string("Act_real.txt")), m.Rtotnew)
    writedlm(joinpath(dir_to_save, string("Shannon.txt")), m.Shannon)
    writedlm(joinpath(dir_to_save, string("Simpson.txt")), m.Simpson)
    writedlm(joinpath(dir_to_save, string("Genspop.txt")), m.pops)
end


function increase_tstep(m::Monitor)

    """
        This function increases time step by 1, to get to next iteration
    """

    m.t = m.t+1;
end
