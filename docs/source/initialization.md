---
title: Creating a client
---

## Basic Client Creation

In most cases, you'll want to create a single shared instance of `ApolloClient` and point it at your GraphQL server. The easiest way to do this is to create a singleton:

```swift
class Network {
  static let shared = Network() 
    
  private(set) lazy var apollo = ApolloClient(url: URL(string: "http://localhost:8080/graphql")!)
}
```

Under the hood, this will create a client using `RequestChainNetworkTransport` with a default configuration. You can then use this client from anywhere in your code with `Network.shared.apollo`.

## Advanced Client Creation

For more advanced usage of the client, you can use this initializer which allows you to pass in an object conforming to the `NetworkTransport` protocol, as well as a store: 

```swift
public init(networkTransport: NetworkTransport, 
            store: ApolloStore)
```

The available implementations are: 

- **`RequestChainNetworkTransport`**, which passes a request through a chain of interceptors that can do work both before and after going to the network, and uses standard HTTP requests to communicate with the server
- **`WebSocketTransport`**, which will send everything using a web socket. If you're using CocoaPods, make sure to install the `Apollo/WebSocket` sub-spec to access this. 
- **`SplitNetworkTransport`**, which will send subscription operations via a web socket and all other operations via HTTP. If you're using CocoaPods, make sure to install the `Apollo/WebSocket` sub-spec to access this. 

### Using `RequestChainNetworkTransport`

The initializer for `RequestChainNetworkTransport` has several properties which can allow you to get better information and finer-grained control of your HTTP requests and responses:

- `interceptorProvider`: The interceptor provider to use when constructing chains for a request. See below for details on interceptor providers.
- `endpointURL`: The GraphQL endpoint URL to use for all calls.
- `additionalHeaders`: Any additional headers that should be automatically added to **every** request, such as an API key or a language setting. Headers that should not be sent with every request (or whose values can change across requests) should be configured through an interceptor. Defaults to an empty dictionary. 
- `autoPersistQueries`: Pass `true` if [Automatic Persisted Queries](https://www.apollographql.com/docs/apollo-server/performance/apq/) should be used to send an operation's hash instead of the full operation body by default. **NOTE:** To use APQs, you need to make sure to generate your types with operation identifiers. In your Swift Script, make sure to pass a non-nil `operationIDsURL` to have this output. Due to this restriction, this option defaults to `false`. You will also want to make sure you're using the `AutomaticPersistedQueryInterceptor` in your chain after a network request has come back to handle known APQ errors. 
- `requestCreator`: The `RequestCreator` object to use to build your `URLRequest`. Defaults to the provided `ApolloRequestCreator` implementation.
- `useGETForQueries`: Sends all requests of `query` type using `GET` instead of `POST`. This is mostly useful for large companies taking advantage of CDNs (Content Distribution Networks) that allow local caches instead of going all the way to your server for data which does not change often. This defaults to `false` to preserve existing behavior in older versions of the client. 
- `useGETForPersistedQueryRetry`: Pass `true` to use `GET` instead of `POST` for a retry of a persisted query. Defaults to `false`. 

### How the `RequestChain` works

A `RequestChain` is constructed using an array of interceptors, to be run in the order given, and handles calling back on a specified `DispatchQueue` after all work is complete. 

A chain is started by calling `kickoff`. This causes the chain to start running through the chain of interceptors in order.

In each interceptor, work can be performed asynchronously on any thread. To move along to the next interceptor in the chain, call `proceedAsync`. 

By default, when the interceptor chain ends, if you have a parsed result available, this result will be returned to the caller.

If you want to directly return a value to the caller, call `returnValueAsync`. If you want to have the chain return an error, call `handleErrorAsync`. Both of these methods will call your completion block on the queue specified when creating the `RequestChain`.

Note that calling `returnValue` does **NOT** forbid calling `handleError` - or calling each more than once. For example, if you want to return data from the cache to the UI while a network fetch executes, you'd want to make sure that `returnValueAsync` was called twice. 

The chain also includes a `retry` mechanism, which will go all the way back to the first interceptor in the chain, then start running through the interceptors again. 

**IMPORTANT**: Do not call `retry` blindly. If your server is returning 500s or if the user has no internet, this will create an infinite loop of requests that are retrying (especially if you're not using something like the `MaxRetryInterceptor` to limit how many retries are made). This **will** kill your user's battery, and might also run up the bill on their data plan. Make sure to only request a retry when there's something your code can actually do about the problem!

In the `RequestChainNetworkTransport`, each request creates an individual request chain, and uses an `InterceptorProvider` to figure out which interceptors should be handed to that chain. 

### Setting up `ApolloInterceptor` chains with `InterceptorProvider`

Every operation sent through a `RequestChainNetworkTransport` will be passed into an `InterceptorProvider` before going to the network. This protocol creates an array of interceptors for use by a single request chain based on the provided operation. 

Interceptors themselves are designed to be **short-lived**. A new set of interceptors should be provided for each request in order to avoid having multiple calls hitting the same instance of a single interceptor at the same time. 

Holding references to individual interceptors (outside of test verification) is generally not recommended. Instead, you can create an interceptor that holds on to a longer-lived object, and the provider can pass this object into each new set of interceptors. That way an interceptor itself can be easily disposable, but you don't have to recreate the underlying object doing heavier work.

There are two default implementations for `InterceptorProvider` provided for you:

- `LegacyInterceptorProvider` works with our existing parsing and caching system and tries to replicate the experience of using the old `HTTPNetworkTransport` as closely as possible. It takes a `URLSessionClient` and an `ApolloStore` to pass into the interceptors it uses. **This is the provider that developers will want to use at this time.** You can also sublcass this interceptor provider if you only need to insert interceptors at the beginning or end of the chain rather than intersperse them throughout.
- `CodableInterceptorProvider` is a **work in progress**, which is going to be for use with our [Swift Codegen Rewrite](https://github.com/apollographql/apollo-ios/projects/2), (which, I swear, will eventually be finished). It is not suitable for use at this time. It takes a `URLSessionClient`, a `FlexibleDecoder` (something can decode anything that conforms to `Decodable`). It does not support caching yet.

If you wish to make your own `InterceptorProvider` instead of using the provided one, you can take advantage of several interceptors that are included in the library: 

#### Pre-network
- `MaxRetryInterceptor` checks to make sure a query has not been tried more than a maximum number of times. 
- `LegacyCacheReadInterceptor` reads from a provided `ApolloStore` based on the `cachePolicy`, and will return a result if one is found.

#### Network 
- `NetworkFetchInterceptor` takes a `URLSessionClient` and uses it to send the prepared `HTTPRequest` (or subclass thereof) to the server. 

#### Post-Network

- `ResponseCodeInterceptor` checks to make sure a valid response status code has been returned. **NOTE**: Most errors at the GraphQL level are returned with a `200` status code and information in the `errors` array per the GraphQL Spec. This interceptor helps with things like server errors and errors that are returned by middleware. [This article on error handling in GraphQL](https://medium.com/@sachee/200-ok-error-handling-in-graphql-7ec869aec9bc) is a really helpful look at how and why these differences occur. 
- `AutomaticPersistedQueryInterceptor` handles checking responses to see if an error is because an automatic persisted query failed, and the full operation needs to be resent to the server.
- `LegacyParsingInterceptor` parses code generated by our current Typescript-based code generation. 
- `LegacyCacheWriteInterceptor` writes to a provided `ApolloStore` based on code from our current Typescript-based code generation.
- `CodableParsingError` is a **work in progress** which will parse `Codable` results form the Swift Codegen Rewrite.

#### The Additional Error Interceptor

The `InterceptorProvider` can optionally provide an `additionalErrorInterceptor` which will get called before returning an error to the caller, regardless of the origin of the error. This is mostly useful for logging and tracing errors. 

Note that if there is a particular _expected_ error, such as an expired authentication token, that type of error is best handled by having an interceptor within the interceptor chain, which will allow you to retry your request much more easily. 

### The URLSessionClient class

Since `URLSession` only supports use in the background using the delegate-based API, we have created our own `URLSessionClient` which handles the basics of setup for that. 

One thing to be aware of: Because setting up a delegate is only possible in the initializer for `URLSession`, you can only pass in a `URLSessionConfiguration`, **not** an existing `URLSession`, to this class's initializer. 

By default, instances of `URLSessionClient` use `URLSessionConfiguration.default` to set up their URL session, and instances of `LegacyInterceptorProvider` and `CodableInterceptorProvider` use the default initializer for `URLSessionClient`.

The `URLSessionClient` class and most of its methods are `open` so you can subclass it if you need to override any of the delegate methods for the `URLSession` delegates we're using or you need to handle additional delegate scenarios.  

### Example Advanced Client Setup

Here's a sample how to use an advanced client with some custom interceptors. This code assumes you've got the following classes in your own code (**these are not part of the Apollo library**): 

- **`UserManager`** to check whether the user is logged in, perform associated checks on errors and responses to see if they need to renew their token, and perform that renewal
- **`Logger`** to handle printing logs based on their level, and which supports `.debug`, `.error`, or `.always` log levels.

#### Example interceptors

##### Sample `UserManagementInterceptor` 

An interceptor which checks if the user is logged in and then renews the user's token if it is expired asynchronously before continuing the chain, using the above-mentioned `UserManager` class: 

```swift
class UserManagementInterceptor: ApolloInterceptor {
    
    enum UserError: Error {
        case noUserLoggedIn
    }
    
    /// Helper function to add the token then move on to the next step
    private func addTokenAndProceed<Operation: GraphQLOperation>(
        _ token: Token,
        to request: HTTPRequest<Operation>,
        chain: RequestChain,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
        
        request.addHeader(name: "Authorization", value: "Bearer \(token.value)")
        chain.proceedAsync(request: request,
                           response: response,
                           completion: completion)
    }
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
        
        guard let token = UserManager.shared.token else {
            // In this instance, no user is logged in, so we want to call 
            // the error handler, then return to prevent further work
            chain.handleErrorAsync(UserError.noUserLoggedIn,
                                   request: request,
                                   response: response,
                                   completion: completion)
            return
        }
        
        // If we've gotten here, there is a token!
        if token.isExpired {
            // Call an async method to renew the token
            UserManager.shared.renewToken { [weak self] tokenRenewResult in
                guard let self = self else {
                    return
                }
                
                switch tokenRenewResult {
                case .failure(let error):
                    // Pass the token renewal error up the chain, and do 
                    // not proceed further. Note that you could also wrap this in a 
                    // `UserError` if you want.
                    chain.handleErrorAsync(error,
                                           request: request,
                                           response: response,
                                           completion: completion)
                case .success(let token):
                    // Renewing worked! Add the token and move on
                    self.addTokenAndProceed(token,
                                            to: request,
                                            chain: chain,
                                            response: response,
                                            completion: completion)
                }
            }
        } else {
            // We don't need to wait for renewal, add token and move on
            self.addTokenAndProceed(token,
                                    to: request,
                                    chain: chain,
                                    response: response,
                                    completion: completion)
        }
    }
}
```

##### Sample `RequestLoggingInterceptor` 

An interceptor which logs the outgoing request using the above-mentioned `Logger` class, then moves on:

```swift
class RequestLoggingInterceptor: ApolloInterceptor {
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
        
        Logger.log(.debug, "Outgoing request: \(request)")
        chain.proceedAsync(request: request,
                           response: response,
                           completion: completion)
    }
}
```

##### Sample `‌ResponseLoggingInterceptor`

An interceptor using the above-mentioned `Logger` which logs the incoming response if it exists, and moves on. 

Note that this is an example of an interceptor which can both proceed **and** throw an error - we don't necessarily want to stop processing if this was set up in the wrong place, but we do want to know about it. 

```swift
class ResponseLoggingInterceptor: ApolloInterceptor {
    
    enum ResponseLoggingError: Error {
        case notYetReceived
    }
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
        
        defer {
            // Even if we can't log, we still want to keep going.
            chain.proceedAsync(request: request,
                               response: response,
                               completion: completion)
        }
        
        guard let receivedResponse = response else {
            chain.handleErrorAsync(ResponseLoggingError.notYetReceived,
                                   request: request,
                                   response: response,
                                   completion: completion)
            return
        }
        
        Logger.log(.debug, "HTTP Response: \(receivedResponse.httpResponse)")
        
        if let stringData = String(bytes: receivedResponse.rawData, encoding: .utf8) {
            Logger.log(.debug, "Data: \(stringData)")
        } else {
            Logger.log(.error, "Could not convert data to string!")
        }
    }
}
```

#### Example Custom Interceptor Provider

This `InterceptorProvider` uses all of the interceptors that (as of this writing) are in the default `LegacyInterceptorProvider`, interspersed at the appropriate points with the sample interceptors created above: 

```swift
struct NetworkInterceptorProvider: InterceptorProvider {
    
    // These properties will remain the same throughout the life of the `InterceptorProvider`, even though they
    // will be handed to different interceptors.
    private let store: ApolloStore
    private let client: URLSessionClient
    
    init(store: ApolloStore,
         client: URLSessionClient) {
        self.store = store
        self.client = client
    }
    
    func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        return [
            MaxRetryInterceptor(),
            LegacyCacheReadInterceptor(store: self.store),
            UserManagementInterceptor(),
            RequestLoggingInterceptor(),
            NetworkFetchInterceptor(client: self.client),
            ResponseLoggingInterceptor(),
            ResponseCodeInterceptor(),
            LegacyParsingInterceptor(cacheKeyForObject: self.store.cacheKeyForObject),
            AutomaticPersistedQueryInterceptor(),
            LegacyCacheWriteInterceptor(store: self.store)
        ]
    }
}
```

#### Example Network Singleton Setup

This is the equivalent of what you'd set up in the [Basic Client Creation](#basic-client-creation) section, and what you'd call into from your application.

```swift
class Network {
  static let shared = Network()
  
  private(set) lazy var apollo: ApolloClient = {
      // The cache is necessary to set up the store, which we're going to hand to the provider
      let cache = InMemoryNormalizedCache()
      let store = ApolloStore(cache: cache)
      
      let client = URLSessionClient()
      let provider = NetworkInterceptorProvider(store: store, client: client)
      let url = URL(string: "https://apollo-fullstack-tutorial.herokuapp.com/")!

      let requestChainTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                               endpointURL: url)
                                                               

      // Remember to give the store you already created to the client so it 
      // doesn't create one on its own                                                               
      return ApolloClient(networkTransport: requestChainTransport,
                          store: store)
  }()
}
```


An example of setting up a client which can handle web sockets and subscriptions is included in the [subscription documentation](subscriptions/#sample-subscription-supporting-initializer). 
