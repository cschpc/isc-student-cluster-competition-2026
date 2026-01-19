#!/bin/bash
#SBATCH --account=project_2016753
#SBATCH --job-name=myjob
#SBATCH --time=0:05:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:a100:4
#SBATCH --partition=gputest

srun my_exe