**ENUM**

# `GraphQLHTTPRequestError`

```swift
public enum GraphQLHTTPRequestError: Error, LocalizedError
```

> An error which has occurred during the serialization of a request.

## Cases
### `cancelledByDelegate`

```swift
case cancelledByDelegate
```

### `serializedBodyMessageError`

```swift
case serializedBodyMessageError
```

### `serializedQueryParamsMessageError`

```swift
case serializedQueryParamsMessageError
```

## Properties
### `errorDescription`

```swift
public var errorDescription: String?
```
