import Foundation
import Apollo
import StarWarsAPI
import PlaygroundSupport

/// Taking a query and working with its results

let url = URL(string: "http://localhost:8080/graphql")!
let client = ApolloClient(url: url)

// You can change the episode here if you want, or omit the episode to receive the default value.
let query = HeroDetailsQuery(episode: .empire)

client.fetch(query: query) { result in
  switch result {
  case .success(let graphQLResult):
    if let errors = graphQLResult.errors {
      print("GraphQL errors: \(errors)")
    }
    
    if let hero = graphQLResult.data?.hero {
      print("Hero name: \(hero.name)")
    }
  case .failure(let error):
    print("Network error: \(error)")
  }
  
  PlaygroundPage.current.finishExecution()
}

PlaygroundPage.current.needsIndefiniteExecution = true
