---
title: Subscriptions
---

GraphQL supports [subscriptions](https://graphql.org/blog/subscriptions-in-graphql-and-relay/) to allow clients to be immediately updated when the data changes on a server.

GraphQL subscriptions are distinct from [watching queries](./queries#watching-queries). A query watcher is only updated when new data is written to the local cache (usually by another network operation). A GraphQL subscription is a long-lived request that may receive updated data from the server continuously. Apollo iOS implements subscriptions using a web socket connection.

Apollo iOS requires subscription support to be enabled on your `ApolloClient` using the `ApolloWebSocket` library to work. See the [Enabling GraphQL subscription support](#enabling-graphql-subscription-support) section for instructions on how your application can support GraphQL subscriptions.

## Performing mutations

Apollo iOS Subscriptions are also supported through code generation. Similar to queries, subscriptions are represented by instances of generated classes, conforming to the `GraphQLSubscription` protocol.

```graphql title="ReviewAddedSubscription.graphql"
subscription ReviewAdded {
  reviewAdded {
    id
    stars
  }
}
```

Once those operations are generated, you can use a `ApolloClient.subscribe(subscription:)` using a subscription-supporting network transport to subscribe, and continue to receive updates about changes until the subscription is cancelled.

```swift
let subscription = client.subscribe(subscription: ReviewAddedSubscription()) { result in
  guard let data = try? result.get().data else { return }
  print(data.reviews.map { $0.stars })
}
```

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

The Apollo iOS library supports the use of subscriptions via [`ApolloWebSocket`](api/ApolloSQLite/README/), an optional additional library. `ApolloWebSocket` allows you to use web sockets to connect to your GraphQL server, enabling GraphQL subscriptions. To include `ApolloWebSocket`, add it as a dependency following the instructions in the [Getting Started](./../get-started) guide.

### Creating an `ApolloClient` with subscription support

In order to support GraphQL subscriptions, your `ApolloClient` must be initialized with a [`NetworkTransport`](https://www.apollographql.com/docs/ios/docc/documentation/apollo/networktransport) that supports creating a web socket connection.

Within the `ApolloWebSocket` library, there are two classes which conform to the [`NetworkTransport` protocol](https://www.apollographql.com/docs/ios/docc/documentation/apollo/networktransport):

- **`WebSocketTransport`** sends all operations over a web socket.
- **`SplitNetworkTransport`** hangs onto both a [`WebSocketTransport`](api/ApolloWebSocket/classes/WebSocketTransport/) instance and an [`UploadingNetworkTransport`](api/Apollo/protocols/UploadingNetworkTransport/) instance (usually [`RequestChainNetworkTransport`](api/Apollo/classes/RequestChainNetworkTransport/)) in order to create a single network transport that can use http for queries and mutations, and web sockets for subscriptions.

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

### GraphQL over WebSocket protocols

There are two protocols supported by apollo-ios:
1. [`graphql-ws`](https://github.com/apollographql/subscriptions-transport-ws/blob/master/PROTOCOL.md) protocol which is implemented in the [subscriptions-transport-ws](https://github.com/apollographql/subscriptions-transport-ws) and [AWS AppSync](https://docs.aws.amazon.com/appsync/latest/devguide/real-time-websocket-client.html#handshake-details-to-establish-the-websocket-connection) libraries.
2. [`graphql-transport-ws`](https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md) protocol which is implemented in the [graphql-ws](https://github.com/enisdenjo/graphql-ws) library.

It is important to note that the protocols are not cross-compatible and you will need to know which is implemented in the service you're connecting to. All `WebSocket` initializers allow you to specify which GraphQL over WebSocket protocol should be used.

### Providing authorization tokens

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
