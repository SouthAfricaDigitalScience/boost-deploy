#!/bin/bash
module add ci
module add gcc/4.8.2
cd $WORKSPACE/$NAME-$VERSION/
./b2 install
ls

mkdir -p $REPO_DIR
tar czf $REPO_DIR/build.tar.gz -C $WORKSPACE/build apprepo
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
  puts stderr "\\tAdds $NAME ($VERSION.) to your environment."
}
module-whatis "Sets the environment for using $NAME ($VERSION.)"
module load gcc/4.8.2
setenv BOOST_VERSION $VERSION
set BOOST_DIR /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH \$BOOST_DIR/include
prepend-path LD_LIBRARY_PATH \$BOOST_DIR/lib
prepend-path LD_LIBRARY_PATH \$BOOST_DIR/lib64
MODULE_FILE
) > modules/$VERSION
mkdir -p $LIBRARIES_MODULES/$NAME
cp modules/$VERSION $LIBRARIES_MODULES/$NAME

which g++
cd $WORKSPACE
g++ hello-world.cpp
./a.out
