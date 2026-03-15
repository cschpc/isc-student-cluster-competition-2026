# Installing MaxText

## Complications with the installation

MaxText's [official installation instructions](https://maxtext.readthedocs.io/en/latest/install_maxtext.html#from-pypi-recommended)
do not tell the whole story for of the installation.

If you try to install MaxText using those instructions you quickly run into
problems because MaxText depends on NVIDIA's
[Transformer Engine](https://github.com/NVIDIA/TransformerEngine) and
its JAX backend `transformer-engine-jax`.

This package contains various optimizations for transformer layers in deep
networks.

However, during its installation the JAX backend requires a C++ compiler
and CUDA toolkit to be present so that it can build kernels for the layers.

MaxText itself is built with CUDA 12, which is installed from PyPI. This
CUDA toolkit does not provide necessary files for compiling custom CUDA
kernels, so we need to get these from somewhere else. In addition, the
CUDA version installed in the environment needs to be similar in version.

This means that for the installation to work we need an environment with those
available. We can use conda to provide such an environment.

## Creating a MaxText container in Mahti

To create the container we'll use [Tykky](https://docs.csc.fi/computing/containers/tykky/).

We could create the environment as a normal Conda environment, but that would
create a huge number of files, so we'll use Tykky instead.

To create the container run:
```console
sinteractive --account project_2016753 --time 1:00:00 --cores 8 --tmp 60
module load tykky
export MAXTEXT_PREFIX=/scratch/project_2016753/$USER/maxtext_env
mkdir $MAXTEXT_PREFIX
conda-containerize new --prefix $MAXTEXT_PREFIX --mamba --post-install post-install.sh environment.yml
```

This does the following:

1. Creates a new container into `$MAXTEXT_PREFIX`
2. Instructs the builder to utilize mamba for the build process (mamba is
   a faster installer for conda packages)
3. Instructs the builder to run actual MaxText installation in a post-install
   hook that installs the packages using uv.
4. Instructs the builder to use `environment.yml` as a 
   specification for the base packages.

To activate the environment, run
```console
export MAXTEXT_PREFIX=/scratch/project_2016753/$USER/maxtext_env
export PATH="$MAXTEXT_PREFIX/bin:$PATH"
```

## Exercise

1. Install MaxText.
2. Run `pip list` and check what packages are installed.
