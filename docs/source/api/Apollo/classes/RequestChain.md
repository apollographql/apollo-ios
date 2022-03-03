**CLASS**

# `RequestChain`

```swift
public class RequestChain: Cancellable
```

A chain that allows a single network request to be created and executed.

## Properties
### `isNotCancelled`

```swift
public var isNotCancelled: Bool
```

Checks the underlying value of `isCancelled`. Set up like this for better readability in `guard` statements

### `additionalErrorHandler`

```swift
public var additionalErrorHandler: ApolloErrorInterceptor?
```

Something which allows additional error handling to occur when some kind of error has happened.

## Methods
### `init(interceptors:callbackQueue:)`

```swift
public init(interceptors: [ApolloInterceptor],
            callbackQueue: DispatchQueue = .main)
```

Creates a chain with the given interceptor array.

- Parameters:
  - interceptors: The array of interceptors to use.
  - callbackQueue: The `DispatchQueue` to call back on when an error or result occurs. Defaults to `.main`.

#### Parameters

| Name | Description |
| ---- | ----------- |
| interceptors | The array of interceptors to use. |
| callbackQueue | The `DispatchQueue` to call back on when an error or result occurs. Defaults to `.main`. |

### `kickoff(request:completion:)`

```swift
public func kickoff<Operation: GraphQLOperation>(
  request: HTTPRequest<Operation>,
  completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void)
```

Kicks off the request from the beginning of the interceptor array.

- Parameters:
  - request: The request to send.
  - completion: The completion closure to call when the request has completed.

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | The request to send. |
| completion | The completion closure to call when the request has completed. |

### `proceedAsync(request:response:completion:)`

```swift
public func proceedAsync<Operation: GraphQLOperation>(
  request: HTTPRequest<Operation>,
  response: HTTPResponse<Operation>?,
  completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void)
```

Proceeds to the next interceptor in the array.

- Parameters:
  - request: The in-progress request object
  - response: [optional] The in-progress response object, if received yet
  - completion: The completion closure to call when data has been processed and should be returned to the UI.

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | The in-progress request object |
| response | [optional] The in-progress response object, if received yet |
| completion | The completion closure to call when data has been processed and should be returned to the UI. |

### `cancel()`

```swift
public func cancel()
```

Cancels the entire chain of interceptors.

### `retry(request:completion:)`

```swift
public func retry<Operation: GraphQLOperation>(
  request: HTTPRequest<Operation>,
  completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void)
```

Restarts the request starting from the first interceptor.

- Parameters:
  - request: The request to retry
  - completion: The completion closure to call when the request has completed.

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | The request to retry |
| completion | The completion closure to call when the request has completed. |

### `handleErrorAsync(_:request:response:completion:)`

```swift
public func handleErrorAsync<Operation: GraphQLOperation>(
  _ error: Error,
  request: HTTPRequest<Operation>,
  response: HTTPResponse<Operation>?,
  completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void)
```

Handles the error by returning it on the appropriate queue, or by applying an additional error interceptor if one has been provided.

- Parameters:
  - error: The error to handle
  - request: The request, as far as it has been constructed.
  - response: The response, as far as it has been constructed.
  - completion: The completion closure to call when work is complete.

#### Parameters

| Name | Description |
| ---- | ----------- |
| error | The error to handle |
| request | The request, as far as it has been constructed. |
| response | The response, as far as it has been constructed. |
| completion | The completion closure to call when work is complete. |

### `returnValueAsync(for:value:completion:)`

```swift
public func returnValueAsync<Operation: GraphQLOperation>(
  for request: HTTPRequest<Operation>,
  value: GraphQLResult<Operation.Data>,
  completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void)
```

Handles a resulting value by returning it on the appropriate queue.

- Parameters:
  - request: The request, as far as it has been constructed.
  - value: The value to be returned
  - completion: The completion closure to call when work is complete.

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | The request, as far as it has been constructed. |
| value | The value to be returned |
| completion | The completion closure to call when work is complete. |