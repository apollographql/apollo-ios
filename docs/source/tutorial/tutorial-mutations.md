---
title: Working with Mutations
---

In this tutorial, you'll learn how to build authenticated mutations and handle information returned from those mutations, and use that knowledge to book and cancel some trips for yourself. 

## Adding authentication handling

Before you start booking, you need to be able to pass your authentication token along to Apollo. To do that, you'll dig a little deeper into how the Apollo client works. 

If you need to do anything before a request hits the and after Apollo has done most of the configuration for you, there's a delegate protocol called `HTTPNetworkTransportPreflightDelegate` which will allow you to do that. 

Open `Network.swift` and add an extension to conform to that delegate: 

```swift
extension Network: HTTPNetworkTransportPreflightDelegate { 

}
```

You'll get an error telling you that protocol stubs must be implemented, and asking you if you want to fix this. Click "Fix."

![Do you wish to add protocol stubs with fix button](images/preflight_delegate_add_protocol_stubs.png)

Two protocol methods will be added: `networkTransport(_:shouldSend:)` and `networkTransport(_:willSend:)`. 

The `shouldSend` method is called to allow you to make sure a request should go out to the network all. This is useful for things like checking that your user is logged in before trying to make a request. 

However, you're not going to be using that functionality in this application. Update the method to have it return `true` all the time.

```swift  
func networkTransport(_ networkTransport: HTTPNetworkTransport, 
											shouldSend request: URLRequest) -> Bool {
	return true
}
```

The `willSend` request is the last thing which can manipulate the request before it goes out to the network. Since the request is passed as an `inout` variable, you can manipulate its contents directly. 

Update the `willSend` method to add your token as the value for the `Authorization` header: 

```swift
func networkTransport(_ networkTransport: HTTPNetworkTransport, 
											willSend request: inout URLRequest) {
	let keychain = KeychainSwift()
	if let token = keychain.get(LoginViewController.loginKeychainKey) {
		request.addValue(token, forHTTPHeaderField: "Authorization")
	} // else do nothing
}
```

Next, you need to make sure that Apollo knows that this delegate exists. In order to do that, you need to do a step that so far, the Apollo client has been doing for you under the hood: Instantiating the `HTTPNetworkTransport`, which is the default way of talking to your server.

In the primary declaration of `Network`, update your `lazy var` to create this transport and set the `Network` object as its delegate, then pass it through to the `ApolloClient`: 

```swift
private(set) lazy var apollo: ApolloClient = {
  let httpNetworkTransport = HTTPNetworkTransport(url: URL(string: "https://apollo-fullstack-tutorial.herokuapp.com/")!, 
																								  delegate: self)
        
  return ApolloClient(networkTransport: httpNetworkTransport)
}()
```

Click on the line numbers to add a breakpoint at the line where you're instantiating the `Keychain`: 

![adding a breakpoint](images/preflight_delegate_breakpoint.png)

Build and run the application. Whenever a network request goes out, that breakpoint should now get hit. Now if you're logged in, your token will be sent to the server whenever you make a request. 

Now it's time to book a trip! 🚀

## Adding the booking mutation

In GraphiQL, open the Docs tab and take a look at the `bookTrips` mutation.

```graphql
mutation BookTrip($tripID:ID!) {
  bookTrips(launchIds:[$tripID]) {
    success
    message
  }
}
```

In the `Query Variables` section of GraphiQL, add the identifier 

```json
{"id":"25"}
```

In the `HTTP Headers` section of GraphiQL, add the following:

```json
{ "Authorization" :"(your token)"}
```

In `DetailViewController.swift`, add a new method to book your trip based on the flight's ID:

```swift
private func bookTrip(with id: GraphQLID) {
  Network.shared.apollo.perform(mutation: BookTripMutation(id: id)) { [weak self] result in
    guard let self = self else {
      return 
    }
    switch result {
    case .success(let graphQLResult):
      if let bookingResult = graphQLResult.data?.bookTrips {
        // TODO
      }

      if let errors = graphQLResult.errors {
        self.showAlertForErrors(errors)
      }
    case .failure(let error):
      self.showAlert(title: "Network Error",
                     message: error.localizedDescription)
    }
  }
}
```

And add a similar method to cancel the trip based on the flight's ID: 

```swift
private func cancelTrip(with id: GraphQLID) {
  Network.shared.apollo.perform(mutation: CancelTripMutation(id: id)) { [weak self] result in
    guard let self = self else {
      return
    }
    switch result {
    case .success(let graphQLResult):
      if let cancelResult = graphQLResult.data?.cancelTrip {
        if cancelResult.success {
          // TODO
      }

      if let errors = graphQLResult.errors {
        self.showAlertForErrors(errors)
      }
    case .failure(let error):
      self.showAlert(title: "Network Error",
                     message: error.localizedDescription)
    }
  }
}
```

```swift
if launch.isBooked {
  self.cancelTrip(with: launch.id)
} else {
  self.bookTrip(with: launch.id)
}
```

In `bookTrip`, replace the `TODO` with code to handle what comes back in the `success` property: 


```swift
if bookingResult.success {
	self.showAlert(title: "Success!",
							   message: bookingResult.message ?? "Trip booked successfully")
} else {
  self.showAlert(title: "Could not book trip", 
							   message: bookingResult.message ?? "Unknown failure.")
}
```

In `cancelTrip`, replace the `TODO` with code to handle what comes back in that mutation's `success` property: 

```swift
if cancelResult.success {
	self.showAlert(title: "Trip cancelled",  
		             message: cancelResult.message ?? "Your trip has been officially cancelled.")
} else {
	self.showAlert(title: "Could not cancel trip", 
			           message: cancelResult.message ?? "Unknown failure.")
}
```

## Forcing a fetch from the network

Update the `loadLaunchDetails` method to take a parameter to determine if it should force reload, as well. 

If it should force reload, update the cache policy from the default `.returnCacheDataElseFetch`, which will return data from the cache if it exists, to `.fetchIgnoringCacheCompletely` which  will force the network to go out and 

```swift
private func loadLaunchDetails(forceReload: Bool = false) {
  guard
    let launchID = self.launchID,
    (forceReload || launchID != self.launch?.id) else {
        // This is the launch we're alrady displaying, or the ID is nil.
        return
  }
        
  let cachePolicy: CachePolicy
  if forceReload {
    cachePolicy = .fetchIgnoringCacheCompletely
  } else {
    cachePolicy = .returnCacheDataElseFetch
  } 
        
  Network.shared.apollo.fetch(query: LaunchDetailsQuery(id: launchID), cachePolicy: cachePolicy) { [weak self] result in
	  // Rest of this remains the same
  }
}
```

Add the following to both the `bookingResult.success` and `cancelResult.success` branches in their respective methods:

```swift
self.loadLaunchDetails(forceReload: true)
```

## Updating the cache yourself