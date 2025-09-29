#!/bin/bash

# Script modified from https://docs.emergetools.com/docs/analyzing-a-spm-framework-ios

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P)"
PROJECT_ROOT="$SCRIPT_DIR"

PROJECT_BUILD_DIR="${PROJECT_BUILD_DIR:-"${PROJECT_ROOT}/artifacts"}"
XCODEBUILD_BUILD_DIR="$PROJECT_BUILD_DIR/xcodebuild"
XCODEBUILD_DERIVED_DATA_PATH="$XCODEBUILD_BUILD_DIR/DerivedData"

# Create build directory
mkdir -p "$PROJECT_BUILD_DIR"

echo "🚀 Working with Swift Package Manager..."
cd "$PROJECT_ROOT"

PACKAGE_NAME=$1
if [ -z "$PACKAGE_NAME" ]; then
    echo "No package name provided. Using the first available library target."
    # Available library targets from Package.swift
    AVAILABLE_TARGETS=("Apollo" "ApolloAPI" "ApolloSQLite" "ApolloWebSocket" "ApolloTestSupport")
    PACKAGE_NAME=${AVAILABLE_TARGETS[0]}
    echo "Using: $PACKAGE_NAME"
    echo "Available targets: ${AVAILABLE_TARGETS[@]}"
fi

echo "🏗️ Building XCFramework for: $PACKAGE_NAME"

build_framework() {
    local sdk="$1"
    local destination="$2"
    local scheme="$3"
    local deployment_target="$4"
    local platform_prefix="$5"

    local XCODEBUILD_ARCHIVE_PATH="$PROJECT_BUILD_DIR/$scheme-$sdk.xcarchive"

    rm -rf "$XCODEBUILD_ARCHIVE_PATH"

    echo "🏗️ Building $scheme for $sdk..."

    # Use separate derived data paths for each SDK to avoid conflicts
    local DERIVED_DATA_PATH="$PROJECT_BUILD_DIR/DerivedData-$sdk"
    
    # Use xcodebuild with Swift Package Manager directly (no project file needed)
    if ! xcodebuild archive \
        -scheme "$scheme" \
        -archivePath "$XCODEBUILD_ARCHIVE_PATH" \
        -derivedDataPath "$DERIVED_DATA_PATH" \
        -destination "$destination" \
        SKIP_INSTALL=NO \
        $deployment_target \
        OTHER_SWIFT_FLAGS="-emit-module-interface -enable-library-evolution -D XCFRAMEWORK_BUILD"; then
        echo "❌ Build failed for $scheme on $sdk"
        exit 1
    fi
    
    FRAMEWORK_MODULES_PATH="$XCODEBUILD_ARCHIVE_PATH/Products/usr/local/lib/$scheme.framework/Modules"
    mkdir -p "$FRAMEWORK_MODULES_PATH"
    
    # Copy swiftmodule files
    SWIFTMODULE_SOURCE="$DERIVED_DATA_PATH/Build/Intermediates.noindex/ArchiveIntermediates/$scheme/BuildProductsPath/Release-$sdk/$scheme.swiftmodule"
    if [ -d "$SWIFTMODULE_SOURCE" ]; then
        cp -r "$SWIFTMODULE_SOURCE" "$FRAMEWORK_MODULES_PATH/$scheme.swiftmodule"
    else
        echo "❌ Could not find swiftmodule at $SWIFTMODULE_SOURCE"
        exit 1
    fi
    
    # Copy swiftinterface files from build intermediates
    SWIFTINTERFACE_BUILD_PATH="$DERIVED_DATA_PATH/Build/Intermediates.noindex/ArchiveIntermediates/$scheme/IntermediateBuildFilesPath/Apollo.build/Release-$sdk/$scheme.build/Objects-normal"
    if [ -d "$SWIFTINTERFACE_BUILD_PATH" ]; then
        for arch_dir in "$SWIFTINTERFACE_BUILD_PATH"/*; do
            if [ -d "$arch_dir" ]; then
                arch_name=$(basename "$arch_dir")
                if [ -f "$arch_dir/$scheme.swiftinterface" ]; then
                    # Determine the correct platform identifier for swiftinterface
                    local platform_id=""
                    case "$sdk" in
                        "iphonesimulator")
                            platform_id="$arch_name-apple-ios-simulator"
                            ;;
                        "iphoneos")
                            platform_id="$arch_name-apple-ios"
                            ;;
                        "watchsimulator")
                            platform_id="$arch_name-apple-watchos-simulator"
                            ;;
                        "watchos")
                            platform_id="$arch_name-apple-watchos"
                            ;;
                        *)
                            platform_id="$arch_name-apple-$platform_prefix$([ "$sdk" = *"simulator" ] && echo "-simulator")"
                            ;;
                    esac
                    cp "$arch_dir/$scheme.swiftinterface" "$FRAMEWORK_MODULES_PATH/$scheme.swiftmodule/$platform_id.swiftinterface"
                fi
            fi
        done
    fi
    
    # Delete private and package swiftinterface (keep public interfaces)
    rm -f "$FRAMEWORK_MODULES_PATH/$scheme.swiftmodule"/*.package.swiftinterface
    rm -f "$FRAMEWORK_MODULES_PATH/$scheme.swiftmodule"/*.private.swiftinterface
}

create_xcframework() {
    local framework_name="$1"
    
    echo "📦 Creating XCFramework for $framework_name..."
    
    cd "$PROJECT_BUILD_DIR"
    
    rm -rf "$framework_name.xcframework"
    
    # Build the XCFramework with all platforms
    local xcframework_args=()
    
    # Add iOS frameworks
    xcframework_args+=(-framework "$framework_name-iphonesimulator.xcarchive/Products/usr/local/lib/$framework_name.framework")
    xcframework_args+=(-framework "$framework_name-iphoneos.xcarchive/Products/usr/local/lib/$framework_name.framework")
    
    # Add watchOS frameworks
    xcframework_args+=(-framework "$framework_name-watchsimulator.xcarchive/Products/usr/local/lib/$framework_name.framework")
    xcframework_args+=(-framework "$framework_name-watchos.xcarchive/Products/usr/local/lib/$framework_name.framework")
    
    xcodebuild -create-xcframework \
        "${xcframework_args[@]}" \
        -output "$framework_name.xcframework"
    
    # Copy dSYMs if they exist
    # iOS Simulator
    if [ -d "$framework_name-iphonesimulator.xcarchive/dSYMs" ]; then
        cp -r "$framework_name-iphonesimulator.xcarchive/dSYMs" "$framework_name.xcframework/ios-arm64_x86_64-simulator/" 2>/dev/null || true
    fi
    
    # iOS Device
    if [ -d "$framework_name-iphoneos.xcarchive/dSYMs" ]; then
        cp -r "$framework_name-iphoneos.xcarchive/dSYMs" "$framework_name.xcframework/ios-arm64/" 2>/dev/null || true
    fi
    
    # watchOS Simulator
    if [ -d "$framework_name-watchsimulator.xcarchive/dSYMs" ]; then
        cp -r "$framework_name-watchsimulator.xcarchive/dSYMs" "$framework_name.xcframework/watchos-arm64_i386_x86_64-simulator/" 2>/dev/null || true
    fi
    
    # watchOS Device
    if [ -d "$framework_name-watchos.xcarchive/dSYMs" ]; then
        cp -r "$framework_name-watchos.xcarchive/dSYMs" "$framework_name.xcframework/watchos-arm64_armv7k/" 2>/dev/null || true
    fi
    
    # Create zip archive
    zip -r "$framework_name.xcframework.zip" "$framework_name.xcframework"
    
    echo "✅ $framework_name.xcframework created successfully!"
}

generate_checksum() {
    local framework_name="$1"
    local zip_path="$PROJECT_BUILD_DIR/$framework_name.xcframework.zip"
    
    if [ -f "$zip_path" ]; then
        echo "🔐 Generating checksum for $framework_name.xcframework.zip..."
        local checksum=$(swift package compute-checksum "$zip_path")
        echo "$checksum" > "$PROJECT_BUILD_DIR/$framework_name.xcframework.sha256"
        echo "📝 Checksum: $checksum"
        echo "💾 Saved to: $framework_name.xcframework.sha256"
    else
        echo "❌ Error: $framework_name.xcframework.zip not found at $zip_path"
        exit 1
    fi
}

# Build frameworks for all platforms
echo "🏗️ Building for iOS..."
build_framework "iphonesimulator" "generic/platform=iOS Simulator" "$PACKAGE_NAME" "IPHONEOS_DEPLOYMENT_TARGET=17.0" "ios"
build_framework "iphoneos" "generic/platform=iOS" "$PACKAGE_NAME" "IPHONEOS_DEPLOYMENT_TARGET=17.0" "ios"

echo "🏗️ Building for watchOS..."
build_framework "watchsimulator" "generic/platform=watchOS Simulator" "$PACKAGE_NAME" "WATCHOS_DEPLOYMENT_TARGET=11.0" "watchos"
build_framework "watchos" "generic/platform=watchOS" "$PACKAGE_NAME" "WATCHOS_DEPLOYMENT_TARGET=11.0" "watchos"

echo "🏗️ Builds completed successfully."

# Create the XCFramework
create_xcframework "$PACKAGE_NAME"

# Generate the checksum
generate_checksum "$PACKAGE_NAME"

echo "🎉 XCFramework build completed!"
echo "📁 Location: $PROJECT_BUILD_DIR/"
echo "📦 Built framework: $PACKAGE_NAME.xcframework"
echo "📦 Archive: $PACKAGE_NAME.xcframework.zip"
echo "📦 Checksum: $PACKAGE_NAME.xcframework.sha256"
echo ""
echo "🎯 Supported platforms:"
echo "  • iOS 17.0+ (Device & Simulator)"
echo "  • watchOS 11.0+ (Device & Simulator)"
