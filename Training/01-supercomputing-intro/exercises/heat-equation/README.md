# Heat equation

In this exercise we are working with a simple code which solves in three dimensional heat equation in
parallel. Start by cloning the repository:
```
git clone https://github.com/cschpc/heat-equation.git
```

## CPU version

Use the version utilizing both MPI and OpenMP:
```
cd 3d/mpi-openmp
```

Build the code:
```
make
```

Run the code in batch job with different combination of MPI tasks and OpenMP threads, and
investigate which gives the best performance. Try e.g. 1, 2, and 4 threads so that total amount
cores to per node is 128.

What is the speed-up when scaling from one node to two nodes?

## GPU version

In Mahti, one can use the CUDA version of the code `3d/cuda`. Note in order to compile the
code, the `cuda` module needs to be loaded, as well as CUDA aware MPI `openmpi/4.1.2-cuda` module.

Try to run the code with different number of GPUs per node and both with one or two nodes.
Investigate parallel scalability. How is the performance compared to CPU version?


