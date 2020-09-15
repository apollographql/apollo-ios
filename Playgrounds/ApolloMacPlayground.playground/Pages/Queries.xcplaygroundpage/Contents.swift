//: [Introduction](@previous)

import Foundation
import Apollo
import StarWarsAPI
import PlaygroundSupport

//: ## Queries
//: Queries are the most basic GraphQL operation: You ask the graph for information, and it returns the specific things you asked for.
//:
//: ## Creating a basic client
//: To create a basic client with a default configuration, you need the URL for your GraphQL endpoint, which you can then pass into your client:

let url = URL(string: "http://localhost:8080/graphql")!
let client = ApolloClient(url: url)

//: ## Making a query
//: First, you need to set up code generation to create the Swift code based on your queries. In this playground, we're using the sample `StarWarsAPI` code.
//:
//: When code is generated, you can use it to create a type-safe query object which has any available parameters:

let query = HeroDetailsQuery(episode: .newhope)

//: After setting up your query, you can pass it to your server using `client.fetch` and receive the results asynchronously:

client.fetch(query: query) { result in
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
    
    PlaygroundPage.current.finishExecution()
}

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Mutations](@next)
