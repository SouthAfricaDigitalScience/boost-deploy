#!/bin/bash -e
. /etc/profile.d/modules.sh
module add deploy

# add the dependency modules for the deploy
module add bzlib2
module  add zlib
module add gcc/${GCC_VERSION}
module add  openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
cd ${WORKSPACE}/${NAME}-${VERSION}
./b2 --clean

./b2 -d+2 stage threading=multi link=shared --debug-configuration --prefix=--prefix=${SOFT_DIR}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
./b2 -d+2 install
mkdir -p ${LIBRARIES_MODULES}/${NAME}
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
module add zlib
module add bzlib2
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/${name}-deploy"
set BOOST_DIR $::env(CVMFS_DIR)$/::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
prepend-path CFLAGS ${BOOST_DIR}/include
prepend-path PATH ${BOOST_DIR}/bin
prepend-path LD_LIBRARY_PATH ${BOOST_DIR}/lib
MODULE_FILE
) > ${COMPILERS_MODULES}/${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}