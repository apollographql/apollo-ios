import Foundation
import Apollo
import MySwiftPackage

public func buildDogQuery() throws -> MyGraphQLSchema.DogQuery.Data {
  return try MyGraphQLSchema.DogQuery.Data(data: [
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
