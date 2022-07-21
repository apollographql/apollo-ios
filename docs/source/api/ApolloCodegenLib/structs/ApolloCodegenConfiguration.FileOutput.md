**STRUCT**

# `ApolloCodegenConfiguration.FileOutput`

```swift
public struct FileOutput: Codable, Equatable
```

The paths and files output by code generation.

## Properties
### `schemaTypes`

```swift
public let schemaTypes: SchemaTypesFileOutput
```

The local path structure for the generated schema types files.

### `operations`

```swift
public let operations: OperationsFileOutput
```

The local path structure for the generated operation object files.

### `testMocks`

```swift
public let testMocks: TestMockFileOutput
```

The local path structure for the test mock operation object files.

### `operationIdentifiersPath`

```swift
public let operationIdentifiersPath: String?
```

An absolute location to an operation id JSON map file. If specified, also stores the
operation IDs (hashes) as properties on operation types.

## Methods
### `init(schemaTypes:operations:testMocks:operationIdentifiersPath:)`

```swift
public init(
  schemaTypes: SchemaTypesFileOutput,
  operations: OperationsFileOutput = .relative(subpath: nil),
  testMocks: TestMockFileOutput = .none,
  operationIdentifiersPath: String? = nil
)
```

Designated initializer.

- Parameters:
 - schemaTypes: The local path structure for the generated schema types files.
 - operations: The local path structure for the generated operation object files.
 Defaults to `.relative` with a `subpath` of `nil`.
 - testMocks: The local path structure for the test mock operation object files.
 If `.none`, test mocks will not be generated. Defaults to `.none`.
 - operationIdentifiersPath: An absolute location to an operation id JSON map file.
 If specified, also stores the operation IDs (hashes) as properties on operation types.
 Defaults to `nil`.
