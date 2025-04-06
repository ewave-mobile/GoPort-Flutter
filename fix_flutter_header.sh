#!/bin/bash

# Create directory structure for Flutter header
mkdir -p ios/Flutter/Flutter.framework/Headers

# Find Flutter.h in the FVM installation
FLUTTER_H=$(find ~/fvm/versions/2.10.5 -name Flutter.h | grep -v ephemeral | head -n 1)
if [ -z "$FLUTTER_H" ]; then
  echo "Flutter.h not found in FVM installation!"
  exit 1
fi

echo "Found Flutter.h at: $FLUTTER_H"

# Create a copy of Flutter.h in the Flutter framework directory
cp "$FLUTTER_H" ios/Flutter/Flutter.framework/Headers/

# Create a symlink to make Flutter.h accessible to GeneratedPluginRegistrant.h
mkdir -p ios/Flutter/Flutter.framework/Modules
echo '{
  "version": 1,
  "headers": [
    {
      "path": "Headers/Flutter.h",
      "umbrella": true
    }
  ],
  "abi": "",
  "name": "Flutter",
  "module_map": "module.modulemap",
  "module": ""
}' > ios/Flutter/Flutter.framework/Modules/module.json

# Create module.modulemap
echo 'framework module Flutter {
  umbrella header "Flutter.h"
  export *
  module * { export * }
}' > ios/Flutter/Flutter.framework/Modules/module.modulemap

# Fix the Runner-Bridging-Header.h issue by creating a GeneratedPluginRegistrant.h that doesn't use Flutter.h
PLUGIN_REG_PATH="ios/Runner/GeneratedPluginRegistrant.h"
if [ -f "$PLUGIN_REG_PATH" ]; then
  # Back up the original file
  cp "$PLUGIN_REG_PATH" "${PLUGIN_REG_PATH}.bak"
  
  # Replace the problematic import with a direct import
  sed -i '' 's|#import <Flutter/Flutter.h>|// #import <Flutter/Flutter.h>|g' "$PLUGIN_REG_PATH"
fi

echo "Setup complete! Now run the following commands:"
echo "cd ios"
echo "pod install"
echo "cd .."
echo "fvm flutter build ios"