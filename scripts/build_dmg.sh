#!/bin/bash
set -e

PROJECT="KawalPrayer.xcodeproj"
SCHEME="KawalPrayer"
BUILD_DIR="build"
VERSION=$(grep -m1 "MARKETING_VERSION =" "$PROJECT/project.pbxproj" | sed -E 's/.*MARKETING_VERSION = ([0-9.]+);/\1/' | tr -d '[:space:]')
BUILD_NUMBER=$(grep -m1 "CURRENT_PROJECT_VERSION =" "$PROJECT/project.pbxproj" | sed -E 's/.*CURRENT_PROJECT_VERSION = ([0-9]+);/\1/' | tr -d '[:space:]')
DMG_NAME="KawalPrayer-v${VERSION}.dmg"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

echo "==> Building KawalPrayer v${VERSION} (Build ${BUILD_NUMBER}) [$SCHEME]..."
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

APP_PATH="$BUILD_DIR/Build/Products/Release/KawalPrayer.app"

if [ ! -d "$APP_PATH" ]; then
    echo "Error: Build failed, $APP_PATH not found."
    exit 1
fi

echo "==> Stripping extended attributes and ad-hoc signing..."
xattr -cr "$APP_PATH"
codesign --force --deep --sign - "$APP_PATH"

echo "==> Creating DMG ($DMG_NAME)..."
rm -rf dmg_tmp "$DMG_NAME"
mkdir -p dmg_tmp
cp -r "$APP_PATH" dmg_tmp/
ln -s /Applications dmg_tmp/Applications

hdiutil create \
    -volname "KawalPrayer" \
    -srcfolder dmg_tmp \
    -ov -format UDZO \
    "$DMG_NAME"

rm -rf dmg_tmp

echo ""
echo "Successfully built DMG: $DMG_NAME"
