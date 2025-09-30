# Using Apollo iOS with XCFrameworks

This project supports two ways to integrate Apollo iOS into your project:

## Option 1: Source-Based Installation (Default)

Use the standard `Package.swift` file which builds Apollo from source. This is the default and recommended approach for most users.

**Pros:**
- Full source code available for debugging
- Works with all platforms (iOS, macOS, tvOS, watchOS, visionOS)
- Automatic updates through Swift Package Manager

**Supported Platforms:**
- iOS 12.0+
- macOS 10.14+
- tvOS 12.0+
- watchOS 5.0+
- visionOS 1.0+

## Option 2: Precompiled XCFramework Installation

Use the `Package.XCFramework.swift` file which uses precompiled binary XCFrameworks for faster build times.

**Pros:**
- Significantly faster build times
- Smaller project compilation overhead
- Pre-optimized binaries

**Cons:**
- Limited to iOS 17.0+ and watchOS 11.0+
- Requires building XCFrameworks first
- No source code debugging

**Supported Platforms:**
- iOS 17.0+
- watchOS 11.0+

### How to Use XCFrameworks

1. **Build the XCFrameworks:**
   ```bash
   make xcframeworks
   ```
   This will create XCFrameworks for Apollo, ApolloAPI, and ApolloSQLite in the `artifacts/` folder.

2. **Switch to XCFramework Package:**
   ```bash
   # Backup the original Package.swift
   mv Package.swift Package.Source.swift
   
   # Use the XCFramework version
   mv Package.XCFramework.swift Package.swift
   ```

3. **Use in your project:**
   Add the dependency to your project's `Package.swift` as usual:
   ```swift
   dependencies: [
       .package(path: "../path/to/apollo-ios")
   ]
   ```

4. **Switch back to source-based (if needed):**
   ```bash
   mv Package.swift Package.XCFramework.swift
   mv Package.Source.swift Package.swift
   ```

## Available Libraries

Both installation methods provide the following libraries:

- **Apollo**: The core Apollo iOS client
- **ApolloAPI**: Apollo's GraphQL type system
- **ApolloSQLite**: SQLite normalized cache implementation
- **ApolloWebSocket**: WebSocket transport (source-based only)
- **ApolloTestSupport**: Testing utilities (source-based only)

## Choosing the Right Option

- **Use source-based** if you need:
  - Support for macOS, tvOS, or visionOS
  - Access to ApolloWebSocket or ApolloTestSupport
  - Support for older OS versions
  - Source-level debugging

- **Use XCFramework** if you:
  - Only target iOS 17+ and/or watchOS 11+
  - Want faster build times
  - Prefer smaller project compilation overhead
  - Only need Apollo, ApolloAPI, and ApolloSQLite
