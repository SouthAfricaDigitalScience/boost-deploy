#!/bin/bash
# boost has a different naming convention to most, for it's source tarballs. Instead of using x.y.z it uses x_y_z
# We have to change the name of the tarbal then, later
SOURCE_FILE=$NAME-$VERSION.tar.gz
CPUS=$(cat /proc/cpuinfo |grep "^processor"|wc -l)
module load ci
module add gcc/4.8.2

if [[ ! -s $SRC_DIR/$SOURCE_FILE ]] ; then
  echo "tarball's not here ! let's get it"
  mkdir -p $SRC_DIR
  REMOTE_VERSION=`echo $VERSION | sed "s/\\./\_/g"`
  wget http://sourceforge.net/projects/boost/files/boost/$VERSION/${NAME}_${REMOTE_VERSION}.tar.gz/download -O $SRC_DIR/$SOURCE_FILE
fi

tar xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
# this creates boost_1_55_0 | we would like it to follow our "." naming conventions
mv $WORKSPACE/${NAME}_${REMOTE_VERSION} $WORKSPACE/$NAME-$VERSION
cd $WORKSPACE/$NAME-$VERSION
./bootstrap.sh --prefix=$SOFT_DIR
./b2 -d+2 stage threading=multi link=shared
