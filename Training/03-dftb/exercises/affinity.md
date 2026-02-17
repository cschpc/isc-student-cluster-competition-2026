# Process and thread affinity

In this exercise you can investigate how processes and threads are bound to CPU cores and
how various Slurm and OpenMP settings can affect that.

You should be working within the "scratch" directory in Mahti. The project
directories can be found with the `csc-workspaces` command.

1. Go to the project scratch
```
cd /scratch/project_2016753/$USER
```
2. Download the affinity test code with `git clone` under your personal scratch space:
```
git clone https://github.com/cschpc/affinity.git
```
3. Build the code along the instructions in the main `README.md` in the repository
```
mpicc -o cpu_affinity cpu_affinity.c utilities.c -fopenmp -lm -lnuma
```
4. Follow along the tutorial to inspect how the default task/thread binding on Mahti is like

### Example Slurm run command:

```
srun --time=00:01:00 -N1 --ntasks-per-node=2 --cpus-per-task=2 --account=project_2016753 --partition=small cpu_affinity
```

**Note**: It is highly recommended that when you start working on a new HPC system
you investigate how process and thread binding work there.

## Notes from the training:

### Mahti default settings

On Mahti, when you request MPI processes (`--ntasks-per-node`) and OpenMP threads (`--cpus-per-task`), Slurm spaces the MPI tasks apart so that each task receives a contiguous set of CPU cores that matches the requested amount.  

By default, Mahti does not enable hyperthreading (virtual cores).
This can be adjusted using:

```
--hint=multithread
--hint=nomultithread
```

### OpenMP thread behavior and binding during program runtime

When running an OpenMP program, you specify the amount of threads your program has available to it with the environment variable:

```
OMP_NUM_THREADS
```

If the program is launched using MPI, each MPI task receives its own set of `OMP_NUM_THREADS` cores.

By default in Mahti's Slurm settings, these threads are not bound to a specific core. Instead, they can migrate between the set of cores available to them.

### Controlling thread placement

You can restrict where threads may run using the OpenMP runtime variable:

```
OMP_PLACES=cores
```

This assigns each thread only to a single core and reduces context switching.

Thread binding can then be enforced with:

```
OMP_PROC_BIND=true
```

`OMP_PLACES` defines the allowed locations, while `OMP_PROC_BIND` controls whether the threads remain fixed in those locations during execution (if there are multiple places to choose from).

### Memory binding 

You can check how by default memory is bound with the following command:

```
[sarastel@mahti-login12 affinity]$ srun --time=00:01:00 -N1 --ntasks-per-node=1 --account=project_2016753 --partition=small numactl --show
srun: job 5988715 queued and waiting for resources
srun: job 5988715 has been allocated resources
policy: default
preferred node: current
physcpubind: 114 
cpubind: 7 
nodebind: 7 
membind: 0 1 2 3 4 5 6 7 
```

We see that memory can be allocated from any NUMA domain (membind: 0-7).
Linux will typically use the closest NUMA domain first (first-touch policy). However, if you want to explicitly bind it, you can utilize Slurm's `--mem-bind` option:

```
[sarastel@mahti-login12 affinity]$ srun --time=00:01:00 -N1 --ntasks-per-node=1 --account=project_2016753 --partition=small --mem-bind=local numactl --show
srun: job 5988725 queued and waiting for resources
srun: job 5988725 has been allocated resources
policy: bind
preferred node: 1
physcpubind: 26 
cpubind: 1 
nodebind: 1 
membind: 1 
preferred: 1
```

Now memory is pinned to the NUMA domain local to the CPU core.

## Performance implications:

Often, with HPC applications running on a full node, or multiple nodes, it will be beneficial to bind MPI processes and OMP threads to specific cores during runtime. It's recommended to test out different configurations to find out an optimal one.

Before running DFTB+, run the affinity code with your intended Slurm options first to see how your cores will be allocated. This will be especially important on the ROMEO system, as we do not know the default behavior there.

If a program runs entirely inside one NUMA domain, it benefits from lower memory latency.

However:
- Remote NUMA access occurs when the domain capacity is exceeded
- Memory bandwidth is not maximized, since only a subset of DIMMs and memory lanes are used

Optimal placement depends on the workload and should be investigated for your given application.

A common configuration is to assign one MPI task per NUMA domain and use OpenMP threads to occupy the cores within that domain. 
This allows each MPI task (and its threads) to primarily access memory local to its NUMA domain. Using threads within the domain also reduces the total number of MPI ranks, which can decrease communication overhead and improve scalability.

In Mahti, the default behavior achieves this when using a full node (8 NUMA domains, each with 16 cores):

```
OMP_NUM_THREADS=16 srun --time=00:01:00 -N1 --ntasks-per-node=8 --cpus-per-task=16 --account=project_2016753 --partition=test cpu_affinity | sort
```

## Examples:

Test out some default binding policies on a full Mahti node:

1. Example job with 4 MPI tasks and 4 threads per task, with a full Mahti node reserved (test partition):

```
OMP_NUM_THREADS=4 srun --time=00:01:00 -N1 --ntasks-per-node=4 --cpus-per-task=4 --account=project_2016753 --partition=test cpu_affinity | sort
```

2. The same command but with `OMP_PLACES` set to cores, limiting their possible places to a single core:

```
OMP_PLACES=cores OMP_NUM_THREADS=4 srun --time=00:01:00 -N1 --ntasks-per-node=4 --cpus-per-task=4 --account=project_2016753 --partition=test cpu_affinity | sort
```

3. The same can be achieved with the `OMP_PROC_BIND` command, which binds the cores in place during their runtime:

```
OMP_PROC_BIND=true OMP_NUM_THREADS=4 srun --time=00:01:00 -N1 --ntasks-per-node=4 --cpus-per-task=4 --account=project_2016753 --partition=test cpu_affinity | sort
```

4. Investigate the interplay between setting the OpenMP environment variable `OMP_NUM_THREADS` and Slurm's `--cpus-per-task` parameter:
  - What happens if you specify more threads in `OMP_NUM_THREADS` environment variable than in the `--cpus-per-task` parameter? 
  - What happens when you specify less threads in `OMP_NUM_THREADS` than in `--cpus-per-task`?

## Links and manuals:

- [Slurm parameters (--cpus-per-task, --distribution, etc.)](https://slurm.schedmd.com/sbatch.html)
- [OMP_PLACES](https://www.openmp.org/spec-html/5.0/openmpse53.html)
- [OMP_PROC_BIND](https://www.openmp.org/spec-html/5.0/openmpse52.html)
- [numactl](https://linux.die.net/man/8/numactl) (or just use `man numactl` or `numactl --help`)