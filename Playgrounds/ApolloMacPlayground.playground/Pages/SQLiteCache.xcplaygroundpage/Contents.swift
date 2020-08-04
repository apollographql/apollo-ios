//: [Subscriptons](@previous)

import Apollo
import Foundation
import PlaygroundSupport

//: # Setting up a client with a SQLite cache

//: First, you'll need to set up a network transport, since you will also need that to set up the client:
let serverURL = URL(string: "http://localhost:8080/graphql")!
let networkTransport = HTTPNetworkTransport(url: serverURL)

//: You'll need to make sure you import the ApolloSQLite library IF you are not using CocoaPods (CocoaPods will automatically flatten everything down to a single Apollo import):
import ApolloSQLite

//: Next, you'll have to figure out where to store your SQLite file. A reasonable place is the user's Documents directory in your sandbox.
let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
let documentsURL = URL(fileURLWithPath: documentsPath)
let sqliteFileURL = documentsURL.appendingPathComponent("test_apollo_db.sqlite")

print("File path: \(sqliteFileURL.path)")

//: Use that file URL to instantiate the SQLite cache:
let sqliteCache = try SQLiteNormalizedCache(fileURL: sqliteFileURL)

//: And then instantiate an instance of `ApolloStore` with the cache you've just created:
let store = ApolloStore(cache: sqliteCache)

//: Finally, pass that into your `ApolloClient` initializer, and you're now set up to use the SQLite cache for persistent storage:
let apolloClient = ApolloClient(networkTransport: networkTransport, store: store)


//: Now, let's test
import StarWarsAPI
let query = HeroDetailsQuery(episode: .newhope)
apolloClient.fetch(query: query) { result in
    // This is the outer Result, which has either a `GraphQLResult` or an `Error`
    switch result {
    case .success(let graphQLResult):
        if let errors = graphQLResult.errors {
            // Errors here were returned by the GraphQL system.
            // Note that the presence of errors does NOT necessarily indicate a request failed: GraphQL requests can return partial results in the event of an error.
            print("GraphQL errors: \(errors)")
        }
        
        if let hero = graphQLResult.data?.hero {
            // Here, we've used a type-safe accessor to the nested type to access the specific type with the specific fields requested by this query.
            print("Hero name: \(hero.name)")
        }
    case .failure(let error):
        // If this happens, something's gone wrong at the network level before the GraphQL server could respond.
        print("Network error: \(error)")
    }
}

//: Give the database write a chance to finish before the playground finishes executing
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    print("FINISHED")
    PlaygroundPage.current.finishExecution()
}

PlaygroundPage.current.needsIndefiniteExecution = true

//: Once "FINISHED" prints, you can open the database file at the path printed out with "File path" and examine it to see the persisted data.
//: If you don't already have a SQLite file browser, you can try the free one at https://sqlitebrowser.org/

//: [Next](@next)
