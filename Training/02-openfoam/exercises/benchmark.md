# Running a larger OpenFOAM simulation on Mahti

In this tutorial, we will run an OpenFOAM case that is computationally more demanding.  
We will run it purely with MPI tasks, as the interFoam solver does not utilize OpenMP threading.

The default case is a coarse setup, so we will aim to make it finer, producing more accurate results, but also requiring much more computational power. We make an extremely fine grain mesh, that will provide us with comparable results for studying the case's scaling properties.

The tutorial is based on, and largely follows, the OpenFOAM tutorial at https://www.openfoam.com/documentation/tutorial-guide/4-multiphase-flow/4.1-breaking-of-a-dam.

## The case

We are simulating a two-dimensional square domain, where there is a solid object, or a dam, in the bottom middle of the domain.

A water column is initialized to one end of the computational domain which, when broken free, rushes to the dam and simulates the breaking/overflowing effects that happen. 

## First, initialize your settings and copy the tutorial files

The tutorial is located in OpenFOAM's directory `tutorials/multiphase/interFoam/laminar/damBreak/damBreak`. If you are still compiling your own OpenFOAM installation or want to use the pre-made one, source the existing installation, and copy the tutorial folder to your working directory, with e.g.:

```
source /projappl/project_2016753/share/OpenFOAM-v2506/etc/bashrc

cp -r /projappl/project_2016753/share/OpenFOAM-v2506/tutorials/incompressible/icoFoam/cavity /scratch/project_2016753/<your-group-folder>
```

At any point, if you need to get a clean slate, clean the copied folder with the `Allclean` command in the case directory.

## Setting up the case

This time, we want to change the mesh a little to make it finer than the default settings. Use a text editor to change the file `system/blockMeshDict`, and change the `blocks` section (lines 47-54) there into the following:

I suggest working in pairs, where one person changes the mesh into a finer mesh, and the other uses the default (coarse) mesh.

```
blocks
(
    hex (0 1 5 4 12 13 17 16) (138 30 1) simpleGrading (1 1 1)
    hex (2 3 7 6 14 15 19 18) (120 30 1) simpleGrading (1 1 1)
    hex (4 5 9 8 16 17 21 20) (138 228 1) simpleGrading (1 2 1)
    hex (5 6 10 9 17 18 22 21) (12 228 1) simpleGrading (1 2 1)
    hex (6 7 11 10 18 19 23 22) (120 228 1) simpleGrading (1 2 1)
);
```

Here, we create a much finer mesh for our simulation. This will lead to more computational cost but with added accuracy.  

Now we can create it by running the `blockMesh` command.

## Visualizing our problem domain and mesh resolution

Again, before running the problem, it is a good idea to check the mesh in paraview, to see that everything looks okay.

## Setting up the initial conditions

The initial state of the simulation is read by OpenFOAM from a folder `0`. Let's create this by copying the `0.orig` folder into `0`, with:

```
cp -r 0.orig 0
```

This way you also save the original settings of the case.

In our case, we now need to also specify an initial condition for the water phase fraction in our domain. We can achieve this by running OpenFOAM's `setFields` command.

The `setFields` command reads the field from a file (`0/alpha.water`) to determine our initial condition, and will overwrite that file.

We can leave the `controlDict` file as default for now, but different parameters you could change there include e.g.:
- endTime
- deltaT
- writeInterval

## Designing the process MPI decomposition

For the coarse case, you can skip this step, as the case runs very well without any parallelization. However, for the fine-grain case, the job can take up to an hour sequentially, so parallelization is recommended.

The problem area needs to be divided into subdomains to enable parallelism in OpenFOAM. To achieve this, we need to specify our subdomain numbers in the file `system/decomposeParDict`.

Try running OpenFOAM with either 16, 32 or 64 processes. Change the parameter `numberOfSubdomains` accordingly, and set up the section:

```
coeffs
{
    n           (x y z);
}
```

To match that. There, we specify how many domains we split our case into in the x, y and z directions. Our case is two-dimensional, so the z direction should always be 1.

Run the utility command `decomposePar`, to decompose our problem domain into the number of subdomains we specified.

## Running the case

Finally, we can run the case through Slurm. Run it with the amount of processes you chose earlier with e.g.:

```
#!/bin/bash
#SBATCH --job-name=example
#SBATCH --account=project_2016753
#SBATCH --partition=small
#SBATCH --time=00:20:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=<number-of-processes>

srun interFoam -parallel
```

Notice the `-parallel` flag at the end. Without it, you would be launching OpenFOAM serially `-n` times.

While your program is executing, you can check the latest output by the `tail` command on the output file.

After running, reconstruct your subdomains into one with `reconstructPar`.

## Visualization

Open again a desktop session in mahti.csc.fi.  
Source your openfoam installation, go to your tutorials folder and type in `paraFoam`.

Inspect the parameters `p`, `U` and `alpha.water`. What do these represent? What is the difference between visualizing the `U` parameter's different aspects (Magnitude, x, y and z)

