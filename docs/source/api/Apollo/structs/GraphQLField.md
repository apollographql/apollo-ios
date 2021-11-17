**STRUCT**

# `GraphQLField`

```swift
public struct GraphQLField: GraphQLSelection
```

## Methods
### `init(_:alias:arguments:type:)`

```swift
public init(_ name: String,
            alias: String? = nil,
            arguments: FieldArguments? = nil,
            type: GraphQLOutputType)
```

### `cacheKey(with:)`

```swift
public func cacheKey(with variables: [String: JSONEncodable]?) throws -> String
```
