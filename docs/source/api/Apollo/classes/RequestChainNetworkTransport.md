**CLASS**

# `RequestChainNetworkTransport`

```swift
open class RequestChainNetworkTransport: NetworkTransport
```

An implementation of `NetworkTransport` which creates a `RequestChain` object
for each item sent through it.

## Properties
### `endpointURL`

```swift
public let endpointURL: URL
```

The GraphQL endpoint URL to use.

### `additionalHeaders`

```swift
public private(set) var additionalHeaders: [String: String]
```

Any additional headers that should be automatically added to every request.

### `autoPersistQueries`

```swift
public let autoPersistQueries: Bool
```

Set to `true` if Automatic Persisted Queries should be used to send a query hash instead of the full query body by default.

### `useGETForQueries`

```swift
public let useGETForQueries: Bool
```

Set to  `true` if you want to use `GET` instead of `POST` for queries, for example to take advantage of a CDN.

### `useGETForPersistedQueryRetry`

```swift
public let useGETForPersistedQueryRetry: Bool
```

Set to `true` to use `GET` instead of `POST` for a retry of a persisted query.

### `requestBodyCreator`

```swift
public var requestBodyCreator: RequestBodyCreator
```

The `RequestBodyCreator` object to use to build your `URLRequest`.

### `clientName`

```swift
public var clientName = RequestChainNetworkTransport.defaultClientName
```

### `clientVersion`

```swift
public var clientVersion = RequestChainNetworkTransport.defaultClientVersion
```

## Methods
### `init(interceptorProvider:endpointURL:additionalHeaders:autoPersistQueries:requestBodyCreator:useGETForQueries:useGETForPersistedQueryRetry:)`

```swift
public init(interceptorProvider: InterceptorProvider,
            endpointURL: URL,
            additionalHeaders: [String: String] = [:],
            autoPersistQueries: Bool = false,
            requestBodyCreator: RequestBodyCreator = ApolloRequestBodyCreator(),
            useGETForQueries: Bool = false,
            useGETForPersistedQueryRetry: Bool = false)
```

Designated initializer

- Parameters:
  - interceptorProvider: The interceptor provider to use when constructing chains for a request
  - endpointURL: The GraphQL endpoint URL to use.
  - additionalHeaders: Any additional headers that should be automatically added to every request. Defaults to an empty dictionary.
  - autoPersistQueries: Pass `true` if Automatic Persisted Queries should be used to send a query hash instead of the full query body by default. Defaults to `false`.
  - requestBodyCreator: The `RequestBodyCreator` object to use to build your `URLRequest`. Defaults to the provided `ApolloRequestBodyCreator` implementation.
  - useGETForQueries: Pass `true` if you want to use `GET` instead of `POST` for queries, for example to take advantage of a CDN. Defaults to `false`.
  - useGETForPersistedQueryRetry: Pass `true` to use `GET` instead of `POST` for a retry of a persisted query. Defaults to `false`.

#### Parameters

| Name | Description |
| ---- | ----------- |
| interceptorProvider | The interceptor provider to use when constructing chains for a request |
| endpointURL | The GraphQL endpoint URL to use. |
| additionalHeaders | Any additional headers that should be automatically added to every request. Defaults to an empty dictionary. |
| autoPersistQueries | Pass `true` if Automatic Persisted Queries should be used to send a query hash instead of the full query body by default. Defaults to `false`. |
| requestBodyCreator | The `RequestBodyCreator` object to use to build your `URLRequest`. Defaults to the provided `ApolloRequestBodyCreator` implementation. |
| useGETForQueries | Pass `true` if you want to use `GET` instead of `POST` for queries, for example to take advantage of a CDN. Defaults to `false`. |
| useGETForPersistedQueryRetry | Pass `true` to use `GET` instead of `POST` for a retry of a persisted query. Defaults to `false`. |

### `constructRequest(for:cachePolicy:contextIdentifier:)`

```swift
open func constructRequest<Operation: GraphQLOperation>(
  for operation: Operation,
  cachePolicy: CachePolicy,
  contextIdentifier: UUID? = nil) -> HTTPRequest<Operation>
```

Constructs a default (ie, non-multipart) GraphQL request.

Override this method if you need to use a custom subclass of `HTTPRequest`.

- Parameters:
  - operation: The operation to create the request for
  - cachePolicy: The `CachePolicy` to use when creating the request
  - contextIdentifier: [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Should default to `nil`.
- Returns: The constructed request.

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to create the request for |
| cachePolicy | The `CachePolicy` to use when creating the request |
| contextIdentifier | [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Should default to `nil`. |

### `send(operation:cachePolicy:contextIdentifier:callbackQueue:completionHandler:)`

```swift
public func send<Operation: GraphQLOperation>(
  operation: Operation,
  cachePolicy: CachePolicy = .default,
  contextIdentifier: UUID? = nil,
  callbackQueue: DispatchQueue = .main,
  completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send. |
| cachePolicy | The `CachePolicy` to use making this request. |
| contextIdentifier | [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Defaults to `nil`. |
| callbackQueue | The queue to call back on with the results. Should default to `.main`. |
| completionHandler | A closure to call when a request completes. On `success` will contain the response received from the server. On `failure` will contain the error which occurred. |