import Foundation
import MySwiftPackage
import ApolloWrapper

print("Running MyApp/main.swift")

do {
  let queryData = try buildDogQuery()

  print(queryData.allAnimals[0].skinCovering!)

} catch {
  print(error)
}

