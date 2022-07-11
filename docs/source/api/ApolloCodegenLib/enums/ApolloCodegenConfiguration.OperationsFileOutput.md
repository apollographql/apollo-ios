**ENUM**

# `ApolloCodegenConfiguration.OperationsFileOutput`

```swift
public enum OperationsFileOutput: Codable, Equatable
```

The local path structure for the generated operation object files.

## Cases
### `inSchemaModule`

```swift
case inSchemaModule
```

All operation object files will be located in the module with the schema types.

### `relative(subpath:)`

```swift
case relative(subpath: String?)
```

Operation object files will be co-located relative to the defining operation `.graphql`
file. If `subpath` is specified a subfolder will be created relative to the `.graphql` file
and the operation object files will be generated there. If no `subpath` is defined then all
operation object files will be generated alongside the `.graphql` file.

### `absolute(path:)`

```swift
case absolute(path: String)
```

All operation object files will be located in the specified path.
