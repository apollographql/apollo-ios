**STRUCT**

# `GraphQLResult`

```swift
public struct GraphQLResult<Data>
```

> Represents the result of a GraphQL operation.

## Properties
### `data`

```swift
public let data: Data?
```

> The typed result data, or `nil` if an error was encountered that prevented a valid response.

### `errors`

```swift
public let errors: [GraphQLError]?
```

> A list of errors, or `nil` if the operation completed without encountering any errors.

### `source`

```swift
public let source: Source
```

> Source of data

## Methods
### `init(data:errors:source:dependentKeys:)`

```swift
public init(data: Data?,
            errors: [GraphQLError]?,
            source: Source,
            dependentKeys: Set<CacheKey>?)
```
