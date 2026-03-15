# Testing MaxText

## Decoupling MaxText from Google Cloud

MaxText is heavily designed around Google Cloud, but it can also be run
without those features.

This is done by [running the code in decoupled mode](https://maxtext.readthedocs.io/en/latest/run_maxtext/decoupled_mode.html):

```sh
export DECOUPLE_GCLOUD=TRUE
```

## Getting example configurations

MaxText's runs are configured using
[OmegaConf](https://omegaconf.readthedocs.io/en/latest/index.html)
configurations.

You can browse configurations and view their documentation
[here](https://github.com/AI-Hypercomputer/maxtext/tree/main/src/maxtext/configs).

A lot of these configurations are available in MaxText's repository. Some of the
configuration parameters have been modified in the main branch, so we'll need
to checkout an older version of the repository.

We're running MaxText v0.2.0 so lets checkout that tag from the repository:

```console
git clone https://github.com/AI-Hypercomputer/maxtext.git
cd maxtext
git checkout maxtext-v0.2.0
```

When launching MaxText you can pass it a path to configuration file that it
should use.

## Testing the MaxText installation

Let's adapt the
[example run provided in the MaxText documentation](https://maxtext.readthedocs.io/en/latest/tutorials/first_run.html#run-maxtext-on-nvidia-gpus)
to run on Mahti.

For this we'll need to look a CSC's documentation on running
[GPU jobs](https://docs.csc.fi/computing/running/creating-job-scripts-mahti/#gpu-batch-jobs).

## Exercise 1

1. Create a submission script that runs the example script. Running the example script will take a few minutes on a single GPU.

<details>
    <summary>Hints:</summary>

- Create a sbatch script with requirements for time, memory, cpus-per-task and gpus.
- Activate the installed maxtext env in the script.
- Create a output folder for the model checkpoints.
- Run `python` commands while in MaxText's repository.
- Use `srun` to launch MaxText.
- Modify run's name.
- Modify output paths to a proper place.
- Pass configuration file `src/maxtext/configs/base.yml` to MaxText launches.

</details>

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
#SBATCH --output=maxtext_test.out

# Set variables

## Environment path
MAXTEXT_ENV=/scratch/project_2016753/$USER/maxtext_env

## Outputs path
MAXTEXT_OUTPUTS=$PWD/maxtext_outputs

## Disable Google Cloud integration in maxtext
export DECOUPLE_GCLOUD=TRUE


# Pre-run setup

## Activate environment
export PATH="$MAXTEXT_ENV/bin:$PATH"

## Create output directory
mkdir $MAXTEXT_OUTPUTS


# Run maxtext
cd maxtext

srun python3 -u -m maxtext.trainers.pre_train.train src/maxtext/configs/base.yml \
  run_name=maxtext-test \
  base_output_directory=$MAXTEXT_OUTPUTS \
  dataset_type=synthetic \
  steps=10

srun python3 -m maxtext.inference.decode src/maxtext/configs/base.yml \
  run_name=maxtext-test \
  base_output_directory=$MAXTEXT_OUTPUTS \
  per_device_batch_size=1
```

</details>
