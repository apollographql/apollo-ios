**STRUCT**

# `DownloadMethod.RegistrySettings`

```swift
public struct RegistrySettings: Equatable
```

## Properties
### `apiKey`

```swift
public let apiKey: String
```

### `graphID`

```swift
public let graphID: String
```

### `variant`

```swift
public let variant: String?
```

## Methods
### `init(apiKey:graphID:variant:)`

```swift
public init(apiKey: String,
            graphID: String,
            variant: String? = nil)
```

Designated initializer

- Parameters:
  - apiKey: The API key to use when retrieving your schema.
  - graphID: The identifier of the graph to fetch. Can be found in Apollo Studio.
  - variant: [Optional] The variant of the graph to fetch. Defaults to nil, which will return whatever is set to the current variant.

#### Parameters

| Name | Description |
| ---- | ----------- |
| apiKey | The API key to use when retrieving your schema. |
| graphID | The identifier of the graph to fetch. Can be found in Apollo Studio. |
| variant | [Optional] The variant of the graph to fetch. Defaults to nil, which will return whatever is set to the current variant. |