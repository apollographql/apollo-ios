import PlaygroundSupport
import Apollo
import StarWars

PlaygroundPage.current.needsIndefiniteExecution = true

let client = ApolloClient(url: URL(string: "http://localhost:8080/graphql")!)

func describe(hero: HeroDetails) {
  print(hero.name)
  print(hero.appearsIn)
  
  switch hero {
  case let human as HeroDetails_Human:
    print(human.homePlanet)
  case let droid as HeroDetails_Droid:
    print(droid.primaryFunction)
  default:
    break
  }
}

client.fetch(query: HeroAndFriendsDetailsQuery(episode: .empire)) { (result, error) in
  defer { PlaygroundPage.current.finishExecution() }
  
  if let error = error { NSLog("Error while fetching query: \(error)");  return }
  guard let result = result else { NSLog("No query result");  return }
  
  if let errors = result.errors {
    NSLog("Errors in query result: \(errors)")
  }
  
  guard let data = result.data else { NSLog("No query result data");  return }
  
  describe(hero: data.hero)
  
  guard let friends = data.hero.friends else { return }
  
  for friend in friends {
    // You can't access friend.friends here
    describe(hero: friend)
  }
}
