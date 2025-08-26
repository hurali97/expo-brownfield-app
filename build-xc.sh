#!/bin/bash
SCRIPT_DIR="./$(dirname "${BASH_SOURCE[0]}")"

trap 'echo "Build interrupted"; exit 1' INT

CDPATH=${CDPATH:-"$SCRIPT_DIR/ios"}
WORKSPACE=${WORKSPACE:-"expoapptest"}
SCHEME=${SCHEME:-"RNEXFramework"}
CONFIGURATION=${CONFIGURATION:-"Debug"}

for arg in "$@"; do
  case $arg in
    --release)
      CONFIGURATION="Release"
      shift
      ;;
  esac
done

cd "$CDPATH" || { echo "Failed to change directory to $CDPATH"; exit 1; }

echo -e "Cleaning the old output... \n"
rm -rf "./$SCHEME.xcframework"

mkdir -p ./frameworks/simulator

echo -e "Building $CONFIGURATION frameworks... \n"
#   OTHER_SWIFT_FLAGS="-no-verify-emitted-module-interface" \
xcodebuild \
  -workspace "$WORKSPACE.xcworkspace" \
  -scheme "$SCHEME" \
  -derivedDataPath build \
  -destination "generic/platform=iphonesimulator" \
  -configuration "$CONFIGURATION" \
  SWIFT_VERSION=5.10 \
  SKIP_INSTALL=NO \
  ONLY_ACTIVE_ARCH=NO || { echo "Build failed"; exit 1; }

echo -e "Moving built frameworks... \n"
mv "./build/Build/Products/$CONFIGURATION-iphonesimulator/$SCHEME.framework" ./frameworks/simulator/ || { echo "Failed to move simulator framework"; exit 1; }

echo -e "Creating XCFramework..."
xcodebuild \
  -create-xcframework \
  -framework "./frameworks/simulator/$SCHEME.framework" \
  -output "$SCHEME.xcframework" || { echo "Failed to create XCFramework"; exit 1; }
 
echo -e "Cleaning up temporary files... \n"
# rm -rf "./frameworks"

echo "Build completed successfully!"