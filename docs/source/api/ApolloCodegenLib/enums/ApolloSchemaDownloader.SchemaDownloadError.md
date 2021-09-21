**ENUM**

# `ApolloSchemaDownloader.SchemaDownloadError`

```swift
public enum SchemaDownloadError: Error, LocalizedError
```

## Cases
### `downloadedRegistryJSONFileNotFound(underlying:)`

```swift
case downloadedRegistryJSONFileNotFound(underlying: Error)
```

### `downloadedIntrospectionJSONFileNotFound(underlying:)`

```swift
case downloadedIntrospectionJSONFileNotFound(underlying: Error)
```

### `couldNotParseRegistryJSON(underlying:)`

```swift
case couldNotParseRegistryJSON(underlying: Error)
```

### `unexpectedRegistryJSONType`

```swift
case unexpectedRegistryJSONType
```

### `couldNotExtractSDLFromRegistryJSON`

```swift
case couldNotExtractSDLFromRegistryJSON
```

### `couldNotCreateSDLDataToWrite(schema:)`

```swift
case couldNotCreateSDLDataToWrite(schema: String)
```

### `couldNotConvertIntrospectionJSONToSDL(underlying:)`

```swift
case couldNotConvertIntrospectionJSONToSDL(underlying: Error)
```

## Properties
### `errorDescription`

```swift
public var errorDescription: String?
```
