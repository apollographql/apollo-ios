**ENUM**

# `ApolloSchemaDownloadConfiguration.DownloadMethod`

```swift
public enum DownloadMethod: Equatable, Codable
```

How to attempt to download your schema

## Cases
### `apolloRegistry(_:)`

```swift
case apolloRegistry(_ settings: ApolloRegistrySettings)
```

The Apollo Schema Registry, which serves as a central hub for managing your graph.

### `introspection(endpointURL:httpMethod:outputFormat:)`

```swift
case introspection(
  endpointURL: URL,
  httpMethod: HTTPMethod = .POST,
  outputFormat: OutputFormat = .SDL
)
```

GraphQL Introspection connecting to the specified URL.

## Methods
### `==(_:_:)`

```swift
public static func == (lhs: DownloadMethod, rhs: DownloadMethod) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |