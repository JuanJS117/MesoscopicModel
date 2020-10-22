"""

    MESOSCOPIC SIMULATOR v1.0.0

    main.jl

    Main module. It loads required packages, calls all other modules, and creates a folder
    environment to store all simulation files. Then it runs a single tumor simulation, starting
    from a bunch of cells, and growing until the tumor reaches a given size. Once the simulation
    is done, all monitored variables are stored in files.


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



################################################################################
# REQUIRED PACKAGES
################################################################################

using Distributions     # Includes binomial and multinomial distributions
using Random            # Allows random sampling from previous probability distributions
using DelimitedFiles    # Enhances file I/O


################################################################################
# REQUIRED MODULES
################################################################################

include("constants.jl")     # import predefined constants / parameters
include("tools.jl")         # import helper functions
include("grid.jl")          # main data structure


# Fix seed if you want sim results to be reproducible
# const seedVal = 1
# Random.seed!(seedVal)
Random.seed!()


c = Constants()
g = Grid(c)
m = Monitor(c)


################################################################################
# FOLDER ENVIRONMENT FOR SIMULATION FILES
################################################################################

# Check if there already exists a folder named after current simulation. If it does
# not exists, create it and name it properly, and create a parameter file. If it
# exists, overwrite it
if !ispath(string("Sim",string(ARGS[1]),"/"))
    mkpath(joinpath(@__DIR__, string("Sim",string(ARGS[1]),"/")))
    touch(string("Sim",string(ARGS[1]),"/Params.txt"))
else
    rm(string("Sim",string(ARGS[1]),"/"), recursive = true)
    mkpath(joinpath(@__DIR__, string("Sim",string(ARGS[1]),"/")))
    touch(string("Sim",string(ARGS[1]),"/Params.txt"))
end

# Create a parameter file, to store randomly sampled initial parameters (characteristic times for each cell process)
open(joinpath(@__DIR__, string("Sim",string(ARGS[1]),"/Params.txt")), "w") do file
    println(file, c.Grate, " ", c.Drate, " ", c.Mutrate, " ", c.Migrate)
end


################################################################################
# MAIN SIMULATION LOOP
################################################################################

@time while m.Vol2[m.evalstep] < c.VolEnd

    grid_time_step!(g, c, m)    # Perform a single iteration

    increase_tstep(m)           # Move to the next time step

    # If current time step requires a system evaluation
    if m.t % c.NstepNevalRatio == 0
        # Update all monitored variables
        update_monitor_stats!(m, c)
        # Store system info about each clonal population at each voxel in a separate file
        save_gen_space(g, m, c.N, string("Sim",string(ARGS[1]),"/"))
        # Display a friendly message to keep track of main monitored variables
        print_curr_stats(m)
    end

end


# Store monitored variables into separate files
monitor2files(m, string("Sim",string(ARGS[1]),"/"))
