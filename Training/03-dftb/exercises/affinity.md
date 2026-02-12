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

