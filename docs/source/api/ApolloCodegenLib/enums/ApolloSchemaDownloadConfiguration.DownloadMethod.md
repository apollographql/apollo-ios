**ENUM**

# `ApolloSchemaDownloadConfiguration.DownloadMethod`

```swift
public enum DownloadMethod: Equatable
```

How to attempt to download your schema

## Cases
### `apolloRegistry(_:)`

```swift
case apolloRegistry(_ settings: ApolloRegistrySettings)
```

The Apollo Schema Registry, which serves as a central hub for managing your data graph.

### `introspection(endpointURL:)`

```swift
case introspection(endpointURL: URL)
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