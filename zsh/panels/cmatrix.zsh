#!/usr/bin/env zsh

CMATRIX_DIR="$HOME/src/cmatrix"
if [[ -d $CMATRIX_DIR ]]; then
    cd $CMATRIX_DIR

    git pull &> /dev/null # we dont care if this fails
else
    if ! git clone https://github.com/abishekvashok/cmatrix.git $CMATRIX_DIR; then
        echo "failed to clone cmatrix" >&2
        exit 1
    fi
fi

BUILD_DIR="$CMATRIX_DIR/build"
CMAKE_OPTS="-DCMAKE_POLICY_VERSION_MINIMUM=3.5"

if ! cmake $CMATRIX_DIR -B $BUILD_DIR $CMAKE_OPTS; then
    echo "failed to configure!" >&2
    exit 2
fi

if ! cmake --build $BUILD_DIR -j 8; then
    echo "failed to build!" >&2
    exit 3
fi

$BUILD_DIR/cmatrix -C magenta
