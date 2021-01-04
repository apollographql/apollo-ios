**CLASS**

# `LegacyCacheWriteInterceptor`

```swift
public class LegacyCacheWriteInterceptor: ApolloInterceptor
```

An interceptor which writes data to the legacy cache, following the `HTTPRequest`'s `cachePolicy`.

## Properties
### `store`

```swift
public let store: ApolloStore
```

## Methods
### `init(store:)`

```swift
public init(store: ApolloStore)
```

Designated initializer

- Parameter store: The store to use when writing to the cache.

#### Parameters

| Name | Description |
| ---- | ----------- |
| store | The store to use when writing to the cache. |

### `interceptAsync(chain:request:response:completion:)`

```swift
public func interceptAsync<Operation: GraphQLOperation>(
  chain: RequestChain,
  request: HTTPRequest<Operation>,
  response: HTTPResponse<Operation>?,
  completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| chain | The chain the interceptor is a part of. |
| request | The request, as far as it has been constructed |
| response | [optional] The response, if received |
| completion | The completion block to fire when data needs to be returned to the UI. |