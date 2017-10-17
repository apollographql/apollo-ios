---
title: Creating a client
---

In most cases, you'll want to create a single shared instance of `ApolloClient` and point it at your GraphQL server. The easiest way to do this is to define a global variable in `AppDelegate.swift`:

```swift
let apollo = ApolloClient(url: URL(string: "http://localhost:8080/graphql")!)
```

<h2 id="adding-headers">Adding additional headers</h2>

If you need to add additional headers to requests, to include authentication details for example, you can create your own `URLSessionConfiguration` and use this to configure an `HTTPNetworkTransport`. If you want to define the client as a global variable, you can use an immediately invoked closure here:

```swift
let apollo: ApolloClient = {
  let configuration = URLSessionConfiguration.default
  // Add additional headers as needed
  configuration.httpAdditionalHeaders = ["Authorization": "Bearer <token>"] // Replace `<token>`

  let url = URL(string: "http://localhost:8080/graphql")!

  return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
}()
```

> Right now, additional headers can only be specified when creating a client. We're working on a better solution for dynamic configuration of the network transport, including the ability to retry requests that failed after refreshing an access token. Please chime in on https://github.com/apollographql/apollo-ios/issues/37 to help shape the design of this feature or to contribute to it.
