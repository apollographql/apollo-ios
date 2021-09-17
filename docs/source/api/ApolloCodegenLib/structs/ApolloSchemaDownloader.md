**STRUCT**

# `ApolloSchemaDownloader`

```swift
public struct ApolloSchemaDownloader
```

A wrapper to facilitate downloading a schema with the Apollo node CLI

## Methods
### `fetch(with:)`

```swift
public static func fetch(with configuration: ApolloSchemaDownloadConfiguration) throws
```

Downloads your schema using the specified configuration object.

- Parameters:
  - configuration: The `ApolloSchemaDownloadConfiguration` object to use to download the schema.
- Returns: Output from a successful run

#### Parameters

| Name | Description |
| ---- | ----------- |
| configuration | The `ApolloSchemaDownloadConfiguration` object to use to download the schema. |