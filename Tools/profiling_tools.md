# Profiling tools

# CPU profiling

## Mpitrace 

[MPITrace](https://github.com/IBM/mpitrace) is a simple tool that is aimed at analysis
of distributed-memory parallel applications written with MPI.

MPItrace is easy to install and use, and provides a text based overview of
time spent in MPI calls, number of calls, size of messages etc.

### Installation

```
git clone https://github.com/IBM/mpitrace
cd mpitrace
cd src
export CC=mpicc
./configure
make
```

This creates a shared library `libmpitrace.so`.

Note: libmpitrace need to be build with the same MPI implementation as the
application (e.g. OpenMPI or IntelMPI). If one wants to use mpitrace with
different MPI implementations, a separate version of libmpitrace needs to be
build.

### Usage

In order to use MPITrace, set environment variable `LD_PRELOAD` to the absolute
path of the shared library, *e.g.*
```
export LD_PRELOAD=/scratch/project_2016753/$USER/mpitrace/src/libmpitrace.so
```

When you now run an application, the library collects information about MPI usage,
and writes them out into a set of `mpi_profile.*` files in the directory where
the application is launched. 

By default, a maximumum of three files are produced for the MPI ranks having the minimum, median and maximum communication times. See [documentation](https://github.com/IBM/mpitrace/tree/master/src) for more options for controlling the output. 

## Scalasca

Scalasca is an open-source tool that can be used to measure and analyze parallel program runtime execution and for creating runtime tracing of your program. You can use it for both MPI and hybrid MPI/OpenMP programs.

Scalasca is a run-time tool that can create traces of programs that have been instrumented during their compilation with [Score-P](https://perftools.pages.jsc.fz-juelich.de/cicd/scorep/tags/scorep-7.1/html/).

CSC documentation: https://docs.csc.fi/apps/scalasca/

### Basic usage:

1. Load the right module and compile your source code:
```
module load scorep
scorep mpicc -o my_prog my_prog.c
```

Or, with a program that uses Make/CMake, set your C/C++/Fortran compiler accordingly:

```
CC="scorep mpicc"
FC="scorep mpiftn"
```

2. Run scalasca during the program runtime, by adding the right scalasca commands before your `srun` command:

```
module load scalasca
scan srun ./my_app
```

This collects a flat profile of your program and creates an output file with a prefix `scorep_`.

3. Collect trace data

  - See an estimate of your trace size: `scorep-score -r scorep_my_output_dir/profile.cubex`
  - If the trace is too large, (tens or hundreds of MB) create a basic filter: `scalasca -examine -s -f initial_scorep.filter scorep_my_output_dir/`
  - Check the filter's effect: `scorep-score -f initial_scorep.filter -r scorep_my_output_dir/profile.cubex`
  - Now run the application again, this time specifying a `-t` flag for scalasca, to collect trace data: 
  ```
    module load scalasca

    export SCOREP_FILTERING_FILE=scorep.filter

    scan -q -t srun ./my_app
  ``` 
  - Visualize the output with e.g. Scalasca's analysis report explorer `square`, on your local workstation. See [CSC documentation on Scalasca](https://docs.csc.fi/apps/scalasca/#:~:text=Analysis%20report%20examination,-The) for detail.



