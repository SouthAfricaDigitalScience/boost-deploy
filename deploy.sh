#!/bin/bash -e
. /etc/profile.d/modules.sh
module add deploy

# add the dependency modules for the deploy
module add bzip2
module add readline
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module add python/2.7.13-gcc-${GCC_VERSION}
module add  icu/1_59-gcc-${GCC_VERSION}
REMOTE_VERSION=`echo ${VERSION} | sed "s/\\./\_/g"`

cd ${WORKSPACE}/${NAME}_${REMOTE_VERSION}/
echo "Cleaning"
./b2 --clean
echo "Starting deploy build"
./b2 -d+2 install \
threading=multi \
link=static,shared runtime-link=shared,shared \
runtime-link=shared \
--debug-configuration \
-sMPI_PATH=${OPENMPI_DIR} \
-sBZIP2_BINARY=bz2 -sBZLIB_INCLUDE=${BZLIB_DIR}/include -sBZLIB_LIBDIR=${BZLIB_DIR}/lib \
-sPYTHON_PATH=${PYTHONHOME} -sPYTHON_INCLUDE=${PYTHON_DIR}/include -sPYTHON_LIBDIR=${PYTHON_DIR}/lib \
-sICU_PATH=${ICU_DIR} \
--prefix=${SOFT_DIR}/${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION} \
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

echo "Creating module"
mkdir -p ${LIBRARIES}/${NAME}
# Now, create the module file for deployment
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module add bzip2
module  add  readline
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module add python/2.7.13-gcc-${GCC_VERSION}
module add icu/1_59-gcc-${GCC_VERSION}
module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/${name}-deploy"
setenv BOOST_DIR $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$::env(NAME)/$::env(VERSION)/$::env(VERSION)-mpi-$::env(OPENMPI_VERSION)-gcc-$::env(GCC_VERSION)
setenv BOOST_ROOT                      $::env(BOOST_DIR)
setenv BOOST_VERSION                $::env(VERSION)
prepend-path CFLAGS                     "-I$::env(BOOST_DIR)/include -L$::env(BOOST_DIR)/lib"
prepend-path PATH                          $::env(BOOST_DIR)/bin
prepend-path LD_LIBRARY_PATH  $::env(BOOST_DIR)/lib
MODULE_FILE
) > ${LIBRARIES}/${NAME}/${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module avail ${NAME}
module add ${NAME}/${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION}
echo "LD_LIBRARY_PATH is : ${LD_LIBRARY_PATH}"
which g++
cd ${WORKSPACE}
echo "BOOST DIR is ${BOOST_DIR} ; SOFT_DIR is ${SOFT_DIR}"
ls -lht ${BOOST_DIR}
c++ -I${BOOST_DIR}/include -L${BOOST_DIR}/lib hello-world.cpp
./a.out
