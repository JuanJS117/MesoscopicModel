# Mesoscopic Model 1.0

## A discrete, stochastic, on-lattice, multicompartmental, mesoscale and 3D computational simulation tool to study evolutionary dynamics and heterogeneity during tumor growth

### 1. Description

Here we put forward the mesoscopic model, a simulation platform intended to reproduce tumor growth and progression *in silico*, in a way that evolutionary dynamics and intratumor heterogeneity can be studied and related to other macroscopic tumor features. The model works at the mesoscopic scale, integrating both information at the cellular level, and sizeable clinically-relevant tumors. In doing so, whole simulated tumors with nearly 6 cm of diameter and up to 10<sup>10</sup> cells can be simulated at considerably fast times (2~5 min). The model let us implement mutational and CNV information that affects the way cells behave and interact with each other, while keeping the same resolution as clinical images, so that real PET and/or MRI images can be compared with model results. An example of this is shown in image below: in **A)**, we can see a MRI image of a real glioblastoma, while in **B)**, several *in silico* tumor sections are depicted. It is noticeable that the lobules appearing in the real glioblastoma are reproduced by the model, emerging in simulated tumors.

![Fig 2](https://github.com/JuanJS117/MesoscopicModel/blob/main/fig4.png)

The model is based in an *on lattice* 3D spatial domain, where each compartment can contain several cells. Compartments are called voxels, as they keep the same resolution as this basic clinical imaging unit (around 1 mm<sup>3</sup>). Cells perform basic processes: division, death, migration and mutation, and they can belong to different clonal populations, depending on the genes/pathways they have altered. These alterations affect the rates at which cells perform basic processes, in such a way that cells from an altered clonal population may gain a selective advantage. As evaluating cell by cell would be really time-consuming, whole clonal populations are evaluated at once, considering that cells belonging to the same population behave mostly in the same way (except for some intrinsic noise due to stochastic cell processes). Down below it is depicted the basic model algorithm: at each iteration, every clonal population in every voxel is evaluated, and its cell number is updated with cell gains and losses coming from basic processes (**A)**). A toy depiction of an *in silico* tumor is shown in **B)**, where cells start in a single voxel, and they spread through division and mutation, with the tumor increasing its heterogeneity as they also mutate. In **C)** we can see a truly section of a simulation in false color, pointing that a single voxel can contain thousands of cells.

![Fig 1](https://github.com/JuanJS117/MesoscopicModel/blob/main/fig1.png)

Thanks to this setup, we can keep track of all clonal populations, to see how cells from them all compete among them to access resources and invade new areas. By looking at these evolutionary dynamics, we can measure tumor heterogeneity, and link it to macroscopic features such as the lobules previously mentioned. Some of these macroscopic features, such as rim width or surface regularity, carry prognostic value in real life, so studying them in the model may let us gain deeper insight into the processes that let them emerge. In the image below we can see tridimensional renderings of clonal populations' spatial distribution (**A)**). In **B)** a similar section to image 1 is depicted of the same simulation as in **A)**, and in **C)**, we can see the tridimensional rendering of all clonal populations packed together. Finally, in **D)** we show the phylogenetic tree of this simulation, depicting which alterations appeared in the tumor and at which time point.

![Fig 3](https://github.com/JuanJS117/MesoscopicModel/blob/main/fig5.png)

Further model details and results can be seen by reading the preprint mentioned in **Credits** section.


### 2. Julia installation and required packages

To run a tumor simulation, you need to install Julia in your computer. You can download Julia from [here](https://julialang.org/downloads/). Search for the proper version depending on your platform (Windows, macOS or Linux), and follow the [platform specific instructions](https://julialang.org/downloads/platform/). As a recomendation, the model is built upon Julia version 1.1.1, so we encourage users to try and install this same version in order to use the model. Although we expect so, we do not know if newer/older versions will support the code presented here.

Additionally, the model requires some Julia built-in packages to be preinstalled before running simulations. Once you have installed Julia in your computer, you can download and install any Julia package by opening the Julia Command-Line (type `julia` in your terminal) and typing the following commands:

    use Pkg
    Pkg.add("Package Name")
    
The required packages are "Distributions", "Random", and "DelimitedFiles". Once you have installed all of them, you can go back to terminal prompt by typing `close()` in your Julia Command-Line.

Finally, you have to download the five main modules that contain core model codes. Those are "main.jl", "constants.jl", "grid.jl", "tools.jl" and "monitor.jl". Place them in a custom folder, where you will run tumor simulations.


### 3. Usage

Now you are ready to play with the model. To run a single simulation, open the terminal and navigate to the folder where you placed core modules by typing in your command-line:

    cd folder_path
    
Once you are placed in the folder where all your modules are, please type the following in your terminal prompt:

    julia main.jl #
    
With '#' being any number you want. In this way, your simulation files will be stored in a folder named 'Sim#'. Note that, if you run a second simulation using the same '#', files from the previous one will be overwritten.

During simulation, successive messages will be prompted in the terminal, looking like this one below:

    Cell no: 1.36007572e8; Volume: 3429.0; Activity: 2.45638e6; Necrotics: 2.87404226e8; Het: 0.7414231619172974
    Iteration: 820; Time elapsed: 36.30663514137268
    ------------------------------------------------------------------
  
In this way, you can keep track of tumor status during simulation. 

Running a single simulation is great, but if you need to perform several of them, you will find it tiresome to do it one by one, having to wait for a simulation to finish in order to throw the next one. In macOS and Linux, you can type this command in the terminal to throw *N* simulations, each of them starting right after the previous one is finished:

    for i in {1..N} ; do echo Sim${i} ; julia main.jl $i ; done
    
In Windows, the sintaxis is slightly different.

    FOR /L %I IN (1,1,N) DO julia main.jl %I
    
Once all simulations have finished, you will have *N* new folders with simulation files. Although this is much less tedious, you still have to wait for each simulation to finish until the next one starts. You can always open several terminals at once, and split the *N* simulations you need to run into all opened terminals. 


### 4. Simulation files

Once you have run your first simulation, navigate to the newly created 'Sim#' folder. Here you will find a bunch of files, most of them being named like this: *Gen_space_####.txt*. Those files contain a system snapshot at iteration #### (snapshots are usually taken each 20 iterations). If you open any of them, you will see a structure containing several rows similar to the one below:

    29 42 40 7.0 0.0 0.0 0.0 925.0 99.0 7.0 0.0 56.0 0.0
    
Files come without a header, so you won't know what does each column mean unless you read this document. The header for all of them is:

    Xcoord Ycoord Zcoord Pop1 Pop2 Pop3 Pop4 Pop5 Pop6 Pop7 Pop8 Necrotics Newborn
    
Meaning that each row contains all cell numbers within a voxel. The first three columns indicate the spatial coordinates of the voxel, and the following eight columns contain the cell numbers of each clonal population. Notice that in the example there are 8 clonal populations, due to a simulation being done considering 3 possible alterations. If you work with a different number of alterations *G*, expect a number of columns equal to 5+2<sup>G</sup>. The last two columns represent the number of necrotic and newborn cells within the voxel, respectively. Note that, while necrotics accumulate throught time (their number increase as a monotonic function), newborn cells are snapshots of the system at a given iteration.

By knowing how this file is structured, it is easy to decode it and analyze any parameter of interest. In this repository a Matlab code is uploaded, that contains a simple function to retrieve these parameters and plot them, by reading the files generated during simulation.


### 5. Editing the code

Current version of the model works with in-code parameters, so if you want to modify any of them, you must edit 'constants.jl' module. Any text editor will suit for this purpose; however, here we recommend using Atom. You can download Atom from [here](https://atom.io). As a hackable editor, you can install several packages that will let you work with Julia codes, and even test and debug them directly on Atom. The basic packages required to comfortably work with Julia in Atom are:

* **language-julia.** This package provides support for Julia codes, including syntax highlighting and snippets for common Julia keywords.
* **julia-client.** Boots Julia from inside Atom, providing autocompletion and evaluation within the editor.
* **ink.** Provides generic UI components for building IDEs in Atom.
* **uber-juno.** Sets up Juno IDE, a Julia environment to run Julia code interactively within Atom.

Install these packages in Atom looking for them in `Preferences -> Packages`, and be sure to keep them updated. You may probably need to restart Atom after installing them.

Atom is just an option, and the one we chose to work with the model. However, feel free to read and edit the code in whatever way you feel more comfortable with. Jupyter Notebook is another recommended editor. [Here](https://datatofish.com/add-julia-to-jupyter/) you can find a tutorial to setup Julia in Jupyter Notebook, and run Julia code within it.


### 6. Reproducibility


### 7. Tumor graphics


### 8. Future work

Currently we are focused on properly parameterizing the model with genetic/clinical data and bayesian algorithms, in order to reproduce realistic glioblastomas. As the model is general enough, in theory it allows for reproducing any type of tumor; however, that would require a much more basic previous parameterization, to define a proper number of alterations to be considered, and a set of characteristic times for basic cell processes. A future line of work is to define sets of parameters that are associated with certain kinds of tumors, so that any of them can be simulated in no time, without requiring any previous parameter search.

Although basic in its design, the model is complex enough to allow for the emergence of tumor properties that behave in a similar way than they do *in vivo*. However, the model still lacks some key components that must be added in posterior versions. Some of them are listed down below:

* **Therapy.** Without this element, the model can only produce untreated tumors, which is something far away from reality. Introducing both chemo and radiotherapy (and even immunotherapy) would in turn allow to reproduce the evolution of tumors in patients already treated, and search for the optimal therapy schemes, that lead to the best survival times. This is an interesting study to do and undoubtedly a future milestone in this work. Resistance comes in the same pack as treatment, so including it in the model will also allow for studying the emergence of resistant cells.

* **Microenvironment.** It is already known that tumor microenvironment plays a major role in tumor development, as cells do interact with stromal cells and are affected by surrounding conditions. In this model version, microenvironment is modelled in a implicit way, via probabilities associated to each cell process. In a future work, we intend to include a detailed version of extracellular matrix, cancer-associated fibroblasts (CAFs), and even immune cells such as neutrophils and T cells, that would ease immunotherapy inclusion in the model.

* **Vasculature.** The model does not consider a proper vascular system, so hypoxia and lack of nutrients are restricting conditions that can only be implicitly modelled in the system by now. However, developing a mesoscopic version of the vasculature would let us include both of these conditions in a much more precise way, and even allowing us for the inclusion of anti-angiogenic therapies, such as bevacizumab.



### 9. Credits

If you use the mesoscopic model, please cite the following work:

### [**A mesoscopic simulator to uncover heterogeneity and evolutionary dynamics in tumors**](https://www.biorxiv.org/content/10.1101/2020.08.18.255422v1)
Juan Jiménez-Sánchez, Álvaro Martínez-Rubio, Anton Popov, Julián Pérez-Beteta, Youness Azimzade, David Molina-García, Juan Belmonte-Beitia, Gabriel F. Calvo, Víctor M. Pérez-García <br/>
**bioRxiv 2020.08.18.255422** <br/>
doi: https://doi.org/10.1101/2020.08.18.255422 <br/>
*This article is a preprint and has not been certified by peer review yet. It is currently under revision.*   

For any inquiries regarding code usage, or any question related to troubleshooting, please address it to any of the following contributors:
* Juan Jiménez-Sánchez: Juan.JSanchez@uclm.es
* Álvaro Martínez-Rubio: alvaro.martinezrubio@uca.es
* Gabriel Fernández Calvo: Gabriel.Fernandez@uclm.es 
* Víctor M. Pérez-García: Victor.PerezGarcia@uclm.es
