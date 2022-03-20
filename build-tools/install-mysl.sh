set -o xtrace

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -l|--location) INSTALL_LIB_LOCATION="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done



if [ -z "$1" ]; then
    INSTALL_LIB_LOCATION=$(pwd)/build/deps
fi

START_DIR=$(pwd)


INCLUDE_DIR=$INSTALL_LIB_LOCATION/include/mysl
mkdir -p $INCLUDE_DIR

BIN_DIR=$INSTALL_LIB_LOCATION/lib
mkdir -p $BIN_DIR


TEMP_DIR=$(mktemp -d)

git clone git@github.com:rileymat/mysl.git $TEMP_DIR
cp -R $TEMP_DIR/src/include/* $INCLUDE_DIR
cd $TEMP_DIR
make all
cp build/bin/* $BIN_DIR/
cd $START_DIR


