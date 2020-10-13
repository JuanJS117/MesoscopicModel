"""

    MESOSCOPIC SIMULATOR v1.0.0

    constants.jl

    This module initializes all model parameters that remain constant throughout the whole simulation.
    Those parameters include spatio-temporal domain (number of voxels, time step and time span), initial conditions
    (starting population, number of alterations considered, voxel's carrying capacity), clonal population's characteristic
    times (for cell division, cell death, migration and mutation), and mutation weights (influence of each alteration in each
    process's characteristic times).


    Designed and written by:
           Juan Jimenez Sanchez - Predoctoral researcher -  Juan.JSanchez@uclm.es
           Alvaro Martinez Rubio - Predoctoral researcher -  alvaro.martinezrubio@uca.es

    Edited (Objects and modules) by:
           Anton Popov - Predoctoral researcher - popovanton567@gmail.com
           Juan Jimenez Sanchez

    Principal investigator:
           Victor M. Perez Garcia - Full Professor -   Victor.PerezGarcia@uclm.es

    For any questions related to model usage or citation, please contact Victor.
    For any inquiries related to model performance or improvements, please address
    them to Juan or Alvaro.

"""



struct Constants

    ################################################################################
    # SPATIO-TEMPORAL DOMAIN PARAMETERS
    ################################################################################

    TimeStart::Float64          # Use it to keep track of execution time
    deltat::Int64               # Time step length (hours)
    tspan::Int64                # Max number of simulation time allowed (hours)
    Nstep::Int64                # Max number of steps allowed
    N::Int64                    # Grid size (number of voxels per dimension: N x N x N)
    Neval::Int64                # Number of time steps between system evaluations
    NstepNevalRatio::Float64    # Number of system evaluations during whole simulation
    VolEnd::Float64             # Maximum tumor volume allowed. Once a tumor reaches this volume, simulation is stopped

    ################################################################################
    # STARTING CONDITIONS
    ################################################################################

    alt::Int64          # Number of alterations (number of clonal populations will be 2^alt)
    P0::Float64         # Initial cell number
    K::Int64            # Voxel's carrying capacity
    threshold::Float64  # Number of cells to be exceeded in order to consider a voxel active


    ################################################################################
    # CHARACTERISTIC TIMES
    ################################################################################

    fdata::Array{Float64,2} # Input file containinig mean and standard deviation of cell processes' characteristic times
    Grate_mean::Float64     # Mean cell division time
    Grate_sd::Float64       # Standard deviation of cell division time
    Drate_mean::Float64     # Mean cell death time
    Drate_sd::Float64       # Standard deviation of cell death time
    Migrate_mean::Float64   # Mean cell migration time
    Migrate_sd::Float64     # Standard deviation of cell migration time
    Mutrate_mean::Float64   # Mean clonal population mutation time
    Mutrate_sd::Float64     # Standard deviation of clonal population mutation time
    Grate::Float64          # Basal cell division time
    Drate::Float64          # Basal cell death time
    Migrate::Float64        # Basal cell migration time
    Mutrate::Float64        # Basal clonal population mutation time


    ################################################################################
    # MUTATION WEIGHTS
    ################################################################################

    Gweight::Array{Float64, 1}      # Set of weights that influence basal cell division time
    Dweight::Array{Float64, 1}      # Set of weights that influence basal cell death time
    Mutweight::Array{Float64, 1}    # Set of weights that influence basal clonal population mutation time
    Migweight::Array{Float64, 1}    # Set of weights that influence basal cell migration time


    ################################################################################
    # AUXILIARY KERNEL FOR DISTRIBUTING MIGRATING CELLS IN THE NEIGHBOURHOOD
    ################################################################################

    c_old::Int64                # Iterator
    wcube::Array{Float64, 1}    # 3x3x3 kernel containing normalized migration probabilities to neighbour voxels, depending on distance from central voxel


    ################################################################################
    # INITIALIZATION
    ################################################################################

    function Constants()

        TimeStart = time()

        deltat = 4
        tspan = 1e5
        Nstep = floor(tspan / deltat)
        N = 80
        Neval = ceil(Nstep / 20) + 1
        NstepNevalRatio = round(Nstep / Neval)
        VolEnd = 1.2e5;
        alt = 3
        P0 = 1e1
        K = 2e5
        threshold = 0.2 * K

        # Retrieve parameters from input file
        fdata = readdlm(joinpath(@__DIR__,"Param_dist.txt"))
        Grate_mean = fdata[1,1];
        Grate_sd = fdata[1,2];
        Drate_mean = fdata[2,1];
        Drate_sd = fdata[2,2];
        Mutrate_mean = fdata[3,1];
        Mutrate_sd = fdata[3,2];
        Migrate_mean = fdata[4,1];
        Migrate_sd = fdata[4,2];

        # Random sample characteristic times from uniform distributions based in Param_dist.txt data
        Grate = 1.0
        Migrate = 10.0
        Grate, Migrate = adjust_grate_migrate(Grate, Migrate,
                                    Grate_mean, Grate_sd, Migrate_mean, Migrate_sd)
        Drate = rand(Uniform(Drate_mean-Drate_sd, Drate_mean+Drate_sd))
        Mutrate = rand(Uniform(Mutrate_mean-Mutrate_sd, Mutrate_mean+Mutrate_sd))

        # Set all weights
        Gweight = [0.32, 0.28, 0.25]
        Dweight = [-0.15, -0.05, -0.45]
        Mutweight = [0.18, 0.18, 0.32]
        Migweight = [0.65, 0.05, 0.05]

        # Create weights for surrounding voxels (Moore neighbourhood)
        c_old = 0
        wcube = zeros(26)
        sumcube = 0

        # Create auxiliary kernel for distribution of migrating cells
        for i in [-1, 0, 1]
            for j in [-1, 0, 1]
                for k in [-1, 0, 1]
                    if abs(i) + abs(j) + abs(k) != 0
                        c_old = c_old + 1
                        wcube[c_old] = 1 / sqrt(abs(i) + abs(j) + abs(k))
                        sumcube = sumcube + wcube[c_old]
                    end
                end
            end
        end

        c_old = 0
        for i in [-1, 0, 1]
            for j in [-1, 0, 1]
                for k in [-1, 0, 1]
                    if abs(i) + abs(j) + abs(k) != 0
                        c_old = c_old + 1
                        wcube[c_old] = wcube[c_old] / sumcube
                    end
                end
            end
        end


        new(TimeStart, deltat, tspan, Nstep, N, Neval, NstepNevalRatio, VolEnd, alt, P0, K, threshold, fdata,
        Grate_mean, Grate_sd, Drate_mean, Drate_sd, Migrate_mean, Migrate_sd,
        Mutrate_mean, Mutrate_sd, Grate, Migrate, Drate, Mutrate, Gweight, Dweight, Mutweight, Migweight, c_old, wcube)

    end
end


################################################################################
# FUNCTIONS
################################################################################

function adjust_grate_migrate(Grate::Float64, Migrate::Float64,
    Grate_mean::Float64, Grate_sd::Float64, Migrate_mean::Float64, Migrate_sd::Float64)

    """
        This function ensures that cell division and migration times do not get extremely
        different, a situation that would lead to artifacts (cubic tumors, etc)
    """

    while Grate / Migrate < 0.25 || Migrate / Grate < 0.1
        Grate = rand(Uniform(Grate_mean-Grate_sd, Grate_mean+Grate_sd))
        Migrate = rand(Uniform(Migrate_mean-Migrate_sd, Migrate_mean+Migrate_sd))
    end
    Grate, Migrate
end
