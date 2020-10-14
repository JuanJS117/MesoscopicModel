# Mesoscopic Model 1.0

## A discrete, stochastic, on-lattice, multicompartmental, mesoscale and 3D computational simulation tool to study evolutionary dynamics and heterogeneity during tumor growth

1. ##  Description

Here we present

2. ##  Installation and required packages

To run a tumor simulation, you need to install Julia in your computer. You can download Julia from [here](https://julialang.org/downloads/). Search for the proper version depending on your platform (Windows, macOS or Linux), and follow the [platform specific instructions](https://julialang.org/downloads/platform/).

The model requires some Julia built-in packages to be preinstalled before running simulation. Once you have installed Julia in your computer, you can download and install any Julia package by opening the Julia Command-Line (type `julia` in your terminal) and typing the following commands:

    use Pkg
    Pkg.add("Package Name")
    
The required packages are "Distributions", "Random", and "DelimitedFiles". Once you have installed all of them, you can go back to terminal prompt by typing `close()` in your Julia Command-Line.


3. ##  Usage

Now you are ready to play with the model. To run a single simulation, you need to download the five modules that contain all model's codes: "main.jl", "constants.jl", "grid.jl", "tools.jl" and "monitor.jl". Place them into a custom folder, open the terminal, and navigate to that folder by typing in your command-line:

    cd path
    
Once you are placed in the folder where all your modules are, please type the following in your terminal prompt:

    julia main.jl #
    
With '#' being any number you want. In this way, your simulation files will be stored in a folder named 'Sim#'. Note that, if you run a second simulation using the same '#', files from the previous one will be overwritten.


4. ##  Simulation files


5. ##  Credits

If you use the mesoscopic model, please cite the following work:

### **A mesoscopic simulator to uncover heterogeneity and evolutionary dynamics in tumors**
Juan Jiménez-Sánchez, Álvaro Martínez-Rubio, Anton Popov, Julián Pérez-Beteta, Youness Azimzade, David Molina-García, Juan Belmonte-Beitia, Gabriel F. Calvo, Víctor M. Pérez-García <br/>
**bioRxiv 2020.08.18.255422** <br/>
doi: https://doi.org/10.1101/2020.08.18.255422 <br/>
*This article is a preprint and has not been certified by peer review yet. It is currently under revision*   

For any inquiries regarding code usage, or any question related to troubleshooting, please address it to any of the following contributors:
* Juan Jiménez-Sánchez: Juan.JSanchez@uclm.es
* Álvaro Martínez-Rubio: alvaro.martinezrubio@uca.es
* Víctor M. Pérez-García: Victor.PerezGarcia@uclm.es
