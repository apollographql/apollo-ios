---
title: Subscriptions
---

GraphQL supports [subscriptions](https://graphql.org/blog/subscriptions-in-graphql-and-relay/) to allow clients to be immediately updated when the data changes on a server.

Apollo iOS Subscriptions are supported through code generation. Similar to queries, subscriptions are represented by instances of generated classes, conforming to the `GraphQLSubscription` protocol.

```graphql title="ReviewAddedSubscription.graphql"
subscription ReviewAdded {
  reviewAdded {
    id
    stars
  }
}
```

Once those operations are generated, you can use `ApolloClient.subscribe(subscription:)` using a subscription-supporting network transport to subscribe, and continue to receive updates about changes until the subscription is cancelled.

```swift
let subscription = client.subscribe(subscription: ReviewAddedSubscription()) { result in
  guard let data = try? result.get().data else { return }
  print(data.reviews.map { $0.stars })
}
```

> Note: GraphQL subscriptions are distinct from [watching queries](./queries#watching-queries). A query watcher is only updated when new data is written to the local cache (usually by another network operation). A GraphQL subscription is a long-lived request that may receive updated data from the server continuously.

## Cancelling a subscription

It is important that all subscription connections are canceled when you are done with them. As long as a subscription is active, it will maintain a connection to the server and it's `resultHandler` completion block is retained. This can create memory leaks and reduce your application's performance.

When you call `ApolloClient.subscribe(subscription:)` an opaque `Cancellable` is returned. You can cancel the subscription by calling `cancel()` on the returned `Cancellable`. This will terminate the connection to the server and release the `resultHandler` completion block.

A subscription's cancellation object **does not** cancel itself when it is deallocated, so you must be sure to `cancel()` it yourself. A `class` can ensure any subscriptions it manages are cancelled when it is released by using its deinitializer.

```swift
class ReviewViewController {

  let client: ApolloClient!
  private var subscription: Cancellable?

  func subscribeToReviews() {
    // Keep a reference to the subscription's cancellation object.
    self.subscription = client.subscribe(subscription: ReviewAddedSubscription()) { [weak self] result in
      // Handle each update from the subscription.
    }
  }

  deinit {
    // Make sure the subscription is cancelled, if it exists, when this object is deallocated.
    self.subscription?.cancel()
  }
}
```

## Enabling GraphQL subscription support

The Apollo iOS library supports the use of subscriptions via:
1. [`ApolloWebSocket`](https://www.apollographql.com/docs/ios/docc/documentation/apollowebsocket), an optional additional Apollo library.
2. HTTP using [chunked multipart responses](https://github.com/graphql/graphql-over-http/blob/main/rfcs/IncrementalDelivery.md) (version 1.1.0 and later).

In order to support GraphQL subscriptions, your `ApolloClient` must be initialized with a [`NetworkTransport`](https://www.apollographql.com/docs/ios/docc/documentation/apollo/networktransport) that supports subscriptions.

### GraphQL subscriptions over WebSocket

Within the `ApolloWebSocket` library, there are two classes which conform to the [`NetworkTransport` protocol](https://www.apollographql.com/docs/ios/docc/documentation/apollo/networktransport):

- **[`WebSocketTransport`](https://www.apollographql.com/docs/ios/docc/documentation/apollowebsocket/websockettransport)** sends all operations over a web socket.
- **[`SplitNetworkTransport`](https://www.apollographql.com/docs/ios/docc/documentation/apollowebsocket/splitnetworktransport)** hangs onto both a [`WebSocketTransport`](https://www.apollographql.com/docs/ios/docc/documentation/apollowebsocket/websockettransport) instance and an [`UploadingNetworkTransport`](https://www.apollographql.com/docs/ios/docc/documentation/apollo/uploadingnetworktransport) instance (usually [`RequestChainNetworkTransport`](https://www.apollographql.com/docs/ios/docc/documentation/apollo/requestchainnetworktransport) in order to create a single network transport that can use http for queries and mutations, and web sockets for subscriptions.

Typically, you'll want to use `SplitNetworkTransport`, since this allows you to retain the single `NetworkTransport` setup and avoids any potential issues of using multiple client objects.

Here is an example of setting up an `ApolloClient` which uses a `SplitNetworkTransport` to support both subscriptions and queries:

```swift
/// A common store to use for `httpTransport` and `webSocketTransport`.
let store = ApolloStore()

/// A web socket transport to use for subscriptions
let webSocketTransport: WebSocketTransport = {
  let url = URL(string: "ws://localhost:8080/websocket")!
  let webSocketClient = WebSocket(url: url, protocol: .graphql_transport_ws)
  return WebSocketTransport(websocket: webSocketClient)
}()

/// An HTTP transport to use for queries and mutations
let httpTransport: RequestChainNetworkTransport = {
  let url = URL(string: "http://localhost:8080/graphql")!
  return RequestChainNetworkTransport(interceptorProvider: DefaultInterceptorProvider(store: store), endpointURL: url)
}()

/// A split network transport to allow the use of both of the above
/// transports through a single `NetworkTransport` instance.
let splitNetworkTransport = SplitNetworkTransport(
  uploadingNetworkTransport: httpTransport,
  webSocketNetworkTransport: webSocketTransport
)

/// Create a client using the `SplitNetworkTransport`.
let client = ApolloClient(networkTransport: splitNetworkTransport, store: store)
```

#### Protocols

There are two GraphQL over WebSocket protocols supported by Apollo iOS:
1. [`graphql-ws`](https://github.com/apollographql/subscriptions-transport-ws/blob/master/PROTOCOL.md) protocol which is implemented in the [subscriptions-transport-ws](https://github.com/apollographql/subscriptions-transport-ws) and [AWS AppSync](https://docs.aws.amazon.com/appsync/latest/devguide/real-time-websocket-client.html#handshake-details-to-establish-the-websocket-connection) libraries.
2. [`graphql-transport-ws`](https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md) protocol which is implemented in the [graphql-ws](https://github.com/enisdenjo/graphql-ws) library.

> **Note:** These protocols are **not** cross-compatible and you will need to know which is implemented in the service you're connecting to. All `WebSocket` initializers allow you to specify which protocol should be used.

#### Providing authorization tokens

In a standard HTTP operation, if authentication is necessary an `Authorization` header is often sent with requests. However, with a web socket, this can't be sent with every payload since a persistent connection is required.

For web sockets, the `connectingPayload` provides those parameters you would traditionally specify as part of the headers of your request.

Note that this must be set **when the `WebSocketTransport` is created**. If you need to update the `connectingPayload`, you will need to recreate the client using a new `webSocketTransport`.

```swift
let webSocketTransport: WebSocketTransport = {
  let url = URL(string: "ws://localhost:8080/websocket")!
  let webSocketClient = WebSocket(url: url, protocol: .graphql_transport_ws)
  let authPayload = ["authToken": myAuthToken]
  return WebSocketTransport(websocket: webSocketClient, connectingPayload: authPayload)
}()
```

### GraphQL subscriptions over HTTP

The default `NetworkTransport` is the [`RequestChainNetworkTransport`](https://www.apollographql.com/docs/ios/docc/documentation/apollo/requestchainnetworktransport) which has support for GraphQL queries, mutations and subscriptions. There is no special configuration required to support subscriptions over HTTP. Follow the instructions for [creating a client](../networking/client-creation) to use subscriptions over HTTP.
