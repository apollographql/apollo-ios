**STRUCT**

# `DownloadMethod.ApolloRegistrySettings`

```swift
public struct ApolloRegistrySettings: Equatable, Codable
```

## Properties
### `apiKey`

```swift
public let apiKey: String
```

The API key to use when retrieving your schema from the Apollo Registry.

### `graphID`

```swift
public let graphID: String
```

The identifier of the graph to fetch. Can be found in Apollo Studio.

### `variant`

```swift
public let variant: String?
```

The variant of the graph in the registry.

## Methods
### `init(apiKey:graphID:variant:)`

```swift
public init(apiKey: String, graphID: String, variant: String = "current")
```

Designated initializer

- Parameters:
  - apiKey: The API key to use when retrieving your schema.
  - graphID: The identifier of the graph to fetch. Can be found in Apollo Studio.
  - variant: The variant of the graph to fetch. Defaults to "current", which will return
  whatever is set to the current variant.

#### Parameters

| Name | Description |
| ---- | ----------- |
| apiKey | The API key to use when retrieving your schema. |
| graphID | The identifier of the graph to fetch. Can be found in Apollo Studio. |
| variant | The variant of the graph to fetch. Defaults to “current”, which will return whatever is set to the current variant. |