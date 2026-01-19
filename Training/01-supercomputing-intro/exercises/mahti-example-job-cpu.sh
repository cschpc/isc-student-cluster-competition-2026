#!/bin/bash
#SBATCH --account=project_2016753
#SBATCH --job-name=myjob
#SBATCH --time=0:05:00
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=4
#SBATCH --partition=small
#SBATCH --reservation=scc

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

srun my_exe