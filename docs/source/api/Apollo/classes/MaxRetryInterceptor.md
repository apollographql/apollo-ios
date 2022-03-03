**CLASS**

# `MaxRetryInterceptor`

```swift
public class MaxRetryInterceptor: ApolloInterceptor
```

An interceptor to enforce a maximum number of retries of any `HTTPRequest`

## Methods
### `init(maxRetriesAllowed:)`

```swift
public init(maxRetriesAllowed: Int = 3)
```

Designated initializer.

- Parameter maxRetriesAllowed: How many times a query can be retried, in addition to the initial attempt before

#### Parameters

| Name | Description |
| ---- | ----------- |
| maxRetriesAllowed | How many times a query can be retried, in addition to the initial attempt before |

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