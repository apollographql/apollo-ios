**CLASS**

# `NetworkFetchInterceptor`

```swift
public class NetworkFetchInterceptor: ApolloInterceptor, Cancellable
```

An interceptor which actually fetches data from the network.

## Methods
### `init(client:)`

```swift
public init(client: URLSessionClient)
```

Designated initializer.

- Parameter client: The `URLSessionClient` to use to fetch data

#### Parameters

| Name | Description |
| ---- | ----------- |
| client | The `URLSessionClient` to use to fetch data |

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

### `cancel()`

```swift
public func cancel()
```
