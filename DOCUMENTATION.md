# Apollo iOS XCFramework Generation Documentation

## Overview

This document provides comprehensive documentation for generating XCFrameworks from the Apollo iOS Swift Package. The `make_xcframework.sh` script automates the process of building and packaging Apollo iOS frameworks for distribution to iOS projects that cannot use Swift Package Manager directly.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Supported Frameworks](#supported-frameworks)
- [Usage](#usage)
- [Script Architecture](#script-architecture)
- [Troubleshooting](#troubleshooting)
- [Technical Details](#technical-details)
- [Known Issues and Solutions](#known-issues-and-solutions)

## Prerequisites

- **Xcode**: Version 12.0 or later
- **macOS**: macOS 10.15 (Catalina) or later
- **Command Line Tools**: Xcode Command Line Tools installed
- **Swift**: Swift 5.3 or later

### Installation Verification

```bash
# Verify Xcode installation
xcode-select --print-path

# Verify Swift version
swift --version

# Verify xcodebuild is available
xcodebuild -version
```

## Supported Frameworks

The script supports building XCFrameworks for the following Apollo iOS modules:

1. **Apollo** - Core Apollo GraphQL client
2. **ApolloAPI** - GraphQL schema and operation definitions
3. **ApolloSQLite** - SQLite-based normalized cache implementation

## Usage

### Basic Usage

```bash
# Build a single framework
./make_xcframework.sh <FrameworkName>

# Examples
./make_xcframework.sh Apollo
./make_xcframework.sh ApolloAPI
./make_xcframework.sh ApolloSQLite
```

### Build All Frameworks

```bash
# Build all supported frameworks
./make_xcframework.sh Apollo
./make_xcframework.sh ApolloAPI
./make_xcframework.sh ApolloSQLite
```

### Output Location

Generated XCFrameworks are placed in the `.build/` directory:

```
.build/
├── Apollo.xcframework/
├── ApolloAPI.xcframework/
└── ApolloSQLite.xcframework/
```

## Script Architecture

### Build Process Flow

1. **Environment Setup**
   - Sets build configuration variables
   - Defines archive and derived data paths

2. **Framework Building** (for each platform)
   - **iOS Device** (`iphoneos`)
   - **iOS Simulator** (`iphonesimulator`)

3. **Module Processing**
   - Copies Swift module files (`.swiftmodule`, `.swiftdoc`)
   - Copies Swift interface files (`.swiftinterface`)
   - Removes private and package interfaces

4. **XCFramework Creation**
   - Combines device and simulator frameworks
   - Creates universal XCFramework

5. **Cleanup**
   - Archives generated XCFramework
   - Cleans up intermediate build artifacts

### Key Functions

#### `build_framework(sdk, scheme, destination)`
Builds a framework for a specific SDK (iOS device or simulator).

**Parameters:**
- `sdk`: Target SDK (`iphoneos` or `iphonesimulator`)
- `scheme`: Framework scheme name
- `destination`: Xcode destination string

**Process:**
1. Executes `xcodebuild archive` command
2. Copies Swift module files to framework
3. Copies Swift interface files from build intermediates
4. Removes private/package interface files

#### `create_xcframework(framework_name)`
Creates an XCFramework from device and simulator archives.

**Parameters:**
- `framework_name`: Name of the framework to create

**Process:**
1. Validates that both archives exist
2. Uses `xcodebuild -create-xcframework` to combine archives
3. Creates final `.xcframework` bundle

### Build Configuration

The script uses the following build configuration:

```bash
# Swift compilation flags
OTHER_SWIFT_FLAGS="-emit-module-interface -enable-library-evolution -D XCFRAMEWORK_BUILD"

# Build settings
SKIP_INSTALL=NO                    # Include framework in archive
BUILD_CONFIGURATION=Release        # Release build for distribution
```

### Platform Support

- **iOS Device**: `arm64` architecture
- **iOS Simulator**: `arm64` and `x86_64` architectures

## Technical Details

### Swift Module Interface Files

The script generates and includes three types of Swift interface files:

1. **Public Interface** (`.swiftinterface`)
   - Contains public API definitions
   - Required for module imports
   - Included in final XCFramework

2. **Private Interface** (`.private.swiftinterface`)
   - Contains internal implementation details
   - Removed from final XCFramework for security

3. **Package Interface** (`.package.swiftinterface`)
   - Contains package-internal APIs
   - Removed from final XCFramework

### Library Evolution Support

The script enables **Library Evolution** mode (`-enable-library-evolution`), which:

- Allows framework updates without breaking binary compatibility
- Generates resilient interfaces for future compatibility
- Essential for distributable frameworks

### Directory Structure

```
.build/
├── DerivedData-iphoneos/           # iOS device build artifacts
├── DerivedData-iphonesimulator/    # iOS simulator build artifacts
├── <Framework>-iphoneos.xcarchive/
├── <Framework>-iphonesimulator.xcarchive/
└── <Framework>.xcframework/        # Final output
    ├── Info.plist
    ├── ios-arm64/
    │   └── <Framework>.framework/
    │       ├── <Framework>         # Binary
    │       ├── Headers/
    │       ├── Info.plist
    │       └── Modules/
    │           └── <Framework>.swiftmodule/
    │               ├── *.swiftmodule
    │               ├── *.swiftdoc
    │               └── *.swiftinterface
    └── ios-arm64_x86_64-simulator/
        └── <Framework>.framework/
            └── [same structure as device]
```

## Troubleshooting

### Common Issues

#### 1. "No such module" Error

**Problem**: iOS project cannot import the framework.

**Symptoms:**
```
No such module 'Apollo'
No such module 'ApolloAPI'
No such module 'ApolloSQLite'
```

**Solution**: Ensure the XCFramework contains proper Swift interface files:

```bash
# Verify framework structure
find .build/Apollo.xcframework -name "*.swiftinterface"

# Should return 3+ files (one per architecture)
```

#### 2. Build Failures

**Problem**: Script fails during build process.

**Common Causes:**
- Xcode not properly installed
- Invalid scheme name
- Insufficient disk space
- Conflicting build artifacts

**Solution:**
```bash
# Clean build directory
rm -rf .build/

# Verify Xcode installation
xcode-select --install

# Run script again
./make_xcframework.sh <FrameworkName>
```

#### 3. Missing Swift Interface Files

**Problem**: XCFramework created but missing `.swiftinterface` files.

**Solution**: The script automatically handles this, but verify with:

```bash
# Check if interface files exist in build artifacts
find .build/DerivedData-* -name "*.swiftinterface"
```

#### 4. Archive Path Issues

**Problem**: Script cannot find framework archives.

**Symptoms:**
```
error: archive not found at path
```

**Solution**: The script uses controlled paths. If issues persist:

```bash
# Check if archives were created
ls -la .build/*xcarchive/
```

### Debug Mode

To run the script with verbose output:

```bash
# Enable debug output
set -x
./make_xcframework.sh <FrameworkName>
set +x
```

## Known Issues and Solutions

### Issue 1: Module Interface Generation

**Historical Problem**: Earlier versions of the script had incorrect build flags that prevented Swift interface generation.

**Resolution**: Updated build flags to include:
- `-emit-module-interface`: Generates public interfaces
- `-enable-library-evolution`: Enables ABI stability

### Issue 2: Incorrect Archive Paths

**Historical Problem**: Script looked for frameworks in wrong archive directory.

**Resolution**: Corrected paths to look in:
- Device: `Products/usr/local/lib/<Framework>.framework`
- Simulator: `Products/usr/local/lib/<Framework>.framework`

### Issue 3: Module Copying Logic

**Historical Problem**: Swift modules copied to wrong framework location.

**Resolution**: Updated module copying to use consistent paths across both device and simulator builds.

### Issue 4: Build Path Conflicts

**Historical Problem**: Device and simulator builds interfered with each other when using shared derived data.

**Resolution**: Implemented separate derived data paths:
- Device: `.build/DerivedData-iphoneos/`
- Simulator: `.build/DerivedData-iphonesimulator/`

## Integration Guide

### Adding XCFrameworks to iOS Projects

1. **Drag and Drop Method**:
   - Drag the `.xcframework` files into your Xcode project
   - Ensure "Copy items if needed" is checked
   - Add to appropriate targets

2. **Build Settings Method**:
   - Add framework search paths in Build Settings
   - Link frameworks in "Link Binary With Libraries"

3. **Import in Swift**:
   ```swift
   import Apollo
   import ApolloAPI
   import ApolloSQLite
   ```

### Version Compatibility

| Apollo iOS Version | Minimum iOS Version | Xcode Version |
|-------------------|-------------------|---------------|
| 1.0+              | iOS 12.0          | Xcode 12.0+   |

## Performance Considerations

### Build Time

Typical build times on modern hardware:

- **Apollo**: ~2-3 minutes
- **ApolloAPI**: ~1-2 minutes  
- **ApolloSQLite**: ~1-2 minutes

### Optimization

The script includes several optimizations:

1. **Separate Derived Data**: Prevents build conflicts
2. **Selective Interface Copying**: Only includes necessary interface files
3. **Controlled Build Environment**: Uses consistent build settings

## Contributing

When modifying the script:

1. **Test All Frameworks**: Ensure changes work for Apollo, ApolloAPI, and ApolloSQLite
2. **Verify Module Structure**: Check that generated XCFrameworks contain proper modules
3. **Test Integration**: Verify frameworks can be imported in iOS projects
4. **Update Documentation**: Update this file with any changes

## Support

For issues with:

- **Apollo iOS Library**: See [Apollo iOS GitHub](https://github.com/apollographql/apollo-ios)
- **XCFramework Generation**: Check this documentation and troubleshooting section
- **Swift Package Manager**: See [Swift Package Manager Documentation](https://swift.org/package-manager/)

---

*Last Updated: September 12, 2025*
*Script Version: Compatible with Apollo iOS 1.0+*
