"""

    MESOSCOPIC SIMULATOR v1.0.0

    tools.jl

    In this module there are functions that do not fit in the others. They come in handy
    for several purposes: converting a decimal representation into a binary one (useful for
    mutation events), saving a tumor time lapse in files, and displaying a friendly message
    to keep track of simulation status.


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

    Module contains tools for testing, saving results to files, visualizastion
    etc.

"""



include("monitor.jl")
include("grid.jl")


################################################################################
# FUNCTIONS
################################################################################

function decimal2binstr(e::Int64, alt::Int64)

    """
        This function converts a decimal number into a binary string
    """

    binG = digits(e-1, base=2, pad=alt) |> reverse
    return convert(Array{Float64, 1}, binG)
end


function save_gen_space(g::Grid, m::Monitor, N::Int64, subdir::String=string("Sim",string(ARGS[1]),"/"))

    """
        This function stores a tumor snapshot (cell numbers of each clonal population at each voxel)
        into a file named after current iteration
    """

    dir_to_save = joinpath(@__DIR__, subdir)
    filename = joinpath(dir_to_save, string("Gen_space_",
    string(Int64(floor(m.t))),".txt"))
    open(filename, "w") do file
        for i in 1:N
            for j in 1:N
                for k in 1:N
                    if sum(g.G[i, j, k, :]) > 0
                        wpop = g.G[i, j, k, :]
                        actF = g.Act[i, j, k]
                        necF = g.Nec[i, j, k]
                        println(file, i, " ", j, " ", k, " ", wpop[1], " ",
                        wpop[2], " ", wpop[3], " ", wpop[4], " ", wpop[5],
                        " ", wpop[6], " ", wpop[7], " ", wpop[8], " ",
                        actF, " ", necF)
                    end
                end
            end
        end
    end

end


function print_curr_stats(m::Monitor)

    """
        This function depicts a friendly message in terminal to keep track of
        current simulation status
    """

    println("Cell no: ", m.totpop[m.evalstep], "; Volume: ", m.Vol2[m.evalstep],
     "; Activity: ", m.totnew[m.evalstep], "; Necrotics: ",
    m.totnec[m.evalstep], "; Het: ", m.Shannon[m.evalstep])
    println("Iteration: ", m.t, "; Time elapsed: ", m.elapsed)
    println("------------------------------------------------------------------")
end
