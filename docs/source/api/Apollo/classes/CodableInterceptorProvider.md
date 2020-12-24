**CLASS**

# `CodableInterceptorProvider`

```swift
open class CodableInterceptorProvider<FlexDecoder: FlexibleDecoder>: InterceptorProvider
```

The default interceptor provider for code generated with Swift Codegen™

## Methods
### `init(client:shouldInvalidateClientOnDeinit:decoder:)`

```swift
public init(client: URLSessionClient = URLSessionClient(),
            shouldInvalidateClientOnDeinit: Bool = true,
            decoder: FlexDecoder)
```

Designated initializer

- Parameters:
  - client: The URLSessionClient to use. Defaults to the default setup.
  - shouldInvalidateClientOnDeinit: If the passed-in client should be invalidated when this interceptor provider is deinitialized. If you are recreating the `URLSessionClient` every time you create a new provider, you should do this to prevent memory leaks. Defaults to true, since by default we provide a `URLSessionClient` to new instances.
  - decoder: A `FlexibleDecoder` which can decode `Codable` objects.

#### Parameters

| Name | Description |
| ---- | ----------- |
| client | The URLSessionClient to use. Defaults to the default setup. |
| shouldInvalidateClientOnDeinit | If the passed-in client should be invalidated when this interceptor provider is deinitialized. If you are recreating the `URLSessionClient` every time you create a new provider, you should do this to prevent memory leaks. Defaults to true, since by default we provide a `URLSessionClient` to new instances. |
| decoder | A `FlexibleDecoder` which can decode `Codable` objects. |

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