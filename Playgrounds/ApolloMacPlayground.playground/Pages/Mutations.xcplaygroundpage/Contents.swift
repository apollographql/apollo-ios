//: [Previous](@previous)

import Foundation
import Apollo
import StarWarsAPI
import PlaygroundSupport

//: ## Mutations
//: Mutations are used to change a piece of information on the server, and then return specified data after the change was made.
//: 
//: Again, set up a basic client, similar to how you set one up in the Queries page.
let url = URL(string: "http://localhost:8080/graphql")!
let client = ApolloClient(url: url)

//: Again, code generation will generate Swift initializers for your mutations. Pick one to use and create an instance variable for it:

let mutation = CreateAwesomeReviewMutation()

//: Next, pass it into the `client.perform` closure to actually have the server run the mutation: 

client.perform(mutation: mutation) { result in
    // This is the outer Result, which has either a `GraphQLResult` or an `Error`
    switch result {
    case .success(let graphQLResult):
        if let errors = graphQLResult.errors {
            // Errors here were returned by the graphQL system.
            // Note that the presence of errors does NOT necessarily indicate a request failed: GraphQL requests can return partial results in the event of an error.
            print("GraphQL Errors: \(errors)")
        }
        
        if let review = graphQLResult.data?.createReview {
            // Here, we've used type-safe accessors to the nested type to access the specific type with the specific fields requested by this query.
            print("Stars: \(review.stars)")
            print("Review Commentary: \(review.commentary ?? "(none)")")
            
            // If you try to add a field which is defined in the schema, but which you haven't specifically requested as part of the query, it won't build. Uncomment the following line for an example:
            //print("Episode: \(review.episode)")
        }
    case .failure(let error):
        // If this happens, something's gone wrong at the network level before the GraphQL server could respond.
        print("Network Error: \(error)")
    }
    
    PlaygroundPage.current.finishExecution()
}

PlaygroundPage.current.needsIndefiniteExecution = true


//: [Subscriptions](@next)
