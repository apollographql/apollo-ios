**PROTOCOL**

# `InterceptorProvider`

```swift
public protocol InterceptorProvider
```

A protocol to allow easy creation of an array of interceptors for a given operation.

## Methods
### `interceptors(for:)`

```swift
func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor]
```

Creates a new array of interceptors when called

- Parameter operation: The operation to provide interceptors for

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to provide interceptors for |

### `additionalErrorInterceptor(for:)`

```swift
func additionalErrorInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> ApolloErrorInterceptor?
```

Provides an additional error interceptor for any additional handling of errors
before returning to the UI, such as logging.
- Parameter operation: The operation to provide an additional error interceptor for

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to provide an additional error interceptor for |