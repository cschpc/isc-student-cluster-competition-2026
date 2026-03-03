# Homework

- Compile on CPU
- Compile on GPU

## Visualisation and analysis

Go through the visualization and analysis section on the following site and familiarize yourself with hemeXtract and paraview

https://hpcadvisorycouncil.atlassian.net/wiki/spaces/HPCWORKS/pages/3799024424/Getting+Started+with+HemeLB+for+ISC26+SCC+Virtual+Part

## Scaling

The actual input.xml files for the competition aren't out yet on the atlassian website but it is wise to go through the problems which are already posted 

https://hpcadvisorycouncil.atlassian.net/wiki/spaces/HPCWORKS/pages/3799024424/Getting+Started+with+HemeLB+for+ISC26+SCC+Virtual+Part

On this note run some scaling tests with CPUs and figure out a good stress test. At the moment the competition input files aren't available but the cases file might be of interest:

https://github.com/UCL-CCS/HemePure/tree/master/cases

Run some strong scaling benchmarks. 

As a bonus run scaling on GPUs on mahti medium partition

When running scaling benchmarks it is useful to make a wrapper script that submits jobs for example

```
#!/bin/bash
optspec=":b:e:t:c:n:-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        -)
            case "${OPTARG}" in
                name=*)
                    jobname=${OPTARG#*=}
                    ;;
                folder=*)
                    output_folder=${OPTARG#*=}
                    ;;
            esac;;
        b) 
        batchfile=${OPTARG};;
        e) 
        executable=${OPTARG};;
        t) 
        IFS=' ' read -r -a ntasks  <<< ${OPTARG};;
        c) 
        IFS=' ' read -r -a ncores  <<< ${OPTARG};;
        n) 
        IFS=' ' read -r -a nnodes  <<< ${OPTARG};;
    esac
done

if [[ -z "$nnodes" ]]; then nnodes=(1); fi
if [[ -z "$ntasks" ]]; then ntasks=(128); fi
if [[ -z "$ncores" ]]; then ncores=(1); fi
if [[ -z "$batchfile" ]]; then batchfile=$BATCH_FILE; fi
if [[ -z "$executable" ]]; then executable=$EXECUTABLE_FILE; fi
if [[ -z "$jobname" ]]; then jobname=${executable}; fi
if [[ -z "$output_folder" ]]; then output_folder=slurm_output; fi

mkdir -p ${output_folder}

for n in ${nnodes[@]}; do
    for t in ${ntasks[@]}; do
        for c in ${ncores[@]}; do
            sbatch --job-name="${jobname}_${n}_${t}_${c}" --output="./${output_folder}/%x-%j.out" --nodes=$n --ntasks-per-node=$t --cpus-per-task=$c $batchfile $executable
        done
    done
done
```


Lets say you wanted to benchmark intra node scaling with a fully subscribe node, you would run:

    loop_batch.sh -b batch.sh -e "program_to_benchmark -f some_flag" -t 128 -n "1 2 4 8 16" --name="intra_node"
## Profiling 

Run some mpi profiling on the CPU benchmarks. Make note of the behavior you see.

A standard software for this is https://github.com/IBM/mpitrace which is not too hard to compile from source. 

Similarly do the profiling on GPUs. Note that mpitrace works on GPUs and one can execute it on multiple ranks or only one similar to the wrapper scripts for ncu and nsys.

Run profiling with nsys to see trace and behaviour of mpi and execution kernels. 

Optionally you can run ncu but this is a bonus. 





