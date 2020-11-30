# Mesoscopic Model 1.0

### A discrete, stochastic, on-lattice, multicompartmental, mesoscale and 3D computational simulation tool to study evolutionary dynamics and heterogeneity during tumor growth

## 1. Description

Here we put forward the mesoscopic model, a simulation platform intended to reproduce tumor growth and progression *in silico*, in a way that evolutionary dynamics and intratumor heterogeneity can be studied and related to other macroscopic tumor features. The model works at the mesoscopic scale, integrating both information at the cellular level, and sizeable clinically-relevant tumors. In doing so, whole simulated tumors with nearly 6 cm of diameter and up to 10<sup>10</sup> cells can be simulated at considerably fast times (2~5 min). The model let us implement mutational and CNV information that affects the way cells behave and interact with each other, while keeping the same resolution as clinical images, so that real PET and/or MRI images can be compared with model results. An example of this is shown in image below: in **A)**, we can see a MRI image of a real glioblastoma, while in **B)**, several *in silico* tumor sections (coming from simulations with parameters fitted to real glioblastomas) are depicted. It is noticeable that the lobules appearing in the real glioblastoma are reproduced by the model, emerging in simulated tumors.

![Fig 2](https://github.com/JuanJS117/MesoscopicModel/blob/main/fig4.png)

The model is based in an *on lattice* 3D spatial domain, where each compartment can contain several cells. Compartments are called voxels, as they keep the same resolution as this basic clinical imaging unit (around 1 mm<sup>3</sup>). Cells perform basic processes: division, death, migration and mutation, and they can belong to different clonal populations, depending on the genes/pathways they have altered. These alterations affect the rates at which cells perform basic processes, in such a way that cells from an altered clonal population may gain a selective advantage. As evaluating cell by cell would be really time-consuming, whole clonal populations are evaluated at once, considering that cells belonging to the same population behave mostly in the same way (except for some intrinsic noise due to stochastic cell processes). Down below it is depicted the basic model algorithm: at each iteration, every clonal population in every voxel is evaluated, and its cell number is updated with cell gains and losses coming from basic processes (**A)**). A toy depiction of an *in silico* tumor is shown in **B)**, where cells start in a single voxel, and they spread through division and mutation, with the tumor increasing its heterogeneity as they also mutate. In **C)** we can see a truly section of a simulation in false color, pointing that a single voxel can contain thousands of cells.

![Fig 1](https://github.com/JuanJS117/MesoscopicModel/blob/main/fig1.png)

Thanks to this setup, we can keep track of all clonal populations, to see how cells from them all compete among them to access resources and invade new areas. By looking at these evolutionary dynamics, we can measure tumor heterogeneity, and link it to macroscopic features such as the lobules previously mentioned. Some of these macroscopic features, such as rim width or surface regularity, carry prognostic value in real life, so studying them in the model may let us gain deeper insight into the processes that let them emerge. In the image below we can see tridimensional renderings of clonal populations' spatial distribution (**A)**). In **B)** a similar section to image 1 is depicted of the same simulation as in **A)**, and in **C)**, we can see the tridimensional rendering of all clonal populations packed together. Finally, in **D)** we show the phylogenetic tree of this simulation, depicting which alterations appeared in the tumor and at which time point.

![Fig 3](https://github.com/JuanJS117/MesoscopicModel/blob/main/fig5.png)

Further model details and results can be seen by reading the works the mesoscopic model has appeared in so far. All of them are mentioned in the **Publications** section. If you use the model or cite it in any papers of yours, we kindly ask you to reference our work. More details regarding this are provided in the **Credits** section.


## 2. Installation and requirements

Down below we detail every required step to run a simulation and visualize output files. We encourage users to follow carefully every instruction, as they have been thoroughly tested for proper code execution. Nevertheless, in case any problem arises during any step (due to installation in different OS), feel free to contact any of the people listed at the end of this page for troubleshooting.

### 2.1 Julia installation

The model is written in Julia, so in order to run a tumor simulation, you need to install Julia in your computer. You can download Julia from [here](https://julialang.org/downloads/). Search for the proper version depending on your platform (Windows, macOS or Linux), and follow the [platform specific instructions](https://julialang.org/downloads/platform/). The model is built upong Julia version 1.1.1, though compatibility is guaranteed with version 1.5.2 so far. As a recommendation, we encourage users to download and install the latest stable release that supports the model. Further versions will be checked for compatibility as they are released.

### 2.2 Running Julia from the terminal

After downloading and installing Julia, some additional steps are required to run it directly from the terminal (macOS), shell (Unix) or cmd (Windows). There are other options to use Julia: in macOS, for example, Julia installation brings an app that, when oppened, triggers a specific Julia terminal that let you run commands directly from the prompt. We forget this for now, as we are not going to use it. Depending on your OS, required steps to enable calling Julia from the terminal/shell/cmd are:

* ### macOS

To run Julia from the terminal, navigate to `usr/local/bin` and remove `julia` file (if present). This folder is hidden, so in order to navigate to it, you may either:

  * Go to Finder, press `Command+Shift+G`, and type `/usr/local/bin/`. This will open the folder in your file explorer.
  * Open the terminal and type `cd /usr/local/bin`.

Some operations are forbidden without the right permissions. If you try to remove `usr/local/bin/julia` from the terminal, you will require superuser permission. Simply add a `sudo` before your command and, when prompted, type your user password.

After doing so, type the following in your terminal:

    ln -s /Applications/Julia-<version>.app/Contents/Resources/julia/bin/julia /usr/local/bin/julia
    
If you downladed Julia version 1.5, previous command will look like this

    ln -s /Applications/Julia-1.5.app/Contents/Resources/julia/bin/julia /usr/local/bin/julia
    
You won't be able to perform previous task without superuser permission. To address this issue, you can use `sudo` again. Type this in the terminal:
    
    sudo ln -s /Applications/Julia-1.5.app/Contents/Resources/julia/bin/julia /usr/local/bin/julia
        
and, when prompted, type your user password. You have just created a symlink to your Julia version. Once done, you can open a terminal and run Julia by simply typing `julia` in the terminal. Moreover, you can run a Julia script directly from the terminal by typing `julia script.jl`. This is the preferred way to execute the model in macOS. 

* ### Windows

In Windows, you will need to add Julia executable directory to PATH. Otherwise, you will need to type the whole path each time you want to run Julia (`C:\Users\myusername\AppData\Local\Julia-<version>\bin\julia.exe` by default). Steps for Windows 10 are listed below:
    
 * Open cmd (press Windows Key + R), type `rundll132 sysdm.cpl,EditEnvironmentVariables`, and hit enter.
 * Go to either "User Variables" or "System Variables" section, find the row with "Path", and click edit.ib     
 * A "Edit environment variable" User Interface will appear. There, click "New" and paste Julia installation directory `C:\Users\JohnDoe\AppData\Local\Programs\Julia-<version>\bin`. 
 * Click OK. 
    
Now you can directly run Julia from the terminal by typing `julia`. Additionally, you can run any Julia script by typing `julia script.jl`. Note that instructions may vary for older Windows versions (XP, 7, 8). Please check the [platform specific instructions link](https://julialang.org/downloads/platform/) for further details.

* ### Linux

Linux offers the easiest options to run Julia from the terminal. You can either create a symlink to Julia inside a folder on your system PATH, or add Julia's bin directory (full path) to your system PATH environment variable. The latter choice is preferred. To do it, you can edit `~/.bashrc` (or `~/.bash_profile`) file. Open it in your text editor of choice and add the following line:

    export PATH="$PATH:/path/to/<Julia directory>/bin"
    
Like this, you should be able to run Julia directly from the shell by typing `julia`. You can also run a Julia script from the terminal by typing `julia script.jl`.

### 2.3 Required Julia packages

Additionally, the model requires some Julia built-in packages to be preinstalled before running simulations. Once you have installed Julia in your computer, there are two ways of installing Julia packages:

- Open Julia Command-Line (type `julia` in your terminal/shell/cmd) and enter the specific package environment Pkg prompt (type `]` in Julia Command-Line). Once you have accessed Pkg prompt, type:

        add PackageName
    
    and let selected package to be installed. Once you are done, close Pkg environment pressing Ctrl+C, and exit Julia Command-Line by typing `exit()`. You will     return to your default terminal/shell/cmd prompt.

- Open Julia Command-Line, and type

        use Pkg
        Pkg.add("Package Name")
    
    Then exit Julia Command-Line to go back to default terminal/shell/cmd prompt.
    
For some Julia versions, these methods may not work. If one of them does not work, try the other.

The required packages for running the model are:

- **[Distributions](https://github.com/JuliaStats/Distributions.jl).** This package includes several probability distributions and associated functions. It is used to generate specific probability distributions in a computationally-efficient manner.
- **[Random](https://docs.julialang.org/en/v1/stdlib/Random/).** Here it is provided a way to generate random numbers. It is used to random sample values from specific probability distributions.
- **[DelimitedFiles](https://docs.julialang.org/en/v1/stdlib/DelimitedFiles/).** File I/O (input/output) is a critical point of the model. This package is used to enhance computational time required for I/O tasks.

### 2.4 Model's core modules

Finally, you have to download the [five main modules](https://github.com/JuanJS117/MesoscopicModel/tree/main/Core%20modules) that contain core model's codes. Those are:

- **[main.jl](https://github.com/JuanJS117/MesoscopicModel/blob/main/Core%20modules/main.jl)** Principal module. It loads all the other modules and performs a single tumor simulation. If you want to run a simulation, you must call this module from the terminal by typing `julia main.jl #`, with # being a custom number, used to identify your simulation.
- **[constants.jl](https://github.com/JuanJS117/MesoscopicModel/blob/main/Core%20modules/constants.jl)** This module initializes all model parameters and constants. If you want to change any parameter, you must edit this module with your text editor of choice.
- **[grid.jl](https://github.com/JuanJS117/MesoscopicModel/blob/main/Core%20modules/grid.jl)** This module creates all grid structures that store info about the tumor (namely cell number, clonal populations, etc). Here are also included instructions to perform a single iteration, and functions that perform all basic cell processes.
- **[monitor.jl](https://github.com/JuanJS117/MesoscopicModel/blob/main/Core%20modules/monitor.jl)** This module contains all functions that allow monitoring tumor macroscopic variables during time, such as volume and heterogeneity. 
- **[tools.jl](https://github.com/JuanJS117/MesoscopicModel/blob/main/Core%20modules/tools.jl)** This module includes simple subroutines to perform task such as saving tumor status files, and displaying tumor status in the terminal.

You also need to download the input file **[Param_dist.txt](https://github.com/JuanJS117/MesoscopicModel/blob/main/Core%20modules/Param_dist.txt)**, that contains distributions of cell processes' characteristic times to sample from. Place them in a custom folder, where you will run tumor simulations.


## 3. Usage

Now you are ready to play with the model. To run a single simulation, open the terminal and navigate to the folder where you placed core modules by typing in your command-line:

    cd folder_path
    
Once you are placed in the folder where all your modules are, please type the following in your terminal prompt:

    julia main.jl #
    
With '#' being any number you want. In this way, your simulation files will be stored in a folder named 'Sim#'. Note that, if you run a second simulation using the same '#', files from the previous one will be overwritten.

During simulation, successive messages will be prompted in the terminal, looking like this one below:

    Cell no: 1.36007572e8; Volume: 3429.0; Activity: 2.45638e6; Necrotics: 2.87404226e8; Het: 0.7414231619172974
    Iteration: 820; Time elapsed: 36.30663514137268
    ------------------------------------------------------------------
  
In this way, you can keep track of tumor status during simulation. Info about total cell number, tumor volume, newborn cells (activity), necrotic cells, and Shannon entropy (heterogeneity) will be displayed each 20 iterations. Additionally, current iteration and elapsed time since the start will also be shown.

Running a single simulation is great, but if you need to perform several of them, you will find it tiresome to do it one by one, having to wait for a simulation to finish in order to throw the next one. In macOS and Linux, you can type this command in the terminal to throw *N* simulations, each of them starting right after the previous one is finished:

    for i in {1..N} ; do echo Sim${i} ; julia main.jl $i ; done
    
In Windows, the sintaxis is slightly different.

    FOR /L %I IN (1,1,N) DO julia main.jl %I
    
Once all simulations have finished, you will have *N* new folders with simulation files. Although this is much less tedious, you still have to wait for each simulation to finish until the next one starts. You can always open several terminals at once, and split the *N* simulations you need to run into all opened terminals. 


### 3.1 Simulation files

Once you have run your first simulation, navigate to the newly created 'Sim#' folder. Here you will find a bunch of files, most of them being named like this: *Gen_space_####.txt*. Those files contain a system snapshot at iteration #### (snapshots are usually taken each 20 iterations). If you open any of them, you will see a structure containing several rows similar to the one below:

    29 42 40 7.0 0.0 0.0 0.0 925.0 99.0 7.0 0.0 56.0 0.0
    
Files come without a header, so you won't know what does each column mean unless you read this document. The header for all of them is:

    Xcoord Ycoord Zcoord Pop1 Pop2 Pop3 Pop4 Pop5 Pop6 Pop7 Pop8 Activity Necrotics
    
Meaning that each row contains all cell numbers within a voxel. The first three columns indicate the spatial coordinates of the voxel, and the following eight columns contain the cell numbers of each clonal population. Notice that in the example there are 8 clonal populations, due to a simulation being done considering 3 possible alterations. If you work with a different number of alterations *G*, expect a number of columns equal to 5+2<sup>G</sup>. The last two columns represent the number of newborn and necrotic cells within the voxel, respectively. Note that, while necrotics accumulate throught time (their number increase as a monotonic function), newborn cells are snapshots of the system at a given iteration. According to the row shown, voxel (29,42,40) will be populated with 1094 alive and 0 dead cells. From these 1094 cells, 7 belong to 1st clonal population, 925 to 5th, 99 to 6th, and 7 to 7th clonal population. From previous iteration, 56 new cells have been born.

By knowing how this file is structured, it is easy to decode it and analyze any parameter of interest. In this repository we have uploaded [two Matlab scripts](https://github.com/JuanJS117/MesoscopicModel/tree/main/Matlab%20graphics) for simulation file decoding:

* [dcode_simfiles.m](https://github.com/JuanJS117/MesoscopicModel/blob/main/Matlab%20graphics/dcode_simfiles.m) reads all snapshot files from a given simulation, and calculates tumor volume (as the number of voxels exceeding 20% of carrying capacity), total number of cells within the tumor, total number of necrotic cells, total activity (newborn cells), and Shannon and Simpson's indexes. While these variables are stored as arrays in separate files, containing variables' values each 20 iterations, this Matlab function also returns 4 cell structures containing info per voxel about total cell number (poptot), cell number per clonal population (pops), necrotic cells (nec) and activity (act), respectively. All it requires as input parameter is the number of the simulation to be decoded. From Matlab console, you can run this function like this:

        dcode_simfiles(nsim);
        
    with nsim being the number of the simulation you want to process. Note that, in order to run this function, its corresponding Matlab script must have been added to Matlab path. Additionally, you must be placed in the directory containing simulation folder.
    
* [geometric_features.m](https://github.com/JuanJS117/MesoscopicModel/blob/main/Matlab%20graphics/geometric_features.m) works at a deeper level than previous function. In fact, it internally runs dcode_simfiles.m to retrieve basic tumor info, and then processes it to calculate tumor surface, tumor volume, rim width and surface regularity. It does so only for snapshot files where tumor volume is above 1 cm<sup>3</sup>. These geometric variables are calculated using the marching cubes algorithm. To run this function, type in the Matlab console:

        geometric_features(nsim)
        
    With nsim being the number of the simulation you want to process.
    
    
### 3.2 Tumor graphics

As you may already noticed, the core modules written in Julia do not provide any graphical representation of *in silico* tumors. However, simulation files contain all ingredients required to produce any desired tumor representations. In this repository we provide some examples to reproduce tumor depictions like the ones shown in [model's preprint](https://www.biorxiv.org/content/10.1101/2020.08.18.255422v1). Notice that these depictions are intended to provide a clearer understanding of what is going on inside tumor guts.

In order for all scripts below to run properly, you must run [dcode_simfiles.m](https://github.com/JuanJS117/MesoscopicModel/blob/main/Matlab%20graphics/dcode_simfiles.m) function before, and store its output into custom variables like this

    [poptot,pops,nec,act] = dcode_simfiles(nsim);
    
With these ingredients, you have all that is required to play with in silico tumor visualization

#### 3.2.1 MRI slice

    nsnapshots = size(poptot,2);
    snapshot = round(nsnapshots*0.85);
    figpos = get(groot, 'ScreenSize');
    w = figure('Name','In-silico MRI slice','Units','pixels','OuterPosition',[100 100 2*figpos(4)/3 2*figpos(4)/3]);
    colormap(gray)
    imagesc(poptot{snapshot}(:,:,40))
    axis tight equal
    axis off
    set(gcf,'color','w');


#### 3.2.2 PET slice

    nsnapshots = size(poptot,2);
    snapshot = round(nsnapshots*0.55);
    figpos = get(groot, 'ScreenSize');
    ventana = figure('Name','In-silico PET slice','Units','pixels','OuterPosition',[100 100 2*figpos(4)/3 2*figpos(4)/3]);
    colormap(flipud(gray))
    imagesc(act{snapshot}(:,:,40))
    axis tight equal
    axis off
    set(gcf,'color','w');
    
    
#### 3.2.3 3D Tumor rendering

    col1 = [27 161 226]./255;   % Cyan
    nsnapshots = size(poptot,2);
    snapshot = round(nsnapshots*0.95);
    popT = poptot{snapshot};
    polyT = popT > 0.15*max(popT(:));
    figpos = get(groot, 'ScreenSize');
    w = figure('Name','3D Tumor rendering','Units','pixels','OuterPosition',[0 0 figpos(4) figpos(4)]);
    hiso1 = patch(isosurface(smooth3(polyT),0.5),'FaceColor',col1,'EdgeColor','none');
    view(3)
    fig = gcf;
    fig.Renderer = 'opengl';
    camlight
    lighting phong
    axis equal
    axis([0 80 0 80 0 80])
    axis off


### 3.3 Editing the code

Current version of the model does not admit input arguments, as it only works with parameters within code. If you want to modify any of them, you must edit 'constants.jl' module. Any text editor will suit for this purpose; however, here we recommend using Atom. You can download Atom from [here](https://atom.io). As a hackable editor, you can install several packages that will let you work with Julia codes, and even test and debug them directly on Atom. The most important is arguably [Juno](https://junolab.org), a Julia environment embedded in Atom. The basic packages required to comfortably work with Julia in Atom are:

* **[uber-juno](https://atom.io/packages/uber-juno).** Sets up Juno IDE, a Julia environment to run Julia code interactively within Atom.
* **[language-julia](https://atom.io/packages/language-julia).** This package provides support for Julia codes, including syntax highlighting and snippets for common Julia keywords.
* **[julia-client](https://atom.io/packages/julia-client).** Boots Julia from inside Atom, providing autocompletion and evaluation within the editor.
* **[ink](https://atom.io/packages/ink).** Provides generic UI components for building IDEs in Atom.

Install these packages in Atom looking for them in `Preferences -> Packages`, and be sure to keep them updated. You may probably need to restart Atom after installing them.

Atom is just an option, and the one we chose to work with the model. However, feel free to read and edit the code in whatever way you feel more comfortable with. Jupyter Notebook is another recommended editor. [Here](https://datatofish.com/add-julia-to-jupyter/) you can find a tutorial to setup Julia in Jupyter Notebook, and run Julia code within it.


### 3.4 Reproducibility

In this section we itemize the most relevant code parameters and constants that influence simulation outcome. The aim is to provide a comprehensive guide of them all, so that users can change them freely and experiment with different tumor properties. Note that both **'constants.jl'** module and **'Param_dist.txt'** file contain parameters fitted to produce realistic glioblastomas, such as those that appear in [here](https://www.biorxiv.org/content/10.1101/2020.08.18.255422v1).

In **'Param_dist.txt'** we can see the required parameters to build uniform distributions of cellular processes' characteristic times. These distributions are used to randomly sample values for characteristic times at the start of the simulation, so the content of 'Param_dist.txt' will strongly influence simulated tumor outcome. From first to last, rows correspond to division, death, mutation and migration. As uniform distributions **U(a,b)** are defined by their bounds **a** and **b**, in 'Param_dist.txt' we provide **(b+a)/2** (mean) in the 1st column, and **(b-a)/2** (half of interval length) in the 2nd column. If you increase a given value from the 1st column, the average characteristic time of corresponding process will enlarge, making tumor cells slower when it comes to perform that process. On the other hand, if you increase a given value from the 2nd column, you will increase the interval of values that characteristic times can take, providing more variability.





## 4. Future work

Currently we are focused on properly parameterizing the model with genetic/clinical data and bayesian algorithms, in order to reproduce realistic glioblastomas. As the model is general enough, in theory it allows for reproducing any type of tumor; however, that would require a much more basic previous parameterization, to define a proper number of alterations to be considered, and a set of characteristic times for basic cell processes. A future line of work is to define sets of parameters that are associated with certain kinds of tumors, so that any of them can be simulated in no time, without requiring any previous parameter search.

Although basic in its design, the model is complex enough to allow for the emergence of tumor properties that behave in a similar way than they do *in vivo*. However, the model still lacks some key components that must be added in posterior versions. Some of them are listed down below:

* **Therapy.** Without this element, the model can only produce untreated tumors, which is something far away from reality. Introducing both chemo and radiotherapy (and even immunotherapy) would in turn allow to reproduce the evolution of tumors in patients already treated, and search for the optimal therapy schemes, that lead to the best survival times. This is an interesting study to do and undoubtedly a future milestone in this work. Resistance comes in the same pack as treatment, so including it in the model will also allow for studying the emergence of resistant cells.

* **Microenvironment.** It is already known that tumor microenvironment plays a major role in tumor development, as cells do interact with stromal cells and are affected by surrounding conditions. In this model version, microenvironment is modelled in a implicit way, via probabilities associated to each cell process. In a future work, we intend to include a detailed version of extracellular matrix, cancer-associated fibroblasts (CAFs), and even immune cells such as neutrophils and T cells, that would ease immunotherapy inclusion in the model.

* **Vasculature.** The model does not consider a proper vascular system, so hypoxia and lack of nutrients are restricting conditions that can only be implicitly modelled in the system by now. However, developing a mesoscopic version of the vasculature would let us include both of these conditions in a much more precise way, and even allowing us for the inclusion of anti-angiogenic therapies, such as bevacizumab.


## 5. Publications

The model has appeared in 1 publication and 2 preprints so far. Both preprints are currently under evaluation for publication. In this section we list the model's contribution to these published works:

* **A mesoscopic simulator to uncover heterogeneity and evolutionary dynamics in tumors.** Juan Jiménez-Sánchez, Álvaro Martínez-Rubio, Anton Popov, Julián Pérez-Beteta, Youness Azimzade, David Molina-García, Juan Belmonte-Beitia, Gabriel F. Calvo, Víctor M. Pérez-García.
**bioRxiv 2020.08.18.255422.** *Submitted to PLOS Computational Biology.* doi: https://doi.org/10.1101/2020.08.18.255422 

    This work is the model's *opera prima*; every aspect of its functionality is detailed in this manuscript. Additionally, the model is used to study the specific case of glioblastoma, in order to validate it and to give a glimpse of what it can do.

* **Universal scaling laws rule explosive growth in human cancers.** Víctor M. Pérez-García, Gabriel F. Calvo, Jesús J. Bosque, Odelaisy León-Triana, Juan Jiménez-Sánchez, Julián Pérez-Beteta, Juan Belmonte-Beitia, Manuel Valiente, Lucía Zhu, Pedro García-Gómez, Pilar Sánchez-Gómez, Esther Hernández-San Miguel, Rafael Hortigüela, Youness Azimzade, David Molina-García, Álvaro Martínez-Rubio, Ángel Acosta Rojas, Ana Ortiz de Mendivil, Francois Vallette, Philippe Schucht, Michael Murek, María Pérez-Cano, David Albillo, Antonio F. Honguero Martínez, Germán A. Jiménez Londoño, Estanislao Arana, Ana M. García Vicente. **Nature Physics 2020.** doi: https://doi.org/10.1038/s41567-020-0978-6

    In this work, a scaling law relating tumor metabolism with volume is unveiled, showing that metabolic consumption increases with volume but at a faster rate. That implies a superlinear growth rate for most human tumors, which in turn leads to a explosion in finite time, when the tumor volume would become infinite if it were not for obvious restraints. The analysis performed over several cohorts of patients with different types of tumors provide enough evidence to support this scaling law. In fact, the superlinear exponent obtained from fitting real patient data to the scaling law has shown prognostic value, so that it can be used in the clinic to provide an estimation of tumor malignancy.
    A earlier version of the mesoscopic model was used in this study to explore this phenomenon. The model helped proposing the hypothesis that is tumor heterogeneity what ultimately lies behind the scaling law. A lowly heterogeneus tumor (which can be modelled as a tumor with only one clonal population) will grow in a sublineal way, giving a scaling law exponent lower than 1, while a highly heterogeneous tumor (modelled as a tumor with more than two clonal populations) will keep a sustained competition between its clonal populations, selecting the most aggressive, and increasing its growth rate in the process. This is what leads to a superlinear growth and a scaling law exponent higher than 1.

* **Evolutionary dynamics at the tumor edge reveals metabolic imaging biomarkers.** Juan Jiménez-Sánchez, Jesús J. Bosque, Germán A. Jiménez-Londoño, David Molina-García, Álvaro Martínez-Rubio, Julián Pérez-Beteta, Carmen Ortega-Sabater, Antonio F. Honguero-Martínez, Ana M. García-Vicente, Gabriel F. Calvo, Víctor M. Pérez-García. **medRxiv 2020.10.06.20204461.** *Submitted to PNAS.* doi: https://doi.org/10.1101/2020.10.06.20204461 

    This work proposes a new biomarker, the NPAC, that measures the distance between a tumor's centroid and its spot of maximum cell activity, normalized by the tumor radius. In short, NPAC goes from 0 to 1, measuring how far the maximum activity spot is placed from tumor centroid: a 0 would indicate that activity is mostly localized at the center, while a 1 would indicate that activity is displaced towards tumor border. NPAC has been studied for two cohorts of patients, one of them with non-small cell lung adenocarcinoma (NSCLC) and another with breast cancer. For both of them, survival analysis revealed that NPAC has prognostic value, and can be used as a measure to provide an estimate of tumor malignancy. The mesoscopic model was used (among others) to comprehensively assess NPAC behaviour in two sets of *in silico* tumors, one of them intending to resemble NSCLC, and the other one resembling breast cancer. It also provided a description of NPAC dynamics during tumor growth, showing that maximum activity spot is displaced towards the tumor border as the tumor grows and increases its heterogeneity. 

## 6. Credits

If you use the mesoscopic model, please cite the following work:

### [**A mesoscopic simulator to uncover heterogeneity and evolutionary dynamics in tumors**](https://www.biorxiv.org/content/10.1101/2020.08.18.255422v1)
Juan Jiménez-Sánchez, Álvaro Martínez-Rubio, Anton Popov, Julián Pérez-Beteta, Youness Azimzade, David Molina-García, Juan Belmonte-Beitia, Gabriel F. Calvo, Víctor M. Pérez-García <br/>
**bioRxiv 2020.08.18.255422** <br/>
doi: https://doi.org/10.1101/2020.08.18.255422 <br/>
*This article is a preprint and has not been certified by peer review yet. It is currently under revision.*   

For any inquiries regarding code usage, or any question related to troubleshooting, please address it to any of the following contributors:
* Juan Jiménez-Sánchez: Juan.JSanchez@uclm.es - *First author*
* Álvaro Martínez-Rubio: alvaro.martinezrubio@uca.es - *First author*
* Gabriel Fernández Calvo: Gabriel.Fernandez@uclm.es - *Principal investigator*
* Víctor M. Pérez-García: Victor.PerezGarcia@uclm.es - *Principal investigator*
