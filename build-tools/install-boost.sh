set -o xtrace
BOOST_VERSION=1.78.0

BOOST_UNDERSCORE_VERSION=${BOOST_VERSION//./_}
BOOST_TMP=/tmp/boost_$BOOST_UNDERSCORE_VERSION/
BOOST_FILE=boost_$BOOST_UNDERSCORE_VERSION.tar.gz

BOOST_FILE_URL=https://boostorg.jfrog.io/artifactory/main/release/$BOOST_VERSION/source/$BOOST_FILE 

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -l|--location) INSTALL_LIB_LOCATION="$2"; shift ;;
        -u|--uglify) uglify=1 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done



if [ -z "$1" ]; then
    INSTALL_LIB_LOCATION=$(pwd)/build/deps/
fi

mkdir -p $INSTALL_LIB_LOCATION

START_DIR=$(pwd)

mkdir -p $BOOST_TMP
curl -L $BOOST_FILE_URL > $BOOST_TMP/$BOOST_FILE
tar -xvf $BOOST_TMP/$BOOST_FILE -C $BOOST_TMP

cd $BOOST_TMP/boost_$BOOST_UNDERSCORE_VERSION/
./bootstrap.sh --prefix=$INSTALL_LIB_LOCATION
./b2 --with-test -j8 cxxflags=-std=c++2a
./b2 install
cd $START_DIR
