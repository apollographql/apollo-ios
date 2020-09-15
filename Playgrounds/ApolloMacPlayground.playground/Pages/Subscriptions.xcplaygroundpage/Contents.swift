//: [Mutations](@previous)
import Foundation
import Apollo
import ApolloWebSocket
import StarWarsAPI
import PlaygroundSupport
/*:
## Subscriptions
 
Subscriptions allow you to use a web socket connection to subscribe to updates to a particular query.
 
Your web backend must declare support for subscriptions in the Schema just like it declares support for mutations, these cannot be used to subscribe to listen to changes to arbitrary queries.
*/

/*:
## Network Transport and Client Setup
 
To use subscriptions, you need to have a `NetworkTransport` implementation which supports them. Fortunately, with the `ApolloWebSocket` package, there are two!
 
The first is the `WebSocketTransport`, which works with the web socket, and the second is the `SplitNetworkTransport`, which uses a web socket for subscriptions but a normal `HTTPNetworkTransport` for everything else.

In this instance, we'll use a `SplitNetworkTransport` since we want to demonstrate subscribing to changes, but we need to also be able to send changes for that subscription to come through.
*/

//:First, setup the `HTTPNetworkTransport`:

let url = URL(string: "http://localhost:8080/graphql")!
let normalTransport = HTTPNetworkTransport(url: url)

//: Next, set up the `WebSocketTransport` to talk to the websocket endpoint. Note that this may take a different URL, sometimes with a `ws` prefix, than your normal http endpoint:

let webSocketURL = URL(string: "ws://localhost:8080/websocket")!
let webSocketTransport = WebSocketTransport(request: URLRequest(url: webSocketURL))

//: Then, set up the split transport with the two transports you've just created:

let splitTransport = SplitNetworkTransport(httpNetworkTransport: normalTransport, webSocketNetworkTransport: webSocketTransport)

//: Finally, instantiate your client with the split transport:

let client = ApolloClient(networkTransport: splitTransport)

/*:
 ### Creating a subscription
 
 Any `.graphql` files with a `subscription` in them will cause a subscription object to be generated. Instantiate that object to create the subscription:
 */

let subscription = ReviewAddedSubscription()

//: We'll create a couple vars here to help keep track of how many times we want to do this:

var resultsReceived = 0
var loops = 5

//: Then, start your subscription, and add a closure that you want to have called every time the web socket receives a message for that subscription:
client.subscribe(subscription: subscription) { result in
    print()
    switch result {
    case .success(let graphQLResult):
        if let errors = graphQLResult.errors {
            print("Subscription graphQL errors: \(errors)")
        }
        
        if let review = graphQLResult.data?.reviewAdded {
            print("--- Got review from subscription! ---")
            print("Episode: \(review.episode?.rawValue ?? "(n/a)")")
            print("Stars: \(review.stars)")
            print("Commentary: \(review.commentary ?? "none:")")
        }
    case .failure(let error):
        // If this happens, something's gone wrong either at the network level before the GraphQL server could respond, or parsing has failed completely at the WebSocket level.
        print("Subscription network error: \(error)")
    }
    
    resultsReceived += 1
    
    if let episode = subscription.episode {
        // If your subscription has specified an episode, only reviews for that episode should come in.
        if resultsReceived == loops {
            print("\nGot \(loops) \(episode.rawValue) reviews, finishing execution")
            PlaygroundPage.current.finishExecution()
        }
    } else {
        // If you did not specify an episode, you'll get all reviews for all episodes.
        let expectedTotalReviews = loops * Episode.allCases.count
        if resultsReceived == expectedTotalReviews {
            print("\nGot \(expectedTotalReviews) reviews of all episodes, finishing execution")
            PlaygroundPage.current.finishExecution()
        }
    }
}

/*:
### Sending data to the subscription
 
Now that the subscription is listening for new reviews, let's add a bunch! We'll make a bunch of loops over every episode, to post reviews for a bunch of different episodes:
*/

for _ in 0..<loops {
    for episode in Episode.allCases {
        let review = ReviewInput(stars: 5, commentary: "Loved \(episode.rawValue)", favoriteColor: nil)
        
        let mutation = CreateReviewForEpisodeMutation(episode: episode, review: review)
        
        client.perform(mutation: mutation) { result in
            print()
            switch result {
            case .success(let graphQLResult):
                if let errors = graphQLResult.errors {
                    print("GraphQL errors creating review for \(episode.rawValue): \(errors)")
                }
                
                if let review = graphQLResult.data?.createReview {
                    print("--- Created Review! ---")
                    print("Episode: \(episode.rawValue)")
                    print("Stars: \(review.stars)")
                    print("Commentary: \(review.commentary ?? "(none)")")
                }
            case .failure(let error):
                // If this happens, something's gone wrong at the network level before the GraphQL server could respond.
                print("Network error creating review for \(episode.rawValue): \(error)")
            }
        }
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true

//: [SQLiteCache](@next)
