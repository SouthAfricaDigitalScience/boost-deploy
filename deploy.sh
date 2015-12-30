#!/bin/bash -e
. /etc/profile.d/modules.sh
module add deploy

# add the dependency modules for the deploy
module add bzip2
module add zlib
module add gmp
module add mpfr
module add mpc
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
REMOTE_VERSION=`echo ${VERSION} | sed "s/\\./\_/g"`

cd ${WORKSPACE}/${NAME}_${REMOTE_VERSION}/build-${BUILD_NUMBER}
echo "Cleaning"
./b2 --clean
echo "Starting deploy build"
./b2 -d+2 \
stage \
threading=multi \
link=shared \
--debug-configuration \
--prefix=${SOFT_DIR}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
echo "starting deploy install"
./b2 -d+2 install
echo "Creating module"
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
module add bzip2
module add gmp
module add mpfr
module add mpc
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/${name}-deploy"
setenv BOOST_DIR $::env(CVMFS_DIR)$/::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
setenv BOOST_VERSION $VERSION
prepend-path CFLAGS "-I${BOOST_DIR} -L${BOOST_DIR}"
prepend-path PATH ${BOOST_DIR}/bin
prepend-path LD_LIBRARY_PATH ${BOOST_DIR}
MODULE_FILE
) > ${LIBRARIES_MODULES}/${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
