**ENUM**

# `ApolloSchemaOptions.DownloadMethod`

```swift
public enum DownloadMethod: Equatable
```

How to attempt to download your schema

## Cases
### `registry(_:)`

```swift
case registry(_ settings: RegistrySettings)
```

### `introspection(endpointURL:)`

```swift
case introspection(endpointURL: URL)
```

- endpointURL: The endpoint to hit to download your schema.

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