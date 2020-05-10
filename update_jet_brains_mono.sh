#!/bin/sh

VERSION=$1
URL="https://github.com/JetBrains/JetBrainsMono/releases/download/v$VERSION/JetBrainsMono-$VERSION.zip"
ARCHIVE_FILE="/tmp/JetBrainsMono-$VERSION.zip"
OUT_DIR="/tmp/JetBrainsMono-$VERSION"
REPO_DIR="./dot_local/share/fonts"

if test "$VERSION" = ""; then
  echo "No version specified. Please pass version to download"
  exit 1
fi

echo "fetching file $URL"
curl --silent --location --output "$ARCHIVE_FILE" "$URL"
echo "extracting to $OUT_DIR"
unzip -q -o $ARCHIVE_FILE -d "$OUT_DIR"

echo "updating repo files"
rm -rf "$REPO_DIR/*"
cp $OUT_DIR/JetBrainsMono-$VERSION/ttf/* $REPO_DIR
