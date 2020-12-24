**CLASS**

# `ApolloClient`

```swift
public class ApolloClient
```

The `ApolloClient` class implements the core API for Apollo by conforming to `ApolloClientProtocol`.

## Properties
### `store`

```swift
public let store: ApolloStore
```

## Methods
### `init(networkTransport:store:)`

```swift
public init(networkTransport: NetworkTransport, store: ApolloStore)
```

Creates a client with the specified network transport and store.

- Parameters:
  - networkTransport: A network transport used to send operations to a server.
  - store: A store used as a local cache. Note that if the `NetworkTransport` or any of its dependencies takes a store, you should make sure the same store is passed here so that it can be cleared properly.

#### Parameters

| Name | Description |
| ---- | ----------- |
| networkTransport | A network transport used to send operations to a server. |
| store | A store used as a local cache. Note that if the `NetworkTransport` or any of its dependencies takes a store, you should make sure the same store is passed here so that it can be cleared properly. |

### `init(url:)`

```swift
public convenience init(url: URL)
```

Creates a client with a `RequestChainNetworkTransport` connecting to the specified URL.

- Parameter url: The URL of a GraphQL server to connect to.

#### Parameters

| Name | Description |
| ---- | ----------- |
| url | The URL of a GraphQL server to connect to. |