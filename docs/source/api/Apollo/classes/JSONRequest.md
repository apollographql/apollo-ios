**CLASS**

# `JSONRequest`

```swift
public class JSONRequest<Operation: GraphQLOperation>: HTTPRequest<Operation>
```

> A request which sends JSON related to a GraphQL operation.

## Properties
### `requestCreator`

```swift
public let requestCreator: RequestCreator
```

### `autoPersistQueries`

```swift
public let autoPersistQueries: Bool
```

### `useGETForQueries`

```swift
public let useGETForQueries: Bool
```

### `useGETForPersistedQueryRetry`

```swift
public let useGETForPersistedQueryRetry: Bool
```

### `isPersistedQueryRetry`

```swift
public var isPersistedQueryRetry = false
```

### `serializationFormat`

```swift
public let serializationFormat = JSONSerializationFormat.self
```

### `sendOperationIdentifier`

```swift
public var sendOperationIdentifier: Bool
```

## Methods
### `init(operation:graphQLEndpoint:contextIdentifier:clientName:clientVersion:additionalHeaders:cachePolicy:autoPersistQueries:useGETForQueries:useGETForPersistedQueryRetry:requestCreator:)`

```swift
public init(operation: Operation,
            graphQLEndpoint: URL,
            contextIdentifier: UUID? = nil,
            clientName: String,
            clientVersion: String,
            additionalHeaders: [String: String] = [:],
            cachePolicy: CachePolicy = .default,
            autoPersistQueries: Bool = false,
            useGETForQueries: Bool = false,
            useGETForPersistedQueryRetry: Bool = false,
            requestCreator: RequestCreator = ApolloRequestCreator())
```

> Designated initializer
>
> - Parameters:
>   - operation: The GraphQL Operation to execute
>   - graphQLEndpoint: The endpoint to make a GraphQL request to
>   - contextIdentifier:  [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Defaults to `nil`.
>   - clientName: The name of the client to send with the `"apollographql-client-name"` header
>   - clientVersion:  The version of the client to send with the `"apollographql-client-version"` header
>   - additionalHeaders: Any additional headers you wish to add by default to this request
>   - cachePolicy: The `CachePolicy` to use for this request.
>   - autoPersistQueries: `true` if Auto-Persisted Queries should be used. Defaults to `false`.
>   - useGETForQueries: `true` if Queries should use `GET` instead of `POST` for HTTP requests. Defaults to `false`.
>   - useGETForPersistedQueryRetry: `true` if when an Auto-Persisted query is retried, it should use `GET` instead of `POST` to send the query. Defaults to `false`.
>   - requestCreator: An object conforming to the `RequestCreator` protocol to assist with creating the request body. Defaults to the provided `ApolloRequestCreator` implementation.

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The GraphQL Operation to execute |
| graphQLEndpoint | The endpoint to make a GraphQL request to |
| contextIdentifier | [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Defaults to `nil`. |
| clientName | The name of the client to send with the `"apollographql-client-name"` header |
| clientVersion | The version of the client to send with the `"apollographql-client-version"` header |
| additionalHeaders | Any additional headers you wish to add by default to this request |
| cachePolicy | The `CachePolicy` to use for this request. |
| autoPersistQueries | `true` if Auto-Persisted Queries should be used. Defaults to `false`. |
| useGETForQueries | `true` if Queries should use `GET` instead of `POST` for HTTP requests. Defaults to `false`. |
| useGETForPersistedQueryRetry | `true` if when an Auto-Persisted query is retried, it should use `GET` instead of `POST` to send the query. Defaults to `false`. |
| requestCreator | An object conforming to the `RequestCreator` protocol to assist with creating the request body. Defaults to the provided `ApolloRequestCreator` implementation. |

### `toURLRequest()`

```swift
public override func toURLRequest() throws -> URLRequest
```
