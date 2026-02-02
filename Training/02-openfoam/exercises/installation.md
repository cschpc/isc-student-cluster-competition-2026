# SeisSol (manual) build instructions

The instructions are based on OpenFOAM's build instructions available at: https://develop.openfoam.com/Development/openfoam/blob/develop/doc/Build.md

The aim is to download and compile OpenFOAM v2506. OpenFOAM is a very large installation, so we will compile it in Mahti's local SSD disk for faster progress.

To save login node resources, we will work in groups of three today, where only one installation per group should be done.

## Pre-requisites

Some dependencies mentioned in [OpenFOAM's documentation](https://develop.openfoam.com/Development/openfoam/blob/develop/doc/Requirements.md) are found as modules on Mahti. These include:

- The GNU compiler suite (>7.5.0)
- cmake (>3.8)
- boost (>1.48)
- fftw (>3.3.7)
- scotch
- Paraview (for visualization of results)

The OpenMPI on Mahti is version 4.1.2 (check e.g. with `ompi_info`), which works well with OpenFOAM.

Enable the modules with:

`module load gcc/11.2.0 openmpi/4.1.2 cmake boost/1.77.0-mpi fftw/3.3.10-mpi scotch/6.1.1`

## Fetch the source code

Go to your working directory, e.g. `/scratch/project_2016753/$USER/openfoam` and download the latest OpenFOAM (v2506):

```
wget https://dl.openfoam.com/source/v2506/OpenFOAM-v2506.tgz
```

Untar the file into Mahti's local disk $TMPDIR:

```
tar -xzf OpenFOAM-v2506.tgz -C "$TMPDIR"
```

Go to the directory with `cd $TMPDIR/OpenFOAM-v2506` and source the environment with `source etc/bashrc`. You might get a bash error at the end of the file (due to a bash version specific issue), but the sourcing should still go through.

Make sure that the sourcing was a success by typing `foamSystemCheck`, if you get a PASS, you can continue to compiling OpenFOAM.

## Compiling OpenFOAM 

Make sure you have the environment loaded and that you are in the correct folder by typing `foam`.

If you want your installation to support multithreading, specify the following environment variable: 

```
export WM_COMPILE_CONTROL="+openmp"
```

Without this, you can only run OpenFOAM with MPI. 

Build OpenFOAM with 6 CPU cores with the command `./Allwmake -s -l -j6`

## Waiting

OpenFOAM is *extremely* slow to compile, you can let it run in the background during the training.  
If/when you end up compiling more often, I highly recommend getting used to using tmux for managing workflows on a supercomputer, which allows you to close your connection while waiting for the compilation to finish.

See e.g. [https://www.redhat.com/en/blog/introduction-tmux-linux](https://www.redhat.com/en/blog/introduction-tmux-linux). 

## After installing

After the compilation has finished, copy the folder back to your working directory (e.g. `rsync -a --info=progress2,name0,stats1 $TMPDIR/OpenFOAM-v2506 /scratch/project_2016753/team_xy/`).

Remove any files you have left in `$TMPDIR`. (e.g. `rm -fr $TMPDIR/OpenFOAM-v2506`)