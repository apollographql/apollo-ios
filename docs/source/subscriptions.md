---
title: Subscriptions
---

GraphQL supports [subscriptions](https://graphql.org/blog/subscriptions-in-graphql-and-relay/) to allow clients to be immediately updated when the data changes on a server.

The Apollo iOS library supports the use of subscriptions primarily through the use of [`ApolloWebSocket`](api/ApolloSQLite/README/), an optional additional library that uses popular iOS WebSocket library [`Starscream`](https://github.com/daltoniam/Starscream) under the hood to use WebSockets to connect to your GraphQL server.

Subscriptions are also supported through code generation: Any time your schema declares a subscription field, an operation conforming to `GraphQLSubscription` will be generated which allows you to pass in any parameters that subscription field takes. 

Once those operations are generated, you can use an instance of `ApolloClient` using a subscription-supporting network transport to subscribe, and continue to receive updates about changes until the subscription is cancelled.

## Transport types which support subscriptions

There are two different classes which conform to the [`NetworkTransport` protocol](api/Apollo/protocols/NetworkTransport/) within the `ApolloWebSocket` library: 

- **`WebSocketTransport`** sends all operations over a web socket. 
- **`SplitNetworkTransport`** hangs onto both a [`WebSocketTransport`](api/ApolloWebSocket/classes/WebSocketTransport/) instance and an [`UploadingNetworkTransport`](api/Apollo/protocols/UploadingNetworkTransport/) instance (usually [`HTTPNetworkTransport`](api/Apollo/classes/HTTPNetworkTransport/)) in order to create a single network transport that can use http for queries and mutations, and web sockets for subscriptions. 

Typically, you'll want to use `SplitNetworkTransport`, since this allows you to retain the single `NetworkTransport` setup and avoids any potential issues of using multiple client objects. 

## Sample subscription-supporting initializer 

Here is an example of setting up a singleton similar to the [Example Advanced Client Setup](initialization/#advanced-client-creation), but which uses a `SplitNetworkTransport` to support both subscriptions and queries: 

```swift
import Foundation
import Apollo
import ApolloWebSocket

// MARK: - Singleton Wrapper

class Apollo {
  static let shared = Apollo() 
    
  /// A web socket transport to use for subscriptions  
  private lazy var webSocketTransport: WebSocketTransport = {
    let url = URL(string: "ws://localhost:8080/websocket")!
    let request = URLRequest(url: url)
    return WebSocketTransport(request: request)
  }()
  
  /// An HTTP transport to use for queries and mutations
  private lazy var httpTransport: HTTPNetworkTransport = {
    let url = URL(string: "http://localhost:8080/graphql")!
    return HTTPNetworkTransport(url: url)
  }()

  /// A split network transport to allow the use of both of the above 
  /// transports through a single `NetworkTransport` instance.
  private lazy var splitNetworkTransport = SplitNetworkTransport(
    httpNetworkTransport: self.httpTransport, 
    webSocketNetworkTransport: self.webSocketTransport
  )

  /// Create a client using the `SplitNetworkTransport`.
  private(set) lazy var client = ApolloClient(networkTransport: self.splitNetworkTransport)
}
```

## Example usage of a subscription

Let's say you're using the [Sample Star Wars API](https://github.com/apollographql/apollo-ios/blob/master/Tests/StarWarsAPI/API.swift), and you want to use a view controller with a `UITableView` to show a list of reviews that will automatically update whenever a new review is added. 

You can use the [`ReviewAddedSubscription`](https://github.com/apollographql/apollo-ios/blob/25f860e04c44f1099f509120b8c256433632d131/Tests/StarWarsAPI/API.swift#L5386) to accomplish this: 

```swift
class ReviewViewController: UIViewController {

  private var subscription: Cancellable?
  private var reviewList = [Review]()
  
  // Assume data source and delegate are hooked up in Interface Builder
  @IBOutlet private var reviewTableView: UITableView!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the subscription variable up - be careful not to create a retain cycle!
    self.subscription = Apollo.shared.client
        .subscribe(subscription: ReviewAddedSubscription()) { [weak self] result in
          guard let self = self else {
            return 
          }
      
          switch result {
          case .success(let graphQLResult): 
            if let review = graphQLResult.data?.reviewAdded {
              // A review was added - append it to the list then reload the data.
              self.reviewList.append(review)
              self.reviewTableView.reloadData()
            } // else, something went wrong and you should check `graphQLResult.error` for problems
          case .failure(let error):
            // Not included here: Show some kind of alert
          }
    }
  }
  
  deinit {
    // Make sure the subscription is cancelled, if it exists, when this object is deallocated.
    self.subscription?.cancel()
  }
  
  // MARK: - Standard TableView Stuff
  
  func tableView(_ tableView: UITableView, 
                 numberOfRowsInSection section: Int) -> Int {
    return self.reviewList.count
  }
  
 func tableView(_ tableView: UITableView, 
                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // Assume `ReviewCell` is a cell for displaying reviews created elsewhere
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ReviewCell else {
      return UITableViewCell()
    } 
    
    let review = self.reviewList[indexPath.row]
    
    cell.episode = review.episode
    cell.stars = review.stars
    cell.commentary = review.commentary
    
    return cell
  }
}
```

Each time a review is added, the subscription's closure is called and if the proper data is included, the new data will be displayed immediately. 

Note that if you only wanted to be updated reviews for a specific episode, you could specify that episode in the initializer for `ReviewAddedSubscription`. 

## Subscriptions and authorization tokens

In a standard HTTP operation, if authentication is necessary an `Authorization` header is often sent with requests. However, with a web socket, this can't be sent with every payload since a persistent connection is required. 

For web sockets, the `connectingPayload` provides those parameters you would traditionally specify as part of the headers of your request.

Note that this must be set **when the `WebSocketTransport` is created**. If you need to update the `connectingPayload`, you will need to recreate the client using a new `webSocketTransport`. 

Assuming you (or your backend developers) have read [the authentication section](https://www.apollographql.com/docs/apollo-server/security/authentication/) and [subscriptions example / authentication over WebSocket](https://www.apollographql.com/docs/apollo-server/data/subscriptions/) of our backend documentation, you will need to initialize your `ApolloClient` instance as follows:

```swift
import Foundation
import Apollo
import ApolloWebSocket

// MARK: - Singleton Wrapper

let magicToken = "So long and thanks for all the fish"

class Apollo {
  static let shared = Apollo()
    
  /// A web socket transport to use for subscriptions
  // This web socket will have to provide the connecting payload which
  // initializes the connection as an authorized channel.
  private lazy var webSocketTransport: WebSocketTransport = {
    let url = URL(string: "ws://localhost:8080/websocket")!
    let request = URLRequest(url: url)
    let authPayload = ["authToken": magicToken]
    return WebSocketTransport(request: request, connectingPayload: authPayload)
  }()
  
  /// An HTTP transport to use for queries and mutations.
  private lazy var httpTransport: HTTPNetworkTransport = {
    let url = URL(string: "http://localhost:8080/graphql")!
    return HTTPNetworkTransport(url: url)
  }()

  /// A split network transport to allow the use of both of the above 
  /// transports through a single `NetworkTransport` instance.
  private lazy var splitNetworkTransport = SplitNetworkTransport(
    httpNetworkTransport: self.httpTransport, 
    webSocketNetworkTransport: self.webSocketTransport
  )

  /// Create a client using the `SplitNetworkTransport`.
  private(set) lazy var client = ApolloClient(networkTransport: self.splitNetworkTransport)
}
```



