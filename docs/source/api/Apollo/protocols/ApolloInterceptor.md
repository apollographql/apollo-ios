**PROTOCOL**

# `ApolloInterceptor`

```swift
public protocol ApolloInterceptor: AnyObject
```

A protocol to set up a chainable unit of networking work.

## Methods
### `interceptAsync(chain:request:response:completion:)`

```swift
func interceptAsync<Operation: GraphQLOperation>(
  chain: RequestChain,
  request: HTTPRequest<Operation>,
  response: HTTPResponse<Operation>?,
  completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void)
```

Called when this interceptor should do its work.

- Parameters:
  - chain: The chain the interceptor is a part of.
  - request: The request, as far as it has been constructed
  - response: [optional] The response, if received
  - completion: The completion block to fire when data needs to be returned to the UI.

#### Parameters

| Name | Description |
| ---- | ----------- |
| chain | The chain the interceptor is a part of. |
| request | The request, as far as it has been constructed |
| response | [optional] The response, if received |
| completion | The completion block to fire when data needs to be returned to the UI. |