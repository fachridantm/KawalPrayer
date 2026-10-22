#!/bin/bash
set -e

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

PROJECT="KawalPrayer.xcodeproj"
PBXPROJ="$PROJECT/project.pbxproj"
SCHEME="KawalPrayer"
BUMP_TYPE="${1:-patch}"

if [ ! -f "$PBXPROJ" ]; then
    echo "Error: $PBXPROJ not found."
    exit 1
fi

CURRENT_VERSION=$(grep -m1 "MARKETING_VERSION =" "$PBXPROJ" | sed -E 's/.*MARKETING_VERSION = ([0-9.]+);/\1/' | tr -d '[:space:]')
CURRENT_BUILD=$(grep -m1 "CURRENT_PROJECT_VERSION =" "$PBXPROJ" | sed -E 's/.*CURRENT_PROJECT_VERSION = ([0-9]+);/\1/' | tr -d '[:space:]')

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
MAJOR=${MAJOR:-1}
MINOR=${MINOR:-0}
PATCH=${PATCH:-0}

case "$BUMP_TYPE" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
        ;;
    patch)
        PATCH=$((PATCH + 1))
        NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
        ;;
    [0-9]*.[0-9]*.[0-9]*)
        NEW_VERSION="$BUMP_TYPE"
        ;;
    v[0-9]*.[0-9]*.[0-9]*)
        NEW_VERSION="${BUMP_TYPE#v}"
        ;;
    *)
        echo "Usage: $0 [patch|minor|major|<X.Y.Z>]"
        exit 1
        ;;
esac

NEW_BUILD=$((CURRENT_BUILD + 1))
TAG="v${NEW_VERSION}"
DMG_NAME="KawalPrayer-${TAG}.dmg"

echo "==> Bumping version: ${CURRENT_VERSION} (${CURRENT_BUILD}) -> ${NEW_VERSION} (${NEW_BUILD})"

sed -i '' -E "s/MARKETING_VERSION = [0-9.]+;/MARKETING_VERSION = ${NEW_VERSION};/g" "$PBXPROJ"
sed -i '' -E "s/CURRENT_PROJECT_VERSION = [0-9]+;/CURRENT_PROJECT_VERSION = ${NEW_BUILD};/g" "$PBXPROJ"

echo "==> Running unit tests..."
pkill -x KawalPrayer 2>/dev/null || true
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    test

echo "==> Building release DMG (${DMG_NAME})..."
./scripts/build_dmg.sh

if [ -d "/Applications/KawalPrayer.app" ]; then
    echo "==> Updating /Applications/KawalPrayer.app..."
    pkill -x KawalPrayer 2>/dev/null || true
    sleep 1
    rm -rf /Applications/KawalPrayer.app
    cp -R "build/Build/Products/Release/KawalPrayer.app" /Applications/KawalPrayer.app
    xattr -cr /Applications/KawalPrayer.app
    codesign --force --deep --sign - /Applications/KawalPrayer.app
    open -n /Applications/KawalPrayer.app || true
fi

echo "==> Committing and tagging ${TAG}..."
git add "$PBXPROJ"
git commit -m "chore(release): bump version to ${TAG} (build ${NEW_BUILD})"
git tag -f -a "$TAG" -m "KawalPrayer ${TAG} (Build ${NEW_BUILD})"

echo "==> Pushing main and ${TAG} to origin..."
git push origin main --tags

if command -v gh >/dev/null 2>&1; then
    echo "==> Publishing GitHub Release ${TAG}..."
    if gh release view "$TAG" >/dev/null 2>&1; then
        gh release upload "$TAG" "$DMG_NAME" --clobber
    else
        gh release create "$TAG" "$DMG_NAME" \
            --title "KawalPrayer ${TAG}" \
            --generate-notes
    fi
    echo "==> Release published: $(gh release view "$TAG" --json url -q .url)"
else
    echo "Warning: 'gh' CLI not found; pushed tag ${TAG} but skipped GitHub Release creation."
fi
