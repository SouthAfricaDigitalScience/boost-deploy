#!/bin/bash -e
. /etc/profile.d/modules.sh
# boost has a different naming convention to most, for it's source tarballs. Instead of using x.y.z it uses x_y_z
# We have to change the name of the tarbal then, later
module add ci
module add bzip2
module  add  readline
module add gcc/${GCC_VERSION}
module add openmpi/${OPENMPI_VERSION}-gcc-${GCC_VERSION}
module add python/2.7.13-gcc-${GCC_VERSION}
mkdir -p ${WORKSPACE}
mkdir -p ${SOFT_DIR}
mkdir -p ${SRC_DIR}
which python
which python2
SOURCE_FILE=${NAME}-${VERSION}.tar.gz
echo "Source file is ${SOURCE_FILE}"
echo "Source dir is ${SRC_DIR}"

REMOTE_VERSION=`echo ${VERSION} | sed "s/\\./\_/g"`
echo "Remote version is : ${REMOTE_VERSION}"
# Direct link from TENET is http://downloads.sourceforge.net/project/boost/boost/1.57.0/boost_1_57_0.tar.gz?use_mirror=tenet
if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "tarball's not here ! let's get it"
  echo "Getting it from sourceforge with the following command:"
  echo " wget http://downloads.sourceforge.net/project/${NAME}/${NAME}/${VERSION}/${NAME}_${REMOTE_VERSION}.tar.gz -O ${SRC_DIR}/${SOURCE_FILE}"
  wget http://downloads.sourceforge.net/project/${NAME}/${NAME}/${VERSION}/${NAME}_${REMOTE_VERSION}.tar.gz -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi

tar xzf ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
ls ${WORKSPACE}
# this creates boost_1_55_0 | we would like it to follow our "." naming conventions
#mv -n --strip-trailing-slashes ${WORKSPACE}/${NAME}_${REMOTE_VERSION} ${WORKSPACE}/${NAME}-${VERSION}
cd ${WORKSPACE}/${NAME}_${REMOTE_VERSION}
./bootstrap.sh \
--prefix=$SOFT_DIR/${NAME}-${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION} \
--with-toolset=gcc --with-python-root=$PYTHON_DIR
echo "Making mpi bindings"
echo "using mpi ;" >> project-config.jam
echo "Making python bindings"
echo "using python :  : ${PYTHONHOME}/bin/python : ${PYTHONHOME}/include/python2.7  : ${PYTHONHOME}/lib/python2.7 ;" >> project-config.jam
./b2 -d+2 stage \
threading=multi link=static,shared runtime-link=shared,shared \
  -sMPI_PATH=${OPENMPI_DIR} --debug-configuration \
  -sBZIP2_BINARY=bz2 -sBZLIB_INCLUDE=${BZLIB_DIR}/include -sBZLIB_LIBDIR=${BZLIB_DIR}/lib \
  --prefix=${SOFT_DIR}/${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION} \
   --with-iostreams \
   --with-python
  #  --with-mpi
  # --with-atomic \
  # --with-chrono \
  # --with-container \
  # --with-context \
  # --with-coroutine \
  # --with-coroutine2 \
  # --with-filesystem \
  # --with-date_time \
  # --with-exception \
  # --with-graph \
  # --with-graph_parallel \
  # --with-log \
  # --with-locale \
  # --with-system  \
  # --with-math \
  # --with-program_options \
  # --with-test --with-thread \
  # --with-timer \
  # --with-type_erasure \
  # --with-wave \
  # --with-random \
  # --with-regex \
  # --with-signals \
  # --with-serialization
