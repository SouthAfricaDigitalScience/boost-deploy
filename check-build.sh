#!/bin/bash -e
. /etc/profile.d/module.sh
module add ci
module add bzip2
module add zlib
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
cd ${WORKSPACE}/${NAME}-${VERSION}

# There is a check missing
./b2 install
ls
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
module add zlib
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
setenv BOOST_VERSION $VERSION
set BOOST_DIR /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path CPATH ${BOOST_DIR}/include
prepend-path LD_LIBRARY_PATH ${BOOST_DIR}/lib
prepend-path LD_LIBRARY_PATH ${BOOST_DIR}/lib64
MODULE_FILE
) > modules/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} ${LIBRARIES_MODULES}/${NAME}
module avail
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
which g++
cd ${WORKSPACE}
c++ -I${WORKSPACE}/${NAME}-${VERSION}/libs hello-world.cpp
./a.out
