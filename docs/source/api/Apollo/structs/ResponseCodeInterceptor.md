**STRUCT**

# `ResponseCodeInterceptor`

```swift
public struct ResponseCodeInterceptor: ApolloInterceptor
```

An interceptor to check the response code returned with a request.

## Methods
### `init()`

```swift
public init()
```

Designated initializer

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