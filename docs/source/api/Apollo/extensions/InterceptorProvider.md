**EXTENSION**

# `InterceptorProvider`
```swift
public extension InterceptorProvider
```

## Methods
### `additionalErrorInterceptor(for:)`

```swift
func additionalErrorInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> ApolloErrorInterceptor?
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to provide an additional error interceptor for |