**STRUCT**

# `GraphQLGETTransformer`

```swift
public struct GraphQLGETTransformer
```

## Methods
### `init(body:url:)`

```swift
public init(body: GraphQLMap, url: URL)
```

A helper for transforming a GraphQLMap that can be sent with a `POST` request into a URL with query parameters for a `GET` request.

- Parameters:
  - body: The GraphQLMap to transform from the body of a `POST` request
  - url: The base url to append the query to.

#### Parameters

| Name | Description |
| ---- | ----------- |
| body | The GraphQLMap to transform from the body of a `POST` request |
| url | The base url to append the query to. |

### `createGetURL()`

```swift
public func createGetURL() -> URL?
```

Creates the get URL.

- Returns: [optional] The created get URL or nil if the provided information couldn't be used to access the appropriate parameters.
