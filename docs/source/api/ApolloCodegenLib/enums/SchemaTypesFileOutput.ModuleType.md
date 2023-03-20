**ENUM**

# `SchemaTypesFileOutput.ModuleType`

```swift
public enum ModuleType: Codable, Equatable
```

Compatible dependency manager automation.

## Cases
### `embeddedInTarget(name:)`

```swift
case embeddedInTarget(name: String)
```

Generated schema types will be manually embedded in a target with the specified `name`.
No module will be created for the generated schema types.

- Note: Generated files must be manually added to your application target. The generated
schema types files will be namespaced with the value of your configuration's 
`schemaNamespace` to prevent naming conflicts.

### `swiftPackageManager`

```swift
case swiftPackageManager
```

Generates a `Package.swift` file that is suitable for linking the generated schema types
files to your project using Swift Package Manager.

### `other`

```swift
case other
```

No module will be created for the generated types and you are required to create the
module to support your preferred dependency manager. You must specify the name of the
module you will create in the `schemaNamespace` property as this will be used in `import`
statements of generated operation files.

Use this option for dependency managers, such as CocoaPods or Carthage. Example usage
would be to create the podspec file (CocoaPods) or Xcode project file (Carthage) that
is expecting the generated files in the configured output location.
