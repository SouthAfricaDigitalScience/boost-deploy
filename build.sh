#!/bin/bash
SOURCE_FILE=$NAME-$VERSION.tar.gz
CPUS=$(cat /proc/cpuinfo |grep "^processor"|wc -l)
module load ci
module add gcc/4.8.2

if [[ ! -s $SRC_DIR/$SOURCE_FILE ]] ; then
  echo "tarball's not here ! let's get it"
  mkdir -p $SRC_DIR
  wget http://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.gz/download -O $SRC_DIR/$SOURCE_FILE
fi

tar xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
