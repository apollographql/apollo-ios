**CLASS**

# `LegacyInterceptorProvider`

```swift
open class LegacyInterceptorProvider: InterceptorProvider
```

> The default interceptor provider for typescript-generated code

## Methods
### `init(client:shouldInvalidateClientOnDeinit:store:)`

```swift
public init(client: URLSessionClient = URLSessionClient(),
            shouldInvalidateClientOnDeinit: Bool = true,
            store: ApolloStore)
```

> Designated initializer
>
> - Parameters:
>   - client: The `URLSessionClient` to use. Defaults to the default setup.
>   - shouldInvalidateClientOnDeinit: If the passed-in client should be invalidated when this interceptor provider is deinitialized. If you are recreating the `URLSessionClient` every time you create a new provider, you should do this to prevent memory leaks. Defaults to true, since by default we provide a `URLSessionClient` to new instances.
>   - store: The `ApolloStore` to use when reading from or writing to the cache.

#### Parameters

| Name | Description |
| ---- | ----------- |
| client | The `URLSessionClient` to use. Defaults to the default setup. |
| shouldInvalidateClientOnDeinit | If the passed-in client should be invalidated when this interceptor provider is deinitialized. If you are recreating the `URLSessionClient` every time you create a new provider, you should do this to prevent memory leaks. Defaults to true, since by default we provide a `URLSessionClient` to new instances. |
| store | The `ApolloStore` to use when reading from or writing to the cache. |

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