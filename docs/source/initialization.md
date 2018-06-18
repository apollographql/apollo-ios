---
title: Creating a client
---

In most cases, you'll want to create a single shared instance of `ApolloClient` and point it at your GraphQL server. The easiest way to do this is to define a global variable in `AppDelegate.swift`:

```swift
let apollo = ApolloClient(url: URL(string: "http://localhost:8080/graphql")!)
```

<h2 id="adding-headers">Adding additional headers</h2>

If you need to add additional headers to requests, to include authentication details for example, you need to create an instance of `HTTPNetworkTransport` and use `set(httpHeaders:)`. can be called at any time, just keep in mind that it will override any previously set headers.

```swift
let url = URL(string: "http://localhost:8080/graphql")!

let networkTransport = HTTPNetworkTransport(url: url)
let apollo = ApolloClient(networkTransport: networkTransport)

networkTransport.set(httpHeaders: ["Authorization": "Bearer <token>"]) // Replace `<token>`
```
