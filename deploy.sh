#!/bin/bash -e
. /etc/profile.d/modules.sh
module add deploy

# add the dependency modules for the deploy
module add bzip2
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module add python/2.7.13-gcc-${GCC_VERSION}
REMOTE_VERSION=`echo ${VERSION} | sed "s/\\./\_/g"`

cd ${WORKSPACE}/${NAME}_${REMOTE_VERSION}/
echo "Cleaning"
./b2 --clean
echo "Starting deploy build"
./b2 -d+2 stage \
threading=multi link=shared runtime-link=shared \
  -sMPI_PATH=${OPENMPI_DIR} --debug-configuration \
  -sBZIP2_BINARY=bz2 -sBZLIB_INCLUDE=${BZLIB_DIR}/include -sBZLIB_LIBDIR=${BZLIB_DIR}/lib \
  --prefix=${SOFT_DIR}/${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION} \
   --with-iostreams \
   --with-python
echo "starting deploy install"
./b2 -d+2 install \
threading=multi link=shared runtime-link=shared \
  -sMPI_PATH=${OPENMPI_DIR} --debug-configuration \
  -sBZIP2_BINARY=bz2 -sBZLIB_INCLUDE=${BZLIB_DIR}/include -sBZLIB_LIBDIR=${BZLIB_DIR}/lib \
  --prefix=${SOFT_DIR}/${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION} \
   --with-iostreams \
   --with-python

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
module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/${name}-deploy"
setenv BOOST_DIR $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/${VERSION}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
setenv BOOST_ROOT                      $::env(BOOST_DIR)
setenv BOOST_VERSION                $VERSION
prepend-path CFLAGS                     "-I$::env(BOOST_DIR)/include -L$::env(BOOST_DIR)/lib"
prepend-path PATH                          $::env(BOOST_DIR)/bin
prepend-path LD_LIBRARY_PATH  $::env(BOOST_DIR)/lib
MODULE_FILE
) > ${LIBRARIES}/${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
module avail ${NAME}
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
echo "LD_LIBRARY_PATH is : ${LD_LIBRARY_PATH}"
which g++
cd ${WORKSPACE}
echo "BOOST DIR is ${BOOST_DIR} ; SOFT_DIR is ${SOFT_DIR}"
ls -lht ${BOOST_DIR}
c++ -I${BOOST_DIR}/include -L${BOOST_DIR}/lib hello-world.cpp
./a.out
