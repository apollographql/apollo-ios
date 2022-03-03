**ENUM**

# `DownloadMethod.HTTPMethod`

```swift
public enum HTTPMethod: Equatable, CustomStringConvertible
```

The HTTP request method. This is an option on Introspection schema downloads only. Apollo Registry downloads are always
POST requests.

## Cases
### `POST`

```swift
case POST
```

Use POST for HTTP requests. This is the default for GraphQL.

### `GET(queryParameterName:)`

```swift
case GET(queryParameterName: String)
```

Use GET for HTTP requests with the GraphQL query being sent in the query string parameter named in
`queryParameterName`.

## Properties
### `description`

```swift
public var description: String
```
