# Processes and threads

## Running hostname

Modify the batch job script template [mahti-example-job-cpu.sh](../mahti-example-job-cpu.sh) so that the
"parallel program" to be executed is `hostname`

Submit the batch job as
```
sbatch job_mahti_cpu.sh
```
and investigate the output with different values for `--nodes`, `--ntasks-per-node`, and `--cpus-per-task`

## Hello world

Compile the parallel "hello world" program [parallel-hello.c](parallel-hello.c) with `make`.
Submit both `hello` and `hello-omp` with different values for `--nodes`, `--ntasks-per-node`, 
and `--cpus-per-task` and investigate the output.

What happens to timings in output if with `hello-omp` one uses more threads than `--cpus-per-task` (i.e. `--cpus-per-task=4` and `OMP_NUM_THREADS=8`) ?

# Using GPUs

In order to use GPUs, one needs to load the `cuda` module:
```
module load cuda
```

Next, modify the batch job script template [mahti-example-job-gpu.sh](../mahti-example-job-gpu.sh) so that the "parallel program" to be executed is `nvidia-smi`. Investigate the output with different combinations of `--ntasks-per-node` and number of GPUs.

