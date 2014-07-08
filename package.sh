#!/bin/bash
set -e

GAME_NAME="Invaders"
LOVE_VERSION="0.9.1"
BUILD_DIR=$(pwd)"/build"
TMP_DIR=$BUILD_DIR"/tmp"


if [[ $1 == "win32" ]]; then
    echo "Building $1 binary..."
    INITIAL_DIR=$(pwd)

    # Create and go to tmp dir
    mkdir -p $TMP_DIR
    cd $TMP_DIR
    # Download and unzip love binary
    if [[ ! -d "love-$LOVE_VERSION-$1" ]]; then
        if [[ ! -f "love-$LOVE_VERSION-$1.zip" ]]; then
            wget https://bitbucket.org/rude/love/downloads/love-$LOVE_VERSION-$1.zip
        fi
        unzip love-$LOVE_VERSION-$1.zip
    fi

    # Clean old builds
    cd $BUILD_DIR
    if [[ -f "$GAME_NAME-$1.zip" ]]; then
        rm "$GAME_NAME-$1.zip"
    fi
    if [[ -d "$GAME_NAME-$1" ]]; then
        rm -r "$GAME_NAME-$1"
    fi

    # Make new dir
    mkdir "$GAME_NAME-$1"
    cd "$GAME_NAME-$1"

    # Copy DLL and love binary
    cp $TMP_DIR/love-$LOVE_VERSION-$1/{DevIL.dll,license.txt,love.dll,lua51.dll,mpg123.dll} .
    cp $TMP_DIR/love-$LOVE_VERSION-$1/{msvcp110.dll,msvcr110.dll,OpenAL32.dll,SDL2.dll} .

    # Make .love
    cd $INITIAL_DIR
    if [[ -f "$GAME_NAME.love" ]]; then
        rm $GAME_NAME.love
    fi
    zip -9 -q -x=build/* -r $BUILD_DIR/$GAME_NAME.love .

    # Make .exe
    cd $BUILD_DIR/$GAME_NAME-$1
    cat $TMP_DIR/love-$LOVE_VERSION-$1/love.exe ../$GAME_NAME.love > $GAME_NAME.exe

    # Make .zip
    cd $BUILD_DIR
    zip -9 -q -r $GAME_NAME-$1.zip $GAME_NAME-$1

    echo "Package created. $BUILD_DIR/$GAME_NAME-$1.zip"
    echo "Done."
    cd $INITIAL_DIR
fi

if [[ $1 == "win64" ]]; then
    echo "Building $1 binary..."
    INITIAL_DIR=$(pwd)

    # Create and go to tmp dir
    mkdir -p $TMP_DIR
    cd $TMP_DIR
    # Download and unzip love binary
    if [[ ! -d "love-$LOVE_VERSION-$1" ]]; then
        if [[ ! -f "love-$LOVE_VERSION-$1.zip" ]]; then
            wget https://bitbucket.org/rude/love/downloads/love-$LOVE_VERSION-$1.zip
        fi
        unzip love-$LOVE_VERSION-$1.zip
    fi

    # Clean old builds
    cd $BUILD_DIR
    if [[ -f "$GAME_NAME-$1.zip" ]]; then
        rm "$GAME_NAME-$1.zip"
    fi
    if [[ -d "$GAME_NAME-$1" ]]; then
        rm -r "$GAME_NAME-$1"
    fi

    # Make new dir
    mkdir "$GAME_NAME-$1"
    cd "$GAME_NAME-$1"

    # Copy DLL and love binary
    cp $TMP_DIR/love-$LOVE_VERSION-$1/{DevIL.dll,license.txt,love.dll,lua51.dll,mpg123.dll} .
    cp $TMP_DIR/love-$LOVE_VERSION-$1/{msvcp110.dll,msvcr110.dll,OpenAL32.dll,SDL2.dll} .

    # Make .love
    cd $INITIAL_DIR
    if [[ -f "$GAME_NAME.love" ]]; then
        rm $GAME_NAME.love
    fi
    zip -9 -q -x=build/* -r $BUILD_DIR/$GAME_NAME.love .

    # Make .exe
    cd $BUILD_DIR/$GAME_NAME-$1
    cat $TMP_DIR/love-$LOVE_VERSION-$1/love.exe ../$GAME_NAME.love > $GAME_NAME.exe

    # Make .zip
    cd $BUILD_DIR
    zip -9 -q -r $GAME_NAME-$1.zip $GAME_NAME-$1

    echo "Package created. $BUILD_DIR/$GAME_NAME-$1.zip"
    echo "Done."
    cd $INITIAL_DIR
fi
