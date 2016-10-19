---
title: Creating a client
---

In most cases, you'll want to create a single shared instance of `ApolloClient` and point it at your GraphQL server. The easiest way to do this is to define a global variable in `AppDelegate.swift`:

```swift
let apollo = ApolloClient(url: URL(string: "http://localhost:8080/graphql")!)
```

<h2 id="adding-headers">Adding additional headers</h2>

If you need to add additional headers to requests, to include authentication details for example, you can create your own `URLSessionConfiguration` and use this to configure an `HTTPNetworkTransport`.

```swift
let configuration = URLSessionConfiguration.default
// Add additional headers as needed
configuration.httpAdditionalHeaders = ["Authorization": "Bearer <token>"]

let url = URL(string: "http://localhost:8080/graphql")!

let apollo = ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
```
