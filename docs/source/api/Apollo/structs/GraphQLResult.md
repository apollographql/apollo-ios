**STRUCT**

# `GraphQLResult`

```swift
public struct GraphQLResult<Data>: Parseable
```

Represents the result of a GraphQL operation.

## Properties
### `data`

```swift
public let data: Data?
```

The typed result data, or `nil` if an error was encountered that prevented a valid response.

### `errors`

```swift
public let errors: [GraphQLError]?
```

A list of errors, or `nil` if the operation completed without encountering any errors.

### `extensions`

```swift
public let extensions: [String: Any]?
```

A dictionary which services can use however they see fit to provide additional information to clients.

### `source`

```swift
public let source: Source
```

Source of data

## Methods
### `init(from:decoder:)`

```swift
public init<T: FlexibleDecoder>(from data: Foundation.Data, decoder: T) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| data | The data to decode |
| decoder | The decoder to use to decode it |

### `init(data:extensions:errors:source:dependentKeys:)`

```swift
public init(data: Data?,
            extensions: [String: Any]?,
            errors: [GraphQLError]?,
            source: Source,
            dependentKeys: Set<CacheKey>?)
```
