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

Under the hood, this will create a client using `HTTPNetworkTransport` with a default configuration. You can then use this client from anywhere in your code with `Network.shared.apollo`. 

## Advanced Client Creation

For more advanced usage of the client, you can use this initializer which allows you to pass in an object conforming to the `NetworkTransport` protocol, as well as a store if you wish: 

```swift
public init(networkTransport: NetworkTransport, 
            store: ApolloStore = ApolloStore(cache: InMemoryNormalizedCache()))
```

The available implementations are: 

- **`HTTPNetworkTransport`**, which has a number of configurable options and uses standard HTTP requests to communicate with the server
- **`WebSocketTransport`**, which will send everything using a web socket. If you're using CocoaPods, make sure to install the `Apollo/WebSocket` sub-spec to access this. 
- **`SplitNetworkTransport`**, which will send subscription operations via a web socket and all other operations via HTTP. If you're using CocoaPods, make sure to install the `Apollo/WebSocket` sub-spec to access this. 

### Using `HTTPNetworkTransport`

The initializer for `HTTPNetworkTransport` has several properties which can allow you to get better information and finer-grained control of your HTTP requests and responses:

- `client` allows you to pass in a [subclass of `URLSessionClient`](#the-urlsessionclient-class) to handle managing a background-compatible URL session, and set up anything which needs to be done for every single request without alteration. 
- `sendOperationIdentifiers` allows you send operation identifiers along with your requests. **NOTE:** To send operation identifiers, Apollo types must be generated with `operationIdentifier`s or sending data will crash. Due to this restriction, this option defaults to `false`.
- `useGETForQueries` sends all requests of `query` type using `GET` instead of `POST`. This defaults to `false` to preserve existing behavior in older versions of the client. 
- `delegate` Can conform to one or many of several sub-protocols for `HTTPNetworkTransportDelegate`, detailed below.

### The URLSessionClient class

Since `URLSession` only supports use in the background using the delegate-based API, we have created our own `URLSessionClient` which handles the basics of setup for that. 

One thing to be aware of: Because setting up a delegate is only possible in the initializer for `URLSession`, you can only pass in a `URLSessionConfiguration`, **not** an existing `URLSession`, to this class's initializer. 

By default, instances of `URLSessionClient` use `URLSessionConfiguration.default` to set up their URL session, and instances of `HTTPNetworkTransport` use the default initializer for `URLSessionClient`.

The `URLSessionClient` class and most of its methods are `open` so you can subclass it if you need to override any of the delegate methods for the `URLSession` delegates we're using or you need to handle additional delegate scenarios.  

### Using `HTTPNetworkTransportDelegate`

This delegate includes several sub-protocols so that a single parameter can be passed no matter how many sub-protocols it conforms to. 

If you conform to a particular sub-protocol, you must implement all the methods in that sub-protocol, but we've tried to break things out in a sensible fashion. The sub-protocols are: 

#### `HTTPNetworkTransportPreflightDelegate`

This protocol allows pre-flight validation of requests, the ability to bail out before modifying the request, and the ability to modify the `URLRequest` with things like additional headers.

The `shouldSend` method is called before any modifications are made by `willSend`. This allows you do things like check that you have an authentication token in your keychain, and if not, prevent the request from hitting the network. When you cancel a request in `shouldSend`, you will receive an error indicating the request was cancelled. 

The `willSend` method is called with an `inout` parameter for the `URLRequest` which is about to be sent. There are several uses for this functionality. 

The first is simple logging of the request that's about to go out. You could theoretically do this in `shouldSend`, but particularly if you're making any changes to the request, you'd probably want to do your logging after you've finished those changes. 

The most common usage is to modify the request headers. Note that when modifying request headers, you'll need to make a copy of any pre-existing headers before adding new ones. See the [Example Advanced Client Setup](#example-advanced-client-setup) for details. 

You can also make any other changes you need to the request, but be aware that going too crazy with this may lead to Unexpected Behavior™. 

#### `HTTPNetworkTransportTaskCompletedDelegate`

This delegate allows you to peer in to the raw data returned to the `URLSession`. This is helpful both for logging what you're getting directly from your server and for grabbing any information out of the raw response, such as updated authentication tokens, which would be removed before parsing is completed.

#### `HTTPNetworkTransportRetryDelegate`

This delegate allows you to asynchronously determine whether to retry your request. This is asynchronous to allow for things like re-authenticating your user. 

When you decide to retry, the `send` operation for your `GraphQLOperation` will be retried. This means you'll get brand new callbacks from `HTTPNetworkTransportPreflightDelegate` to update your headers again as if it was a totally new request. Therefore, the parameter for the completion closure is a simple `true`/`false` option: Pass `true` to retry, pass `false` to error out. 

**IMPORTANT**: Do not call `true` blindly in the completion closure. If your server is returning 500s or if the user has no internet, this will create an infinite loop of requests that are retrying. This **will** kill your user's battery, and might also run up the bill on their data plan. Make sure to only request a retry when there's something your code can actually do about the problem!

### Example Advanced Client Setup

Here's a sample of a singleton using an advanced client which handles all three sub-protocols. This code assumes you've got the following classes in your own code (these are **not** part of the Apollo library): 

- **`UserManager`** to check whether the user is logged in, perform associated checks on errors and responses to see if they need to reauthenticate, and perform reauthentication
- **`Logger`** to handle printing logs based on their level, and which supports `.debug`, `.error`, or `.always` log levels.

```swift
import Foundation
import Apollo

// MARK: - Singleton Wrapper

class Network {
  static let shared = Network() 
  
  // Configure the network transport to use the singleton as the delegate. 
  private lazy var networkTransport: HTTPNetworkTransport = {
    let transport = HTTPNetworkTransport(url: URL(string: "http://localhost:8080/graphql")!)
    transport.delegate = self
    return transport
  }()
    
  // Use the configured network transport in your Apollo client.
  private(set) lazy var apollo = ApolloClient(networkTransport: self.networkTransport)
}

// MARK: - Pre-flight delegate 

extension Network: HTTPNetworkTransportPreflightDelegate {

  func networkTransport(_ networkTransport: HTTPNetworkTransport, 
                          shouldSend request: URLRequest) -> Bool {
    // If there's an authenticated user, send the request. If not, don't.                        
    return UserManager.shared.hasAuthenticatedUser
  }
  
  func networkTransport(_ networkTransport: HTTPNetworkTransport, 
                        willSend request: inout URLRequest) {
                        
    // Get the existing headers, or create new ones if they're nil
    var headers = request.allHTTPHeaderFields ?? [String: String]()

    // Add any new headers you need
    headers["Authorization"] = "Bearer \(UserManager.shared.currentAuthToken)"
  
    // Re-assign the updated headers to the request.
    request.allHTTPHeaderFields = headers
    
    Logger.log(.debug, "Outgoing request: \(request)")
  }
}

// MARK: - Task Completed Delegate

extension Network: HTTPNetworkTransportTaskCompletedDelegate {
  func networkTransport(_ networkTransport: HTTPNetworkTransport,
                        didCompleteRawTaskForRequest request: URLRequest,
                        withData data: Data?,
                        response: URLResponse?,
                        error: Error?) {
    Logger.log(.debug, "Raw task completed for request: \(request)")
                        
    if let error = error {
      Logger.log(.error, "Error: \(error)")
    }
    
    if let response = response {
      Logger.log(.debug, "Response: \(response)")
    } else {
      Logger.log(.error, "No URL Response received!")
    }
    
    if let data = data {
      Logger.log(.debug, "Data: \(String(describing: String(bytes: data, encoding: .utf8)))")
    } else {
      Logger.log(.error, "No data received!")
    }
  }
}

// MARK: - Retry Delegate

extension Network: HTTPNetworkTransportRetryDelegate {

  func networkTransport(_ networkTransport: HTTPNetworkTransport,
                        receivedError error: Error,
                        for request: URLRequest,
                        response: URLResponse?,
                        continueHandler: @escaping (_ action: HTTPNetworkTransport.ContinueAction) -> Void) {
    // Check if the error and/or response you've received are something that requires authentication
    guard UserManager.shared.requiresReAuthentication(basedOn: error, response: response) else {
      // This is not something this application can handle, do not retry.
      continueHandler(.fail(error))
      return
    }
    
    // Attempt to re-authenticate asynchronously
    UserManager.shared.reAuthenticate { (reAuthenticateError: Error?) in 
      // If re-authentication succeeded, try again. If it didn't, don't.
      if let reAuthenticateError = reAuthenticateError {
        continueHandler(.fail(reAuthenticateError)) // Will return re authenticate error to query callback 
        // or (depending what error you want to get to callback)
        continueHandler(.fail(error)) // Will return original error
      } else {
        continueHandler(.retry)
      }
    }
  }
}
```

An example of setting up a client which can handle web sockets and subscriptions is included in the [subscription documentation](subscriptions/#sample-subscription-supporting-initializer). 
