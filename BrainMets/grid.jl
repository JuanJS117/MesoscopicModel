"""

    MESOSCOPIC SIMULATOR - Brain Metastases version

    grid.jl

    This module initializes all grid structures containing info about cells. More specifically,
    those structures include a 4D grid storing cell number of each clonal population at each voxel, several
    grids containing info about necrotic and newborn cells per voxel, and auxiliary grids to help updating
    the whole system at each iteration without including artifacts. In this module there is also included
    a function to perform a single iteration, updating all cell numbers according to undergoing basic cellular
    processes, which are also included here as functions.


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

mutable struct Grid

    ################################################################################
    # MAIN MULTIDIMENSIONAL GRIDS
    ################################################################################

    G::Array{Float64, 4}                # Grid containing cell number of each clonal population at each voxel
    Nec::Array{Float64, 3}              # Grid containing number of necrotic cells per voxel
    Act::Array{Float64, 3}              # Grid containing number of newborn cells per voxel
    Rho::Array{Float64, 3}              # Grid containing local mean growth rate


    ################################################################################
    # AUXILIARY MULTIDIMENSIONAL GRIDS
    ################################################################################

    fdata::Array{Float64,2} # Input file containinig initial cell distribution
    Gnext::Array{Float64, 4}            # Auxiliary grid to help updating 'G'
    G2::Array{Float64, 4}               # Auxiliary grid that flattens 4D 'G' grid into 3D grid (although last dimension remains as a 1D array), to help finding occupied voxels
    Necnext::Array{Float64, 3}          # Auxiliary grid to help updating 'Nec'
    Actnext::Array{Float64, 3}          # Auxiliary grid to help udpating 'Act'
    Rhonext::Array{Float64, 3}          # Auxiliary grid to help updating 'Rho'
    Occ::Array{CartesianIndex{3}, 1}    # Array containing 3D coordinates of voxels with at least 1 cell
    ROcc::Array{CartesianIndex{3}, 1}   # Array containing 3D coordinates of voxels with at least 'c.threshold' (variable from constants module) of carrying capacity


    ################################################################################
    # INITIALIZATION
    ################################################################################

    function Grid(c::Constants)

        G = zeros(c.N, c.N, c.N, 2^c.alt)   # Cells can belong to any of 2^alt clonal populations, and be placed at any of NxNxN voxels.
                                            # So, in order to track their number, cells require a 4D grid as this
        Nec = zeros(c.N, c.N, c.N)          # Dead cells do not belong to any clonal population, so a grid tracking their number will only
                                            # 3D, in order to know at which voxel are they placed
        Act = zeros(c.N, c.N, c.N)          # Same as above goes for newborn cells
        Rho = zeros(c.N, c.N, c.N)          # Mean voxel's growth rate (NOT IMPLEMENTED YET)


        # Cells are placed according to an initial distribution.
        # This initial distribution is generated from a simulation, so that cell distribution reaches a feasible configuration.
        # The initial distribution is the same for all simulations, in order to avoid any bias related to cell placement.
        fdata = readdlm(joinpath(@__DIR__,"InitialCellDistribution.txt"))
        for i = 1:size(fdata,1)
            if i < size(fdata,1)/7.5    # This is a custom way of ensuring a fixed proportion (1%) of cells from population 1 in the initial distribution
            # if i < size(fdata,1)/4    # This is a custom way of ensuring a fixed proportion (10%) of cells from population 1 in the initial distribution
            # if i < size(fdata,1)/2.8  # This is a custom way of ensuring a fixed proportion (20%) of cells from population 1 in the initial distribution
            # Although we are aware that this is not a desirable (and reproducible) way of fixing an initial proportion of cells from population 1, since it is
            # based on empirical observations, it works fast and is pretty accurate
                G[Int64(fdata[i,1]),Int64(fdata[i,2]),Int64(fdata[i,3]),2] = fdata[i,4]
            else
                G[Int64(fdata[i,1]),Int64(fdata[i,2]),Int64(fdata[i,3]),1] = fdata[i,4]
            end
            Nec[Int64(fdata[i,1]),Int64(fdata[i,2]),Int64(fdata[i,3])] = fdata[i,7]
            Act[Int64(fdata[i,1]),Int64(fdata[i,2]),Int64(fdata[i,3])] = fdata[i,6]
        end


        Gnext = copy(G)                     # Use copy to ensure that G and Gnext are different entities
                                            # (assignment by value, instead of assignment by reference)
        Necnext = copy(Nec)
        Actnext = copy(Act)
        Rhonext = copy(Rho)

        G2 = zeros(c.N,c.N,c.N,1)           # Although G2 will contain info about total cell number per voxel, flattening process does not remove dimensions of length 1

        Occ = [CartesianIndex(Int(c.N / 2), Int(c.N / 2), Int(c.N / 2))]
        ROcc = [CartesianIndex(Int(c.N / 2), Int(c.N / 2), Int(c.N / 2))]

        new(G, Nec, Act, Rho, fdata, Gnext, G2, Necnext, Actnext, Rhonext, Occ, ROcc)
    end
end


################################################################################
# FUNCTIONS
################################################################################

function grid_time_step!(g::Grid, c::Constants, m::Monitor)

    """
        This function performs a single iteration step. To do so, it is necessary to go
        through every voxel, check every clonal population, and update their cell numbers
        according to undergone cellular processes and local environment.

        In order to reduce computational cost, not all voxels are evaluated, but only those
        that contain at least one cell. However, at the end of each iteration, it is necessary
        to determine which voxels are occupied
    """


    for l in 1:length(g.Occ)        # Iterate along each occupied voxel. There will be as many evaluations as occupied voxels,
                                    # so things will go fast at the beggining

        # Retrieve numerical indexes from cartesian coordinates of occupied voxels
        i = Int(g.Occ[l][1])
        j = Int(g.Occ[l][2])
        k = Int(g.Occ[l][3])

        # Reinitialize activity at each time step. Newborn cells are considered as such at the iteration at which they appear in the system,
        # so activity matrix needs to be emptied at each time step
        g.Actnext[i, j, k] = 0

        # Evaluate voxels only if they contain at least 1 cell
        if sum(g.G[i, j, k, :]) > 0

            # Evaluate clonal populations only if they have at least 1 cell
            for e in 1:2^c.alt
                if g.G[i, j, k, e] > 0

                    # Convert decimal representation of current clonal population into binary one
                    binGb = decimal2binstr(e, c.alt)

                    # Retrieve basic voxel info
                    Popgen = g.G[i, j, k, e]        # Cell number of current clonal population
                    Popvox = sum(g.G[i, j, k, :])   # Total cell number of current voxel
                    Necvox = g.Nec[i, j, k]         # Number of necrotic cells of current voxel

                    # Reproduction event
                    born = reproduction_event!(g, c, Popgen, Popvox, Necvox, i, j, k, e, binGb)

                    # Death event
                    dead = death_event!(g, c, binGb, Popvox, Necvox, Popgen, i, j, k, e)

                    # Migration event
                    migration_event!(g, c, binGb, Popvox, Popgen, Necvox, i, j, k, e)

                    # Mutation event
                    # mutation_event!(g, c, binGb, Popgen, i, j, k, e)

                end
            end

            # If current iteration requires further system evaluation, perform evaluation step
            if m.t % c.NstepNevalRatio == 0
                update_monitor_populations!(m, c, g.G, g.Nec, g.Act, i,
                    j, k)
            end
        end
    end

    # Update multidimensional grids with all cell processes performed by every clonal population at every voxel
    g.G = copy(g.Gnext)
    g.Nec = copy(g.Necnext)
    g.Act = copy(g.Actnext)
    g.Rho = copy(g.Rhonext)

    # Flatten G into G2
    g.G2 = sum(g.G, dims = 4)
    # Join G2 with necrotic cells to get voxel occupation
    m.popt = g.G2[:, :, :, 1] + g.Nec
    # Retrieve occupied voxels with previous info
    g.Occ = findall(x -> x > 0, m.popt)

end



function normalize_prob(Prep::Float64)

    """
        This function ensures that a probability is constrained to values between 0 and 1
    """

    Prep = max(min(Prep, 1), 0)

end



function reproduction_event!(g::Grid, c::Constants, Popgen::Float64,
    Popvox::Float64, Necvox::Float64, i::Int64, j::Int64, k::Int64, e::Int64,
    binGb::Array{Float64, 1})

    """
        Reproduction event

        This function performs a reproduction event. It calculates how many newborn cells of a given clonal population will appear in a given iteration
    """

    # First of all, modify cell division characteristic time depending on alterations carried by current clonal population
    grate = c.Grate * (1 - binGb' * c.Gweight)
    # Then, calculate a division probability depending on previous time, on time step length, and on voxel occupancy
    # The more cells a voxel has, the less cells will divide, so probability will be lower in crowded voxels
    Prep = c.deltat / grate *(1-(Popvox + Necvox) / c.K)
    Prep = normalize_prob(Prep)
    # Random sample newborn cells from a binomial distribution, with N equal to the number of cells of current clonal population, and P equal to
    # previously calculated division probability
    born = rand(Binomial(Int64(Popgen), Prep))
    # Update multidimensional grids with newborn cells, placing them at the correspoding voxel
    g.Gnext[i, j, k, e] = g.Gnext[i, j, k, e] + born
    g.Actnext[i, j, k] = g.Actnext[i, j, k] + born
    return born

end



function death_event!(g::Grid, c::Constants, binGb::Array{Float64, 1},
    Popvox::Float64, Necvox::Float64, Popgen::Float64, i::Int64, j::Int64,
    k::Int64, e::Int64)

    """
        Death event

        This function performs a death event. It calculates how many cells of a given clonal population will die in a given iteration
    """

    # First of all, modify cell death characteristic time depending on alterations carried by current clonal population
    drate = c.Drate * (1 - binGb' * c.Dweight)
    # Then, calculate a death probability depending on previous time, on time step length, and on voxel occupancy
    # The more cells a voxel has, the more cells will die, so probability will be higher in crowded voxels
    Pkill = c.deltat / drate * (Popvox + Necvox) / c.K
    Pkill = normalize_prob(Pkill)
    # Random sample dead cells from a binomial distribution, with N equal to the number of cells of current clonal population, and P equal to
    # previously calculated death probability
    dead = rand(Binomial(Int64(Popgen), Pkill))
    # Update multidimensional grids with dead cells, placing them at the correspoding voxel, and also substracting them from current clonal population
    g.Gnext[i, j, k, e] = g.Gnext[i, j, k, e] - dead
    g.Necnext[i, j, k] = g.Necnext[i, j, k] + dead
    return dead
end



function migration_event!(g::Grid, c::Constants, binGb::Array{Float64, 1},
    Popvox::Float64, Popgen::Float64, Necvox::Float64, i::Int64, j::Int64,
    k::Int64, e::Int64)

    """
        Migration event

        This function performs a migration event. It calculates how many cells of a given clonal population will migrate to surrounding voxels in a given iteration.
        Migration occurs in two steps: first of all, cells leaving current voxel are calculated, and then, leaving cells are distributed in surrounding voxels
    """

    # First of all, modify cell migration characteristic time depending on alterations carried by current clonal population
    migrate = c.Migrate * (1 - binGb' * c.Migweight)
    # Then, calculate a migration probability depending on previous time, on time step length, and on voxel occupancy
    # The more cells a voxel has, the more cells will migrate, so probability will be higher in crowded voxels
    Pmig = c.deltat / migrate * (Popvox + Necvox) / c.K
    Pmig = normalize_prob(Pmig)
    # Random sample migrating cells from a binomial distribution, with N equal to the number of cells of current clonal population, and P equal to
    # previously calculated migration probability
    migrants = rand(Binomial(Int64(Popgen), Pmig))

    # Once we know how many cells are leaving current voxel, we have to distribute them in the vicinity
    neigh = 0   # Iterator
    moore = 26  # Number of neighbours considered in Moore vicinity in 3D
    # vonN = 6  # Number of neighbours considered in von Neumann vicinity in 3D

    # Random sample a multinomial distribution with N equal to the number of leaving cells, and P equal to probabilities in auxiliary kernel for distribution of leaving cells
    multinom = Multinomial(migrants, c.wcube)
    gone = rand(multinom)
    N = c.N

    # Now, iterate along each surrounding voxel, and assign distributed cells to corresponding voxel
    for movi in [-1, 0, 1]
        for movj in [-1, 0, 1]
            for movk = [-1, 0, 1]
                xmov = i + movi
                ymov = j + movj
                zmov = k + movk
                if xmov < N+1 && ymov < N+1 && zmov < N+1 && xmov > 0 &&
                    ymov > 0 && zmov > 0 && abs(movi)+abs(movj)+abs(movk)!=0
                    neigh = neigh + 1
                    g.Gnext[xmov, ymov, zmov, e] = g.Gnext[xmov, ymov, zmov, e] + gone[neigh]
                    g.Gnext[i, j, k, e] = g.Gnext[i, j, k, e] - gone[neigh]
                end
            end
        end
    end
end



function mutation_event!(g::Grid, c::Constants, binGb::Array{Float64, 1},
    Popgen::Float64, i::Int64, j::Int64, k::Int64, e::Int64)

    """
        Mutation event

        This function performs a mutation event. It introduces a new alteration in a single cell from a given clonal population
    """

    # First of all, modify clonal population mutation characteristic time depending on alterations carried by current clonal population
    mutrate = c.Mutrate * (1 - binGb' * c.Mutweight)
    # Then, calculate a mutation probability depending on previous time, on time step length, and on how many cells belong to current clonal population
    # The more cells a clonal population has, the more likely it will be for one of them to acquire an alteration
    Pmut = c.deltat / mutrate * (Popgen / c.K)
    Pmut = normalize_prob(Pmut)

    # Perform a Monte Carlo step to decide whether a mutation is going to occur or not
    r = rand(1)
    r = r[1]
    if r < Pmut && e != 2^c.alt # Last condition ensures that the clonal population with all alterations does not suffer any new mutation
        # Pick a random non-altered pathway (slot) and turn it to mutated
        nonalter = findall(x -> x < 1, binGb)   # Find slots in clonal population binary representation with 0, meaning that they are not altered
        r2 = rand(1:length(nonalter))           # Select one of those slots with 0
        mutating = nonalter[r2]
        binGb[mutating] = 1                     # Change slot status from non-altered (0) to altered (1)

        # Switch binary array back to binary string
        binGc = string(Int(binGb[1]), Int(binGb[2]), Int(binGb[3]))

        # Code below retrieves back clonal population decimal representation from binary string
        decG = parse(Int, binGc, base=2) + 1

        # Update multidimensional grid with cell from new clonal population
        g.Gnext[i, j, k, e] = g.Gnext[i, j, k, e] - 1
        g.Gnext[i, j, k, decG] = g.Gnext[i, j, k, decG] + 1
    end
end
