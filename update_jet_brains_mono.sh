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

# Exit if we're running on Mac OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  exit 0
fi

while true; do
    read -p "Apply new fonts? (y/n) " yn
    case $yn in
        [Yy]* ) chezmoi apply ~/.local/share/fonts -v && sudo fc-cache -f -v; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer Y or N.";;
    esac
done
