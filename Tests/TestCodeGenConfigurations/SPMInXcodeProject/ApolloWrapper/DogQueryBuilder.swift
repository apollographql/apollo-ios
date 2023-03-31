import Foundation
import Apollo
import AnimalKingdomAPI
import ApolloAPI

/// Calling this function crashes due to issue [#2830]https://github.com/apollographql/apollo-ios/issues/2830
public func buildDogQuery() throws -> AnimalKingdomAPI.DogQuery.Data {
  return try AnimalKingdomAPI.DogQuery.Data(data: [
    "allAnimals": [
      [
        "__typename": "Dog",
        "id": "123",
        "skinCovering": "FUR",
        "species": "Canine"
      ]
    ]
  ])
}
