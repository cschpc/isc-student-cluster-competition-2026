# MaxText profiling

## MaxText and JSON profiling

MaxText can produce metrics in a JSON format.

This is enabled by setting `metrics_file=path/to/file.json`
in a config or from the command line.

## MaxText and TensorBoard

MaxText can also log metrics via TensorBoard.
[TensorBoard](https://www.tensorflow.org/tensorboard) was originally
built for with TensorFlow in mind, but it is commonly used to visualize
PyTorch and Jax models as well.

You can use [CSC's Tensorboard app](https://docs.csc.fi/computing/webinterface/tensorboard/) to visualize the results.

To enable TensorFlow metrics in MaxText, set `enable_tensorboard=true`.

## Exercise

1. Profile a MaxText run with both JSON and TensorBoard outputs. Run for slightly longer (e.g. 50 steps).

<details>
    <summary>Solution:</summary>
```sh
#!/bin/bash
#SBATCH --time=00:15:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=4
#SBATCH --partition=gputest
#SBATCH --gres=gpu:a100:1
#SBATCH --account=project_2016753
#SBATCH --output=maxtext_profiling.out

# Set variables

## Environment path
MAXTEXT_ENV=/scratch/project_2016753/$USER/maxtext_env

## Outputs path
MAXTEXT_OUTPUTS=$PWD/maxtext_outputs


# Pre-run setup

## Activate environment
export PATH="$MAXTEXT_ENV/bin:$PATH"

## Create output directory for tensorboard
mkdir -p $MAXTEXT_OUTPUTS


# Run maxtext
cd maxtext

srun python3 -u -m maxtext.trainers.pre_train.train src/maxtext/configs/base.yml \
  run_name=maxtext-profiling \
  base_output_directory=$MAXTEXT_OUTPUTS \
  dataset_type=synthetic \
  steps=50 \
  enable_tensorboard=true \
  metrics_file=$MAXTEXT_OUTPUTS/maxtext-profiling.json \
```
</details>

2. Visualize metrics using CSC's TensorBoard app.
