import PlaygroundSupport
import Apollo

PlaygroundPage.current.needsIndefiniteExecution = true

let client = ApolloClient(url: URL(string: "http://localhost:3000/graphql")!)

client.fetch(query: EntryQuery(repoFullName: "apollostack/apollo-client")) { (result, error) in
  defer { PlaygroundPage.current.finishExecution() }
  
  if let error = error { NSLog("Error while fetching query: \(error)");  return }
  guard let result = result else { NSLog("No query result");  return }
  
  if let errors = result.errors {
    NSLog("Errors in query result: \(errors)")
  }
  
  guard let data = result.data else { NSLog("No query result data");  return }
  
  let entry = data.entry
  
  entry.repository.description
  entry.repository.fullName
  entry.score
  entry.postedBy.login
  entry.postedBy.avatarURL
}
