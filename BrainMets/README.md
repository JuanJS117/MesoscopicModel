# Brain Metastases' mesoscopic model

### A discrete, stochastic, on-lattice, multicompartmental, mesoscale and 3D computational simulation tool to study growth laws of brain metastases

## 1. Motivation

Here we put forward an adapted version of the mesoscopic model to reproduce brain metastases.


## 2. Prerequisites

In order to run simulations of brain metastases with this version of the mesoscopic model, you need an installation of Julia, some specific Julia packages, and the model's core modules.

### 2.1 Installing Julia

Please take a look at the info provided in the main page of [this repository](https://github.com/JuanJS117/MesoscopicModel/tree/main) (section 2.1 and 2.2). There you will find a comprehensive tutorial on how to install and use Julia in different OS.

### 2.2 Related packages

The required packages for running this version of the mesoscopic model are:

- **[Distributions](https://github.com/JuliaStats/Distributions.jl).** This package includes several probability distributions and associated functions. It is used to generate specific probability distributions in a computationally-efficient manner.
- **[Random](https://docs.julialang.org/en/v1/stdlib/Random/).** Here it is provided a way to generate random numbers. It is used to random sample values from specific probability distributions.
- **[DelimitedFiles](https://docs.julialang.org/en/v1/stdlib/DelimitedFiles/).** File I/O (input/output) is a critical point of the model. This package is used to enhance computational time required for I/O tasks.

More info on how to install them is available in the main page of [this repository](https://github.com/JuanJS117/MesoscopicModel/tree/main) (section 2.3).


### 2.3 Model's core modules

The last step required is downloading the [five main modules](https://github.com/JuanJS117/MesoscopicModel/tree/main/BrainMets) that contain core model's codes. Those are:

- **[main.jl](https://github.com/JuanJS117/MesoscopicModel/blob/main/BrainMets/main.jl)** Principal module. It loads all the other modules and performs a single tumor simulation. If you want to run a simulation, you must call this module from the terminal by typing `julia main.jl #`, with # being a custom number, used to identify your simulation.
- **[constants.jl](https://github.com/JuanJS117/MesoscopicModel/blob/main/BrainMets/constants.jl)** This module initializes all model parameters and constants. If you want to change any parameter, you must edit this module with your text editor of choice.
- **[grid.jl](https://github.com/JuanJS117/MesoscopicModel/blob/main/BrainMets/grid.jl)** This module creates all grid structures that store info about the tumor (namely cell number, clonal populations, etc). Here are also included instructions to perform a single iteration, and functions that perform all basic cell processes.
- **[monitor.jl](https://github.com/JuanJS117/MesoscopicModel/blob/main/BrainMets/monitor.jl)** This module contains all functions that allow monitoring tumor macroscopic variables during time, such as volume and heterogeneity. 
- **[tools.jl](https://github.com/JuanJS117/MesoscopicModel/blob/main/BrainMets/tools.jl)** This module includes simple subroutines to perform task such as saving tumor status files, and displaying tumor status in the terminal.

You also need to download the input file **[Param_dist.txt](https://github.com/JuanJS117/MesoscopicModel/blob/main/BrainMets/Param_dist.txt)**, that contains distributions of cell processes' characteristic times to sample from; and the initial cell distribution **[InitialCellDistribution.txt](https://github.com/JuanJS117/MesoscopicModel/blob/main/BrainMets/InitialCellDistribution.txt)**, that is used as an initial condition. Place them in a custom folder, where you will run your simulations of brain metastases.


## 3. Usage

After reading the section on model's usage in the main page of [this repository](https://github.com/JuanJS117/MesoscopicModel/tree/main) (section 3), it should be straightforward to run simulations with the mesoscopic model. However, take care, since this version requires some more arguments in the input command. While we will not cover how to run simulations in this section, we will build upon the main page's tutorial, and detail how to run a simulation of a brain metastasis using this version of the model. The general command to write in your console is:

  julia main.jl SimName Vdiv Vmig
  
These three arguments stand for:

- **SimName** The name you wish to put to the simulation folder.
- **Vdiv** The advantage that the 2nd population will get in division. Mathematically, it is described as the ratio between 1st population and 2nd population's times of division. Hence, its value will range between 0 and 1, with a value closer to 1 meaning a smaller advantage.
- **Vmig** The advantage that the 2nd population will get in migration speed. Mathematically, it is described as the ratio between 1st population and 2nd population's migration coefficients. Hence, its value will range between 0 and 1, with a value closer to 1 meaning a smaller advantage.

Different combinations of these parameters (**Vmig** and **Vdiv**) will provide different growth dynamics, hence influencing the resulting exponent &beta;.
