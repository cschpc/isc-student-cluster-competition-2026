# Process and thread affinity

In this exercise you can investigate how processes and threads are bound to CPU cores and
how various Slurm and OpenMP settings can affect that.

You should be working within the "scratch" directory in Mahti. The project
directories can be found with the `csc-workspaces` command.

1. Go to the project scratch and create a personal directory there:
```
cd /scratch/project_2016753
mkdir -p $USER
cd $USER
```
2. Download a simple affinity test code with `git clone` under your personal scratch space:
```
git clone https://github.com/cschpc/affinity.git
```
3. Build the code along the instructions in the main `README.md` in the repository.
4. Run the code with different combinations of `--ntasks-per-node` and `--cpus-per-task` Slurm settings (with one or two nodes), as well with different settings of `OMP_NUM_THREADS` and `OMP_PLACES` (threads, cores, sockets) environment variables.
    - Test without and with `OMP_PLACES=cores`, what changes?
    - Try asking for more cores with `OMP_NUM_THREADS` than what you allocated with `--cpus-per-bind`, how are threads allocated?
    - Try specifying less cores with OpenMP than what you reserved in Slurm, what happens?
    - Compare the given computation time results

**Note**: It is highly recommended that when you start working on a new HPC system
you investigate how process and thread binding work there.
