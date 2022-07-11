**STRUCT**

# `ApolloCodegenConfiguration.SchemaTypesFileOutput`

```swift
public struct SchemaTypesFileOutput: Codable, Equatable
```

The local path structure for the generated schema types files.

## Properties
### `path`

```swift
public let path: String
```

Local path where the generated schema types files should be stored.

### `moduleType`

```swift
public let moduleType: ModuleType
```

Automation to ease the integration of the generated schema types file with compatible
dependency managers.

## Methods
### `init(path:moduleType:)`

```swift
public init(
  path: String,
  moduleType: ModuleType
)
```

Designated initializer.

- Parameters:
 - path: Local path where the generated schema type files should be stored.
 - moduleType: Type of module that will be created for the schema types files.
