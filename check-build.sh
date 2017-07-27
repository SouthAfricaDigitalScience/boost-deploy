#!/bin/bash -e
. /etc/profile.d/modules.sh
module add ci
module add bzip2
module  add  readline
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module add python/2.7.13-gcc-${GCC_VERSION}
module add icu/59_1-gcc-${GCC_VERSION}
REMOTE_VERSION=`echo ${VERSION} | sed "s/\\./\_/g"`

cd ${WORKSPACE}/${NAME}_${REMOTE_VERSION}/

# There is a check missing
./b2 install

mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
  puts stderr "\\tAdds $NAME ($VERSION.) to your environment."
}
module-whatis "Sets the environment for using $NAME ($VERSION.) Built with GCC ${GCC_VERSION} and OpenMPI Version ${OPENMPI_VERSION}"
module add bzip2
moduule add readline
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module add python/2.7.13-gcc-${GCC_VERSION}
module  add  icu/59_1-gcc-${GCC_VERSION}
setenv BOOST_VERSION $VERSION
setenv BOOST_DIR /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$::env(NAME)/$::env(VERSION)/$::env(VERSION)-mpi-$::env(OPENMPI_VERSION)-gcc-$::env(GCC_VERSION)
setenv BOOST_ROOT $::env(BOOST_DIR)
setenv CFLAGS "$CFLAGS -I$::env(BOOST_DIR)/include -L$::env(BOOST_DIR)/lib"
prepend-path CPATH $::env(BOOST_DIR)/include
prepend-path LD_LIBRARY_PATH $::env(BOOST_DIR)
MODULE_FILE
) > modules/${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION}
mkdir -p ${LIBRARIES}/${NAME}
cp modules/${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION} ${LIBRARIES}/${NAME}
module avail ${NAME}
module add ${NAME}/${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION}
echo "LD_LIBRARY_PATH is : ${LD_LIBRARY_PATH}"
which g++
cd ${WORKSPACE}
echo "BOOST DIR is ${BOOST_DIR} ; SOFT_DIR is ${SOFT_DIR}"
ls -lht ${BOOST_DIR}
c++ -I${BOOST_DIR}/include -L${BOOST_DIR}/lib hello-world.cpp
./a.out
