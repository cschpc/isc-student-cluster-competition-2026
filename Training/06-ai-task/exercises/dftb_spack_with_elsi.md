# Installing DFTB+ with Elsi on Mahti

This tutorial walks you through installing DFTB+ with Elsi on Mahti.  
This tutorial assumes that you have Spack installed and sourced.

## First, fixing a bug in the "ntpoly package"

ELSI depends on a library called ntpoly. However, ntpoly currently contains a bug that causes the compilation to fail.  
Modify the ntpoly package accordingly:

```
spack edit ntpoly
```

Add the following line before the existing two dependency lines:

```

```diff
+    depends_on("c", type="build")
     depends_on("cxx", type="build")  # generated
     depends_on("fortran", type="build")  # generated
```

See https://github.com/spack/spack-packages/issues/3788 for details.  
Update, this is now fixed in the development branch of Spack.

## Modules setup

Make sure that your Spack installation has found the following external installations on Mahti.

```
module purge
ml gcc/11.2.0
ml openmpi/4.1.2
ml openblas/0.3.18-omp

spack compiler find
spack external find
spack external find openmpi
spack external find cmake
spack external find openblas
```

We want to use our pre-existing openblas installation to avoid rebuilding it.  
Additionally, we aim to use our system GCC and OpenMPI.

## Installing DFTB+ with Elsi

First verify that Spack correctly detects the external packages and marks them with [e].

To build ELSI successfully on Mahti, we:

- force ScaLAPACK version 2.2.0
- pass the Fortran compiler flag -fallow-argument-mismatch to ELSI

This flag avoids a Fortran type-checking error that occurs with newer compilers.
In older Fortran versions this produced only a warning, but it is now treated as an error.

Additionally, we again target our system OpenBLAS.

```
spack spec dftbplus@24.1 +elsi +mpi +openmp ^openblas@0.3.18 ^netlib-scalapack@2.2.0 ^elsi fflags="-fallow-argument-mismatch"
```

And if all looks good (OpenMPI, GCC, OpenBLAS marked as external), move forward with the installation:

```
spack install -j 8 dftbplus@24.1 +elsi +mpi +openmp ^openblas@0.3.18 ^netlib-scalapack@2.2.0 ^elsi fflags="-fallow-argument-mismatch"
```