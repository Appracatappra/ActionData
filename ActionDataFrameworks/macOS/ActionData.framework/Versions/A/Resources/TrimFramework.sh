#!/bin/sh

#  TrimFramework.sh
#  ActionUtilities
#
#  Created by Kevin Mullins on 11/30/17.
#  Copyright © 2017 Appracatappra, LLC. All rights reserved.
#
# To use this script:
#  1. Place the script in your project root directory and name it trim.sh or something similar.
#  2. Create a new "Run Script" build phase after the "Embed Frameworks" phase.
#  3. Rename the new build phase to "Trim Framework Executables" or similar (optional).
#  4. Invoke the script for each framework you want to trim (e.g. ${SRCROOT}/trim.sh).
FRAMEWORK=$1
echo "Trimming $FRAMEWORK..."
FRAMEWORK_EXECUTABLE_PATH="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/$FRAMEWORK.framework/$FRAMEWORK"
EXTRACTED_ARCHS=()
for ARCH in $ARCHS
do
echo "Extracting $ARCH..."
lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
done
echo "Merging binaries..."
lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
rm "${EXTRACTED_ARCHS[@]}"
rm "$FRAMEWORK_EXECUTABLE_PATH"
mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"
echo "Done."
