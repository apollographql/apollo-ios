**ENUM**

# `ApolloCodegenConfiguration.TestMockFileOutput`

```swift
public enum TestMockFileOutput: Codable, Equatable
```

The local path structure for the generated test mock object files.

## Cases
### `none`

```swift
case none
```

Test mocks will not be generated. This is the default value.

### `absolute(path:)`

```swift
case absolute(path: String)
```

 Generated test mock files will be located in the specified path.
 No module will be created for the generated test mocks.

- Note: Generated files must be manually added to your test target. Test mocks generated
 this way may also be manually embedded in a test utility module that is imported by your
 test target.

### `swiftPackage(targetName:)`

```swift
case swiftPackage(targetName: String? = nil)
```

Generated test mock files will be included in a target defined in the generated
`Package.swift` file that is suitable for linking the generated test mock files to your
test target using Swift Package Manager.

The name of the test mock target can be specified with the `targetName` value.
If no target name is provided, the target name defaults to "\(schemaNamespace)TestMocks".

- Note: This requires your `SchemaTypesFileOutput.ModuleType` to be `.swiftPackageManager`.
If this option is provided without the `.swiftPackageManager` module type, code generation
will fail.
