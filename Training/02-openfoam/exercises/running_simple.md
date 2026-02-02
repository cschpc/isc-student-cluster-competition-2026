# Running a simulation with OpenFOAM

In this tutorial, we will pre-process, run and visualize a simple OpenFOAM case that simulates a classic lid-driven cavity flow, where fluid in a closed box is driven by the motion of the top wall (see: https://web.mit.edu/calculix_v2.7/CalculiX/ccx_2.7/doc/ccx/node14.html). 

The tutorial largely follows the corresponding OpenFOAM tutorial at: https://www.openfoam.com/documentation/tutorial-guide/2-incompressible-flow/2.1-lid-driven-cavity-flow#x6-60002.1

## First, prepare your environment

Make sure that you have access to the OpenFOAM executables by sourcing it in your `OpenFOAM` folder with `source etc/bashrc`.

If you are still compiling your own OpenFOAM installation or want to use the pre-made one, source the existing installation, and copy the tutorial folder to your working directory, with e.g.:

```
source /projappl/project_2016753/share/OpenFOAM-v2506/etc/bashrc

cp -r /projappl/project_2016753/share/OpenFOAM-v2506/tutorials/incompressible/icoFoam/cavity /scratch/project_2016753/group_xyz
```

Go to the tutorial folder at `tutorials/incompressible/icoFoam/cavity/cavity`.

**Note!** At any point, if you need a clean slate, use the `Allclean` executable in the case directory.

## Creating the mesh

The mesh for the problem is defined in the case's `system/blockMeshDict` file, which in our case defines a cuboid domain.

By default our mesh will consist of a uniform 20x20x1 set of volumes, which corresponds to a quasi-2D square domain with a single cell in the third dimension.

Create the mesh by typing in `blockMesh` in the cavity folder. 

After the blocking is done, check that it finished succesfully with `checkMesh`.

## Visualize the problem domain 

At the beginning, right after creating the mesh, we should check how it looks like.

Visualization in OpenFOAM is done through their tool, `paraFoam`, which requires an installation of paraview.

Paraview is installed on Mahti, and for looking at graphical output, we need to use Mahti's graphical user interface.

1. Go to [mahti.csc.fi](https://mahti.csc.fi) and log in through HAKA
2. Choose a Desktop session with 4 CPU cores and click launch, wait for the session to start
3. Open a terminal in the Mahti desktop session
4. Type in `module load paraview`
5. In the session terminal, source the OpenFOAM installation with `source /projappl/project_2016753/share/OpenFOAM-v2506/etc/bashrc`
6. In the session terminal, go into the training folder that you copied (`/scratch/project_2016753/<your-working-folder>/tutorials/incompressible/icoFoam/cavity/cavity`)
7. Type in `paraFoam` and wait for paraview to initialize
8. Click the green `Apply` button to view the mesh with default settings

At this point you are only viewing the mesh, not the flow field. Velocity and pressure fields will appear only after running the solver.

If all looks good, you can continue into running your simulation. You can leave your Mahti dekstop session open, and return to it after you have run your simulation runs.

## Running the simulation

Go back to your local terminal session, and make sure that you're in the tutorial folder (`/scratch/project_2016753/<your-working-folder>/tutorials/incompressible/icoFoam/cavity/cavity`).

Program runtime parameters are defined the file under `system/controlDict`.
We can leave the parameters as their default values for this test case.

The simulation is very short, and for this simple case, we do not enable parallelism, so a single core run is all that's needed.

Run the program with e.g.

```
srun -N1 -n1 -c1 --account=project_2016753 --time=00:01:00 --partition=small icoFoam
```

Even though this is a serial run, we still use Slurm to ensure the job runs on a compute node and follows system policy.

In this simple example, we do not divide the computational domain into parallel meshes for multiprocessing, so including any more than a single process will only duplicate the same run. In the next example [./benchmarkd.md](benchmark.md), we run a larger scale workload.

## Visualization

Check out how the simulation ran by returning to your desktop session on Mahti, exiting paraview there and opening it again in the tutorial folder with the `paraFoam` command.

Follow the tutorial and apply a stream tracer with the Point Cloud seed type, to visualize how particles behave in the velocity field of the simulated domain.