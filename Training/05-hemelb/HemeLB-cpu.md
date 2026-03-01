
## Build and compile

System will need mpi and python 

on mahti used default modules and default system python:

```
module list

Currently Loaded Modules:
  1) gcc/11.2.0   2) openmpi/4.1.2   3) openblas/0.3.18-omp   4) csc-tools (S)   5) StdEnv   6) boost/1.77.0-mpi

```

Download the repo

    git clone https://github.com/UCL-CCS/HemePure.git
    
Follow installation instructions on github

Code is built in two stages. First the dependencies and then the src. Note that HemePure ships with it's dependencies but if they are available on the machine then use those.

There is a single execution script `FullBuild.sh` but this cause me some headaches. Easier was to do it in separate steps

In both steps I didn't trust cmake to find the correct compiler so I specificed

`cmake  -DCMAKE_C_COMPILER=mpicc   -DCMAKE_CXX_COMPILER=mpic++ ..`


## Running 

Input file path needs to be correct otherwise it will throw an MPI error which is quite confusing.

Result folder must not exist when running. Create it dynamically in your submit script `-out results/${SLURM_NNODES}-${SLURM_JOB_ID}`

Need to run with N >= 3 tasks. 

