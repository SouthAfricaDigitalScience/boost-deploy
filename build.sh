#!/bin/bash
# boost has a different naming convention to most, for it's source tarballs. Instead of using x.y.z it uses x_y_z
# We have to change the name of the tarbal then, later
SOURCE_FILE=$NAME-$VERSION.tar.gz
echo "Source file is $SOURCE_FILE"
echo "Source dir is $SRC_DIR"
CPUS=$(cat /proc/cpuinfo |grep "^processor"|wc -l)
module add ci
module add gcc/4.8.2

# Direct link from TENET is http://downloads.sourceforge.net/project/boost/boost/1.57.0/boost_1_57_0.tar.gz?use_mirror=tenet
if [[ ! -s $SRC_DIR/$SOURCE_FILE ]] ; then
  echo "tarball's not here ! let's get it"
  mkdir -p $SRC_DIR
  REMOTE_VERSION=`echo $VERSION | sed "s/\\./\_/g"`
#  wget http://sourceforge.net/projects/boost/files/boost/$VERSION/${NAME}_${REMOTE_VERSION}.tar.gz/download -O $SRC_DIR/$SOURCE_FILE
  echo "Getting it from sourceforge with the following command: \n wget http://downloads.sourceforge.net/projects/$NAME/$NAME/$VERSION/${NAME}_${REMOTE_VERSION}.tar.gz -O $SRC_DIR/$SOURCE_FILE"
  wget http://downloads.sourceforge.net/projects/$NAME/file/$NAME/$VERSION/${NAME}_${REMOTE_VERSION}.tar.gz -O $SRC_DIR/$SOURCE_FILE
  ls -lht $SRC_DIR
fi

tar xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
# this creates boost_1_55_0 | we would like it to follow our "." naming conventions
mv $WORKSPACE/${NAME}_${REMOTE_VERSION} $WORKSPACE/$NAME-$VERSION
cd $WORKSPACE/$NAME-$VERSION
./bootstrap.sh --prefix=$SOFT_DIR
./b2 -d+2 stage threading=multi link=shared
