#!/bin/bash

# Clean up
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod deintegrate

# Create the necessary directory structure for Flutter.h
mkdir -p Pods/Headers/Public/Flutter

# Find Flutter.h in the FVM installation
FLUTTER_H_PATH=$(find ~/fvm/versions/2.10.5 -name Flutter.h | grep -v "ephemeral" | head -n 1)
if [ -z "$FLUTTER_H_PATH" ]; then
  echo "Flutter.h not found in FVM installation!"
  exit 1
fi

echo "Found Flutter.h at: $FLUTTER_H_PATH"

# Create a symbolic link to Flutter.h
ln -sf "$FLUTTER_H_PATH" Pods/Headers/Public/Flutter/Flutter.h

# Run pod install
pod install

# Fix module map issues - create empty modulemap files for all pods that need them
mkdir -p "Pods/Target Support Files"
PODS_DIR="Pods/Target Support Files"

# Get a list of all pod directories
PODS=$(find "$PODS_DIR" -type d -depth 1 | grep -v "Pods-")

# Create module map files for each pod
for POD in $PODS; do
  POD_NAME=$(basename "$POD")
  MODULE_MAP_PATH="$POD/$POD_NAME.modulemap"
  
  # Create an empty module map file if it doesn't exist
  if [ ! -f "$MODULE_MAP_PATH" ]; then
    echo "Creating module map for $POD_NAME"
    echo "module $POD_NAME {" > "$MODULE_MAP_PATH"
    echo "  export *" >> "$MODULE_MAP_PATH"
    echo "}" >> "$MODULE_MAP_PATH"
  fi
done

# Also create a module map for Pods-Runner
MODULE_MAP_PATH="$PODS_DIR/Pods-Runner/Pods-Runner.modulemap"
echo "Creating module map for Pods-Runner"
echo "module Pods_Runner {" > "$MODULE_MAP_PATH"
echo "  export *" >> "$MODULE_MAP_PATH"
echo "}" >> "$MODULE_MAP_PATH"

# Fix any missing xcfilelist files
XCFILELIST_DIR="$PODS_DIR/Pods-Runner"
INPUT_FILELIST="$XCFILELIST_DIR/Pods-Runner-frameworks-Release-input-files.xcfilelist"
OUTPUT_FILELIST="$XCFILELIST_DIR/Pods-Runner-frameworks-Release-output-files.xcfilelist"

# Create empty xcfilelist files if they don't exist
if [ ! -f "$INPUT_FILELIST" ]; then
  echo "Creating empty input files list"
  touch "$INPUT_FILELIST"
fi

if [ ! -f "$OUTPUT_FILELIST" ]; then
  echo "Creating empty output files list"
  touch "$OUTPUT_FILELIST"
fi

# Go back to root
cd ..

# Run flutter pub get
fvm flutter pub get

echo "Setup complete! Try building now."