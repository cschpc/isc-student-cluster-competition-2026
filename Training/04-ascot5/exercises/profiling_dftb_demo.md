# Profiling DFTB+ with libmpitrace on Mahti

In this demo, we will run libmpitrace on our DFTB+ installation on Mahti.

## Preparing libmpitrace

Go to your working directory, e.g.:

```
cd /scratch/project_2016753/$USER
```

Clone and install libmpitrace:

```
git clone https://github.com/IBM/mpitrace
cd mpitrace
cd src
export CC=mpicc
./configure
make
```

This creates a shared library `libmpitrace.so`.

Define the following environment variable so that your MPI runs in this terminal session will use libmpitrace during their execution:

```
export LD_PRELOAD=/scratch/project_2016753/$USER/mpitrace/src/libmpitrace.so
```

Or, if you installed libmpitrace elsewhere, modify the path accordingly.

## Running DFTB+

Load the right modules, and run DFTB+ as normal, by following, e.g. the demo (modify the paths accordingly, to your parameter file and your dftb+ installation):

```shell
module purge
module load gcc/14.2.0 openmpi/5.0.6
module load openblas/0.3.28-omp netlib-scalapack/2.2.0
cd /scratch/project_2016753/$USER/SiC.0064

OMP_NUM_THREADS=1 DFTBPLUS_PARAM_DIR=../ srun --time=00:05:00 -N1 --ntasks-per-node=2 --cpus-per-task=1 --account=project_2016753 --partition=small ../dftb+/bin/dftb+
```

In the above example, we run the example case with two MPI tasks and one OpenMP threads per task.

## Analysis

After the run has finished, libmpitrace will create at maximum three output files (`mpi_profile.*`), matching the processes that spend the:

  - Maximum time in communication
  - Median time in communication
  - Minimum time in communication

Analyze the files to identify the most numerous MPI calls during execution, and the ones that take up most time in terms of the wall clock time of the execution.

## Seff command

Try also Slurm's `seff` command to see some other basic runtime information of your program:

```shell
# See past jobs
sacct

seff <jobid>
```

By default on Mahti, Slurm is set up to gather usage statistics every 60 seconds (+ at job termination), so the results are not very representative on short jobs.
