**CLASS**

# `DefaultInterceptorProvider`

```swift
open class DefaultInterceptorProvider: InterceptorProvider
```

The default interceptor provider for typescript-generated code

## Methods
### `init(client:shouldInvalidateClientOnDeinit:store:)`

```swift
public init(client: URLSessionClient = URLSessionClient(),
            shouldInvalidateClientOnDeinit: Bool = true,
            store: ApolloStore)
```

Designated initializer

- Parameters:
  - client: The `URLSessionClient` to use. Defaults to the default setup.
  - shouldInvalidateClientOnDeinit: If the passed-in client should be invalidated when this interceptor provider is deinitialized. If you are recreating the `URLSessionClient` every time you create a new provider, you should do this to prevent memory leaks. Defaults to true, since by default we provide a `URLSessionClient` to new instances.
  - store: The `ApolloStore` to use when reading from or writing to the cache. Make sure you pass the same store to the `ApolloClient` instance you're planning to use.

#### Parameters

| Name | Description |
| ---- | ----------- |
| client | The `URLSessionClient` to use. Defaults to the default setup. |
| shouldInvalidateClientOnDeinit | If the passed-in client should be invalidated when this interceptor provider is deinitialized. If you are recreating the `URLSessionClient` every time you create a new provider, you should do this to prevent memory leaks. Defaults to true, since by default we provide a `URLSessionClient` to new instances. |
| store | The `ApolloStore` to use when reading from or writing to the cache. Make sure you pass the same store to the `ApolloClient` instance you’re planning to use. |

### `deinit`

```swift
deinit
```

### `interceptors(for:)`

```swift
open func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor]
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to provide interceptors for |

### `additionalErrorInterceptor(for:)`

```swift
open func additionalErrorInterceptor<Operation: GraphQLOperation>(for operation: Operation) -> ApolloErrorInterceptor?
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to provide an additional error interceptor for |