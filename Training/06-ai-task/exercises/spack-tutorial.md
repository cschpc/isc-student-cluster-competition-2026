# Installing DFTB+ with Spack

General Spack documentation can be found at: https://spack.readthedocs.io

In this tutorial, you will be installing Spack and DFTB+ (without Elsi!) on Mahti. Please note that compiler versions, external libraries etc. might differ on different systems.

Spack will install packages in a `spack` folder, and the config files under a `.spack` folder, by default.

## Installing and configuring Spack

Clone spack:
```
git clone -c feature.manyFiles=true --depth=2 https://github.com/spack/spack.git
```

By default, Spack will install everything into the cloned folder, and the config file for your Spack installation will be under your home folder. DFTB+ installation will take about a GB of space.

Activate shell support (for bash):
```
. spack/share/spack/setup-env.sh
```

**If** you want to have Spack always available you can do something like:
```
echo ". " `realpath spack/share/spack/setup-env.sh` >> $HOME/.bashrc
```

Find compilers and external system packages:
```
spack compiler find
spack external find
```

Here, the external system packages are packages that are native on that system, and Spack can use them out-of-the-box, without needing to install them. Note, that it might look for these in the `/usr` space. If you decide to compile on a compute node, make sure that those nodes also have these packages available (Mahti's compute nodes do not!). 

Finding additional compilers and libraries may require loading additional modules:
```
module load cmake
spack external find
```
Note: once a compiler is known to spack, modules are no longer needed for
using it.

Spack can install all dependencies of a software (including MPI), but normally
one wants to use readily available MPI installations. For this, we need to
tell spack to use "external" MPI installation (the above `external find` added
already some system packages as externals). 

The default external find did not find our openmpi installation. Look for it explicitly with:

```
spack external find openmpi
```

Another way to (manually) edit configuration is via
Spack's own command line tools. In order to edit "packages" configuration use:

```
spack config edit packages
```

If the above command did not find openmpi, you could add the specification for external OpenMPI to the end of `packages.yaml`
file yourself. The prefix where e.g. openmpi has been installed, can be found with `module show
openmpi`):
```
  openmpi:
    externals:
    - spec: openmpi@4.1.2 %gcc@11.2.0
      prefix: /appl/spack/v017/install-tree/gcc-11.2.0/openmpi-4.1.2-h6c3ze
    buildable: False
```       

Spack can also generate modules, but in order to make them usable requires quite a bit
of additional configuration, so we will skip it for time being.

## Before installing DFTB+

## My setup

For my installation, I'm using Mahti's default GCC and OpenMPI, as well as the system netlib-scalapack and openblas.

Download these modules and pass them to Spack:

```
module purge
module load gcc/11.2.0
module load openmpi/4.1.2
module load openblas/0.3.18-omp
spack external find openmpi
spack external find openblas
```

## Installing DFTB+

Move on to installing DFTB+. 

Check if Spack has a DFTB+ package:
```
spack list dftb
```

See DFTB+ versions and variants known by Spack:
```
spack info dftbplus
```

You see that the default version is 24.1., which is the one requested at the SCC task.  
You can also see, that MPI parallelization and OpenMP threading are disabled by default. Similarly, Elsi is disabled by default.

You can see exactly what packages the default installation would include by using Spack's spec operation:

```
spack spec dftbplus
``` 

In our case, however, we want to enable MPI and OpenMP. We also want Spack to specifically use our existing GCC compilers (11.2.0), OpenMPI (4.1.2) and OpenBLAS (0.3.18). 

If you ran the external find commands for all of these above, then Spack should find and use them automatically.  
Thus, our Spack installation script should become:

```
spack spec dftbplus@24.1 +mpi +openmp
```

If any of these are not marked as external [e] for you, you can explicitly ask for their versions:


```
spack spec dftbplus@24.1 +mpi +openmp %gcc@11.2.0 ^openmpi@4.1.2 ^openblas@0.3.18
```

Before you continue, **make sure that the system OpenMPI, OpenBLAS and GCC are marked as externals [e].** We don't want to install these ourselves to save time during the building process. 

Now, if you agree with the spec output, you can finally install seissol together with the dependencies
for the specified variant:
```
spack install -j 4 dftbplus@24.1 +mpi +openmp
```    

The installation step can take a long time (~1 hour with 4 cores), so using `tmux` might be sensible here.  
To compile using multiple cores, use the `-j <n_cores>` flag during installation.

Once the installation completes, we have the binaries in the installation
directory
`.../spack/opt/spack/linux-x86_64_v3/dftbplus-24.1-.../bin/`

## Running the Spack installed version

In principle, we can just use the full path to the binaries to now run DFTB+, or add manually
the installation directory to `$PATH`. Spack provides similar mechanisms as
`module`, *i.e.* "load" / "unload", so using this, we can do:

```
spack load dftbplus
```

which adds the installation directory to `$PATH` for us.

## Additional steps and tuning

At the installation step, you could also enable GPU support through the use of Magma (`+gpu`). See `spack info dftbplus`.

Additionally, you should test performance with Elsi, since it's a pre-requisite for the SCC tasks.  
To get Elsi working on Mahti with Spack, it needs some tuning, see [./dftb_spack_with_elsi.md](./dftb_spack_with_elsi.md) for this.
