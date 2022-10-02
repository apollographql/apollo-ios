**CLASS**

# `HTTPRequest`

```swift
open class HTTPRequest<Operation: GraphQLOperation>: Hashable
```

Encapsulation of all information about a request before it hits the network

## Properties
### `graphQLEndpoint`

```swift
open var graphQLEndpoint: URL
```

The endpoint to make a GraphQL request to

### `operation`

```swift
open var operation: Operation
```

The GraphQL Operation to execute

### `additionalHeaders`

```swift
open var additionalHeaders: [String: String]
```

Any additional headers you wish to add by default to this request

### `cachePolicy`

```swift
open var cachePolicy: CachePolicy
```

The `CachePolicy` to use for this request.

### `contextIdentifier`

```swift
public let contextIdentifier: UUID?
```

[optional] A unique identifier for this request, to help with deduping cache hits for watchers.

## Methods
### `init(graphQLEndpoint:operation:contextIdentifier:contentType:clientName:clientVersion:additionalHeaders:cachePolicy:)`

```swift
public init(graphQLEndpoint: URL,
            operation: Operation,
            contextIdentifier: UUID? = nil,
            contentType: String,
            clientName: String,
            clientVersion: String,
            additionalHeaders: [String: String],
            cachePolicy: CachePolicy = .default)
```

Designated Initializer

- Parameters:
  - graphQLEndpoint: The endpoint to make a GraphQL request to
  - operation: The GraphQL Operation to execute
  - contextIdentifier:  [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Defaults to `nil`.
  - contentType: The `Content-Type` header's value. Should usually be set for you by a subclass.
  - clientName: The name of the client to send with the `"apollographql-client-name"` header
  - clientVersion:  The version of the client to send with the `"apollographql-client-version"` header
  - additionalHeaders: Any additional headers you wish to add by default to this request.
  - cachePolicy: The `CachePolicy` to use for this request. Defaults to the `.default` policy

#### Parameters

| Name | Description |
| ---- | ----------- |
| graphQLEndpoint | The endpoint to make a GraphQL request to |
| operation | The GraphQL Operation to execute |
| contextIdentifier | [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Defaults to `nil`. |
| contentType | The `Content-Type` header’s value. Should usually be set for you by a subclass. |
| clientName | The name of the client to send with the `"apollographql-client-name"` header |
| clientVersion | The version of the client to send with the `"apollographql-client-version"` header |
| additionalHeaders | Any additional headers you wish to add by default to this request. |
| cachePolicy | The `CachePolicy` to use for this request. Defaults to the `.default` policy |

### `addHeader(name:value:)`

```swift
open func addHeader(name: String, value: String)
```

### `updateContentType(to:)`

```swift
open func updateContentType(to contentType: String)
```

### `toURLRequest()`

```swift
open func toURLRequest() throws -> URLRequest
```

Converts this object to a fully fleshed-out `URLRequest`

- Throws: Any error in creating the request
- Returns: The URL request, ready to send to your server.

### `hash(into:)`

```swift
public func hash(into hasher: inout Hasher)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| hasher | The hasher to use when combining the components of this instance. |

### `==(_:_:)`

```swift
public static func == (lhs: HTTPRequest<Operation>, rhs: HTTPRequest<Operation>) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |