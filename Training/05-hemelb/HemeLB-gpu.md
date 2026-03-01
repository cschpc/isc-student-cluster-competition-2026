
## Mahti


```
1) gcc/11.2.0   2) openblas/0.3.18-omp   3) csc-tools (S)   4) StdEnv   5) openmpi/4.1.2-cuda   6) boost/1.77.0-mpi   7) python-data/3.10-24.04   8) cmake/3.31.9   9) cuda/11.5.0

```

## Grace-hopper


Grace-hopper on thea system
``` 
 1) cmake/3.31.8_gcc-13.3.0   3) ucx/1.19.0_gcc-13.3.0-cuda_13.0.0      5) boost/1.88.0_gcc-13.3.0  
 2) cuda/13.0.0               4) openmpi/5.0.8_gcc-15.1.0-cuda_13.0.0  
 
```

The above will be specific for the competition machines but make surer to have atleast

- MPI (gpu aware)
- CUDA
- cmake
- python (test that python executable is found)
## BUILD

Download the repo

    git clone https://github.com/UCL-CCS/HemePure.git

System will need mpi and python, found python3 but not python so had to do some config

    ln -s $(which python3) ~/.local/bin/python
    export PATH="$HOME/.local/bin:$PATH"
    
The is done in two sweeps. One for deps and one for source

For deps load as many modules as you can from system e.g. boost


```bash
cmake -DCMAKE_C_COMPILER=mpicc \
      -DCMAKE_CXX_COMPILER=mpic++ \
      -DCMAKE_CUDA_HOST_COMPILER=mpic++ \
	  -DCMAKE_CUDA_COMPILER=nvcc \
      -DHEMELB_GPU_BACKEND=CUDA \
      -DHEMELB_COMPUTE_ARCHITECTURE=NEUTRAL \
      -DCMAKE_CXX_EXTENSIONS=OFF \
      -DHEMELB_USE_VELOCITY_WEIGHTS_FILE=OFF \
      -DHEMELB_INLET_BOUNDARY=NASHZEROTHORDERPRESSUREIOLET \
      -DHEMELB_WALL_INLET_BOUNDARY=NASHZEROTHORDERPRESSURESBB \
      -DHEMELB_OUTLET_BOUNDARY=NASHZEROTHORDERPRESSUREIOLET \
      -DHEMELB_WALL_OUTLET_BOUNDARY=NASHZEROTHORDERPRESSURESBB \
      -DHEMELB_LOG_LEVEL="Info" \
      -DHEMELB_USE_MPI_PARALLEL_IO=OFF \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DHIP_SEPARABLE_COMPILATION=ON \
      -DCMAKE_CUDA_ARCHITECTURES=80
      ..
```

The same ones can be used for deps but it'll just throw a warning that these flags werent used. 

For performance available options 

```bash
# Available options 
-DHEMELB_CUDA_AWARE_MPI=ON # Requires cuda supported mpi (mahti openmpi/4.1.2-cuda)
-DHEMELB_USE_MPI_PARALLEL_IO=ON # Can be tested
```


## Running

Few things to note with PureHeme. 

Input file path needs to be correct otherwise it will throw an MPI error which is quite confusing.

Result folder must not exist when running. Create it dynamically in your submit script `-out results/${SLURM_NNODES}-${SLURM_JOB_ID}`

Need to run with N >= 3 tasks. This is an issue because we require at least 3 tasks to even test our code. Might be difficult on mahti to get that many gpus for quick testing.

One can oversubscribe resources to one gpu but that is a bit tricky and I couldn't get it working

Also I had the code crash constantly when `OMP_NUM_THREADS` was not set to 1.

Note that in your actual batch script you can change `'_EOF_'` and `_EOF_` => `EOF`. This is just for rendering markdown

Note that this is an example script for a test system that has nodes with one GH200 per node. Adjust for target system https://docs.csc.fi/computing/running/creating-job-scripts-mahti/

### On mahti
```bash
#!/bin/bash -l
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=32
#SBATCH --gres=gpu:a100:4,nvme:1000
#SBATCH --partition=gputest
#SBATCH --account=project_2016753
#SBATCH --time=0:10:00
#SBATCH -o ./slurm_output/output%j.txt ## useful for keeping track of output files
#SBATCH -e ./slurm_errors/errors%j.txt  ## useful for keeping track of error files

# --- SYSTEM CONFIGURATION ---
module load cuda openmpi/4.1.2-cuda boost python-data/3.10-24.04

export OMP_NUM_THREADS=1        # Critical: Prevents CPU race conditions during NLookup

change mpirun -> srun and remove binding variables
```

```bash
#!/bin/bash -l
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=36
#SBATCH --partition=gh
#SBATCH --time=0:15:00
#SBATCH --exclusive
#SBATCH -o ./slurm_output/output%j.txt ## useful for keeping track of output files
#SBATCH -e ./slurm_errors/errors%j.txt  ## useful for keeping track of error files

# --- SYSTEM CONFIGURATION ---
module unload cuda
module load python ucx/1.19.0_gcc-13.3.0-cuda_13.0.0 cuda/13.0.0 openmpi/5.0.8_gcc-13.3.0-cuda_13.0.0

# Grace-Hopper Performance & Communication Environment
export CUDA_VISIBLE_DEVICES=$SLURM_LOCALID
export OMP_NUM_THREADS=1        # Critical: Prevents CPU race conditions during NLookup
export UCX_TLS=all             # Enables fastest transport (NVLink/C2C/Shared Mem)
export OMPI_MCA_opal_cuda_support=1  # Enables CUDA-Aware MPI

# --- ARGUMENT HANDLING ---
MODE=${1:-1}
INPUT=${2}
EXE="./HemePure-GPU/src/build/hemepure_gpu"
NUM_NODES=3

# Ensure results directory exists
mkdir -p results

echo "Running in Mode: $MODE"
echo "Input File: $INPUT"

case $MODE in

  1)
    echo "Starting Standard Run ..."
    mpirun -np $NUM_NODES --map-by ppr:1:node:PE=36 --report-bindings \ #just srun on mahti
        $EXE -in $INPUT -out results/${SLURM_NNODES}-${SLURM_JOB_ID}
    ;;

  2)
    echo "Starting Nsight Systems Profile..."
    PROF_DIR="./results/nsys_job${SLURM_JOB_ID}"
    mkdir -p $PROF_DIR

    mpirun -np $NUM_NODES --map-by ppr:1:node:PE=36 --report-bindings \
        nsys profile \
        --trace=cuda,mpi,nvtx,osrt \
        --stats=true \
        --output=${PROF_DIR}/rank%q{OMPI_COMM_WORLD_RANK} \
        $EXE -in $INPUT -out results/${SLURM_NNODES}-${SLURM_JOB_ID}
    ;;

  3)
    echo "Starting Nsight Compute Profile..."
    PROF_DIR="./results/ncu_job${SLURM_JOB_ID}"
    mkdir -p $PROF_DIR

    # To filter by kernel, uncomment the line below and set the regex.
    # KERNEL_FILTER="-k regex:^kernel_name$"
    KERNEL_FILTER="" 

    cat << '_EOF_' > ./ncu_wrapper.sh
#!/bin/bash
if [ "$OMPI_COMM_WORLD_RANK" -eq "0" ]; then
    ncu --set full \
        ${KERNEL_FILTER} \
        --target-processes all \
        --force-overwrite \
        --launch-count 80 \
        -o ${PROF_DIR}/kernel_profile \
        "$@"
else
    "$@"
fi
_EOF_

    chmod +x ./ncu_wrapper.sh

    mpirun -np $NUM_NODES --map-by ppr:1:node:PE=36 --report-bindings \
        ./ncu_wrapper.sh $EXE -in $INPUT -out results/${SLURM_NNODES}-${SLURM_JOB_ID}
    ;;

  *)
    echo "Error: Invalid mode selected. Use 1 (Standard), 2 (nsys), or 3 (ncu)."
    exit 1
    ;;
esac
```

The above script has three modes 1: Default run, 2: Nsight systems (Timeline profile) 3: Nsight compute (GPU profiling memory/compute usage)

Note that the

### GPU mapping and binding with CPU

On mahti it is automatic 1 task per gpu, but on some machines you need to set

	export CUDA_VISIBLE_DEVICES=$SLURM_LOCALID
	
And on others you even need an additional wrapper script because the `$SLURM_LOCALID` is specific to the launched mpi instance via mpirun or srun. For example on lumi

```bash
cat << '_EOF_' > select_gpu
#!/bin/bash

export ROCR_VISIBLE_DEVICES=\$SLURM_LOCALID
exec \$*
_EOF_

chmod +x ./select_gpu

srun <cpu-binding-opt> ./select_gpu <app> <args>
```

Additionally GPUs will have locality to certain CPUs for example on lumi https://docs.lumi-supercomputer.eu/runjobs/scheduled-jobs/distribution-binding/#__tabbed_1_4

but on gracehopper the CPU (grace) and GPU (hopper) exist as pairs so binding should be straight forward. But this is something to keep in mind. Note that they also share unified memory. 

CHECK ROMEO docs https://romeo.univ-reims.fr/documentation/ressources/romeo_2025/utiliser_des_gpu#acc%C3%A9der-aux-gpu-r%C3%A9serv%C3%A9s-dans-votre-job (docs are in french but google translate works)

Seems like mapping is automatic
### Profiling 

run the profiling on the target machine then pull the files to your local machine and view there.

The nsight compute and nsight system need to match the version of the ones on the target machine. 
### CUDA GDB

Sometimes you would like to debug because error messages on gpu mpi code are very cryptic.

How do we run multirank gdb and especially with gpus!


```bash
#!/bin/bash -l
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=36
#SBATCH --partition=gh
#SBATCH --time=0:15:00
#SBATCH --exclusive
#SBATCH -o ./slurm_output/debug_%j.txt
#SBATCH -e ./slurm_errors/debug_%j.txt

module load python ucx/1.19.0_gcc-13.3.0-cuda_13.0.0 cuda/13.0.0 openmpi/5.0.8_gcc-13.3.0-cuda_13.0.0 (change on mahti)

export NV_DEBUG_AGENT_START_TIMEOUT_SEC=120
export CUDA_VISIBLE_DEVICES=0 #(mahti does this automatically I think)
export UCX_TLS=self,sm,cuda_copy,rc #(Should be needed on mahti defines transport layer calls gpu aware mpi)
export OMPI_MCA_opal_cuda_support=1 #(Should be needed on mahti defines transport layer calls gpu aware mpi)
export OMP_NUM_THREADS=1 # Absolutely necessary to set to 1. play with this later but for now set to one

# GDB helper script
cat << '_EOF_' > batch_debug.gdb
set confirm off
catch throw
run
echo \n--- BACKTRACE START ---\n
backtrace
echo \n--- VARIABLE INSPECTION ---\n
info locals
echo \n--- BACKTRACE END ---\n
quit
_EOF_

# Helper script to run run multirank gdb

cat << '_EOF_' > ./debug_wrapper.sh
#!/bin/bash
if [ "\$OMPI_COMM_WORLD_RANK" -eq "0" ]; then
    cuda-gdb -batch -x batch_debug.gdb --args "\$@"
else
    sleep 15
    "\$@"
fi
_EOF_
chmod +x ./debug_wrapper.sh

# --- 4. EXECUTION ---
INPUT=${1} # Pass XML as first argument to sbatch
echo "Launching HemePure-GPU with Automated Rank 0 Debugging..."
echo "Input: $INPUT"

mpirun -np 3 --map-by ppr:1:node:PE=36 --report-bindings \
    ./debug_wrapper.sh ./HemePure-GPU/src/build/hemepure_gpu \
    -in $INPUT \
    -out results/debug_${SLURM_JOB_ID}

# Clean up temporary debug files
rm batch_debug.gdb

```


