# SCC Training 01 - Basics of supercomputing and compiling of applications

Date 19.1.2026  
At CSC - Keilaniemi
- Arrival instructions: https://csc.fi/en/about-us/contact-information/#espoo-directions-and-accessibility

Slides: https://kannu.csc.fi/s/zbgGj6kHqi5ySjb?dir=/01-supercomputing-intro

## Agenda

|Time|Topic|
|---|---|
|13:00|Training and competition schedule|
|13:15|Background for supercomputing, compiling|
|14:30|Coffee break|
|15:00|Machine hall visit|
|15:30|Hands-on exercises|

## Hands-on exercises

Before you get started, walk through the [general_instructions.md](general_instructions.md) file.

See e.g. [CSC User Documentation](https://docs.csc.fi/computing/running/example-job-scripts-mahti/#mpi-openmp)
for examples of Slurm batch job scripts. For this particular training a set of nodes has been reserved, the reservation can be used with `--reservation=scc` option in Slurm:
```
sbatch --reservation=scc my_job_script.sh
```

- [Parallel hello world](exercises/parallel-hello/README.md)
- [Heat equation](exercises/heat-equation/README.md)


## Homework

- Attend the Aalto HPC winter school 28.1.  
- Look through the competition applications and discuss with your teammates on what the preliminary task division could be
