**STRUCT**

# `JSONResponseParsingInterceptor`

```swift
public struct JSONResponseParsingInterceptor: ApolloInterceptor
```

An interceptor which parses JSON response data into a `GraphQLResult` and attaches it to the `HTTPResponse`.

## Methods
### `init()`

```swift
public init()
```

### `interceptAsync(chain:request:response:completion:)`

```swift
public func interceptAsync<Operation: GraphQLOperation>(
  chain: RequestChain,
  request: HTTPRequest<Operation>,
  response: HTTPResponse<Operation>?,
  completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| chain | The chain the interceptor is a part of. |
| request | The request, as far as it has been constructed |
| response | [optional] The response, if received |
| completion | The completion block to fire when data needs to be returned to the UI. |