**CLASS**

# `RequestChainNetworkTransport`

```swift
public class RequestChainNetworkTransport: NetworkTransport
```

> An implementation of `NetworkTransport` which creates a `RequestChain` object
> for each item sent through it.

## Properties
### `clientName`

```swift
public var clientName = RequestChainNetworkTransport.defaultClientName
```

### `clientVersion`

```swift
public var clientVersion = RequestChainNetworkTransport.defaultClientVersion
```

## Methods
### `init(interceptorProvider:endpointURL:additionalHeaders:autoPersistQueries:requestCreator:useGETForQueries:useGETForPersistedQueryRetry:)`

```swift
public init(interceptorProvider: InterceptorProvider,
            endpointURL: URL,
            additionalHeaders: [String: String] = [:],
            autoPersistQueries: Bool = false,
            requestCreator: RequestCreator = ApolloRequestCreator(),
            useGETForQueries: Bool = false,
            useGETForPersistedQueryRetry: Bool = false)
```

> Designated initializer
>
> - Parameters:
>   - interceptorProvider: The interceptor provider to use when constructing chains for a request
>   - endpointURL: The GraphQL endpoint URL to use.
>   - additionalHeaders: Any additional headers that should be automatically added to every request. Defaults to an empty dictionary.
>   - autoPersistQueries: Pass `true` if Automatic Persisted Queries should be used to send a query hash instead of the full query body by default. Defaults to `false`.
>   - requestCreator: The `RequestCreator` object to use to build your `URLRequest`. Defaults to the providedd `ApolloRequestCreator` implementation.
>   - useGETForQueries: Pass `true` if you want to use `GET` instead of `POST` for queries, for example to take advantage of a CDN. Defaults to `false`.
>   - useGETForPersistedQueryRetry: Pass `true` to use `GET` instead of `POST` for a retry of a persisted query. Defaults to `false`.

#### Parameters

| Name | Description |
| ---- | ----------- |
| interceptorProvider | The interceptor provider to use when constructing chains for a request |
| endpointURL | The GraphQL endpoint URL to use. |
| additionalHeaders | Any additional headers that should be automatically added to every request. Defaults to an empty dictionary. |
| autoPersistQueries | Pass `true` if Automatic Persisted Queries should be used to send a query hash instead of the full query body by default. Defaults to `false`. |
| requestCreator | The `RequestCreator` object to use to build your `URLRequest`. Defaults to the providedd `ApolloRequestCreator` implementation. |
| useGETForQueries | Pass `true` if you want to use `GET` instead of `POST` for queries, for example to take advantage of a CDN. Defaults to `false`. |
| useGETForPersistedQueryRetry | Pass `true` to use `GET` instead of `POST` for a retry of a persisted query. Defaults to `false`. |

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