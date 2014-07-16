#!/bin/bash
set -e

GAME_NAME="Invaders"
LOVE_VERSION="0.9.1"
BUILD_DIR=$(pwd)"/build"
TMP_DIR=$BUILD_DIR"/tmp"
ICON="assets/images/icon.png"

PLIST=$(cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>BuildMachineOSBuild</key>
    <string>13C64</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>English</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeIconFile</key>
            <string>LoveDocument.icns</string>
            <key>CFBundleTypeName</key>
            <string>LÖVE Project</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSHandlerRank</key>
            <string>Owner</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>org.love2d.love-game</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Folder</string>
            <key>CFBundleTypeOSTypes</key>
            <array>
                <string>fold</string>
            </array>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSHandlerRank</key>
            <string>None</string>
        </dict>
    </array>
    <key>CFBundleExecutable</key>
    <string>love</string>
    <key>CFBundleIconFile</key>
    <string>icon.icns</string>
    <key>CFBundleIdentifier</key>
    <string>$GAME_NAME</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$GAME_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.9.1</string>
    <key>CFBundleSignature</key>
    <string>LoVe</string>
    <key>DTCompiler</key>
    <string>com.apple.compilers.llvm.clang.1_0</string>
    <key>DTPlatformBuild</key>
    <string>5B130a</string>
    <key>DTPlatformVersion</key>
    <string>GM</string>
    <key>DTSDKBuild</key>
    <string>13C64</string>
    <key>DTSDKName</key>
    <string>macosx10.9</string>
    <key>DTXcode</key>
    <string>0510</string>
    <key>DTXcodeBuild</key>
    <string>5B130a</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.games</string>
    <key>NSHumanReadableCopyright</key>
    <string>© 2006-2014 LÖVE Development Team</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF
)


if [[ $1 == "osx" ]]; then
    echo "Building $1 binary..."
    INITIAL_DIR=$(pwd)

    # Create and go to tmp dir
    mkdir -p $TMP_DIR
    cd $TMP_DIR
    # Download and unzip love binary
    if [[ ! -d "love.app" ]]; then
        if [[ ! -f "love-$LOVE_VERSION-macosx-X64.zip" ]]; then
            wget https://bitbucket.org/rude/love/downloads/love-$LOVE_VERSION-macosx-x64.zip
        fi
        unzip love-$LOVE_VERSION-macosx-x64.zip
    fi

    # Clean old builds
    cd $BUILD_DIR
    if [[ -f "$GAME_NAME-$1.zip" ]]; then
        rm "$GAME_NAME-$1.zip"
    fi
    if [[ -d "$GAME_NAME.app" ]]; then
        rm -r "$GAME_NAME.app"
    fi

    cp -R $TMP_DIR/love.app $BUILD_DIR/$GAME_NAME.app

    # Make .love
    cd $INITIAL_DIR
    if [[ -f "$GAME_NAME.love" ]]; then
        rm $GAME_NAME.love
    fi
    zip -9 -q -x=build/* -r $BUILD_DIR/$GAME_NAME.love .

    # Copy .love
    cp $BUILD_DIR/$GAME_NAME.love $BUILD_DIR/$GAME_NAME.app/Contents/Resources/

    # Create icon
    sips -s format tiff "$ICON" --out "$BUILD_DIR/$GAME_NAME.app/Contents/Resources/icon.tiff" --resampleHeightWidth 128 128 >& /dev/null
    tiff2icns -noLarge "$BUILD_DIR/$GAME_NAME.app/Contents/Resources/icon.tiff" >& /dev/null

    # Set plist
    echo $PLIST > $BUILD_DIR/$GAME_NAME.app/Contents/Info.plist

    # Make .zip
    cd $BUILD_DIR
    zip -9 -q -r $GAME_NAME-$1.zip $GAME_NAME.app

    echo "Package created. $BUILD_DIR/$GAME_NAME-$1.zip"

    echo "Done."
    cd $INITIAL_DIR

elif [[ $1 == "win32" ]] || [[ $1 == "win64" ]]; then
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
elif [[ $1  == "love" ]]; then
    echo "Building $1 binary..."
    INITIAL_DIR=$(pwd)

    # Make .love
    cd $BUILD_DIR/..
    if [[ -f "$GAME_NAME.love" ]]; then
        rm $GAME_NAME.love
    fi
    zip -9 -q -x=build/* -r $BUILD_DIR/$GAME_NAME.love .
    echo "Package created. $BUILD_DIR/$GAME_NAME.$1"
    echo "Done."
    cd $INITIAL_DIR
else
    echo "Usage: ./package.sh [win32|win64|osx|love]"
fi
