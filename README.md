[![Build Status](https://ci.sagrid.ac.za/job/boost-deploy/badge/icon)](https://ci.sagrid.ac.za/job/boost-deploy/)

# boost-deploy

Build, test and deploy scripts necessary to deploy BOOST C++ library by CODE-RADE

# Versions

  1. 1.62
  2. 1.63

# Dependencies

  * GCC
  * OpenMPI
  * Python
  * ICU
  * readline

# Configuration


##  Bootstrapping

Bootstrapping is done to generate an initial `project-config.jam` file with the required tools:
```
./bootstrap.sh \
--prefix=$SOFT_DIR/${NAME}-${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION} \
--with-toolset=gcc \
--with-python-root=$PYTHON_DIR \
--with-icu=${ICU_DIR} \
--with-libraries=all
```

The MPI bndings are added to the project-config.jam :

```
echo "using mpi ;" >> project-config.jam
```

## Configuration and build

All libraries are built as shared libraries. Some verbosity is added during the build phase.

```
./b2 -d+2 \
threading=multi \
link=static,shared runtime-link=shared,shared \
runtime-link=shared \
--debug-configuration \
-sMPI_PATH=${OPENMPI_DIR} \
-sBZIP2_BINARY=bz2 -sBZLIB_INCLUDE=${BZLIB_DIR}/include -sBZLIB_LIBDIR=${BZLIB_DIR}/lib \
-sPYTHON_PATH=${PYTHONHOME} -sPYTHON_INCLUDE=${PYTHON_DIR}/include -sPYTHON_LIBDIR=${PYTHON_DIR}/lib \
-sICU_PATH=${ICU_DIR} \
--prefix=${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} \
--with-iostreams \
 --with-python \
--with-mpi \
--with-atomic \
--with-chrono \
--with-container \
--with-context \
--with-coroutine \
--with-coroutine2 \
--with-filesystem \
--with-date_time \
--with-exception \
--with-graph \
--with-graph_parallel \
--with-log \
--with-locale \
--with-system  \
--with-math \
--with-program_options \
--with-test --with-thread \
--with-timer \
--with-type_erasure \
--with-wave \
--with-random \
--with-regex \
--with-signals \
--with-serialization
```

# Citing
