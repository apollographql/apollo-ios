import Foundation
import OrderedCollections

/// Generates a file containing schema metadata used when converting data to `Object` types at runtime.
struct SchemaFileGenerator: FileGenerator, Equatable {
  let name: String
  let objectTypes: OrderedSet<GraphQLObjectType>
  let path: String

  var data: Data {
    #warning("TODO: need correct data template")
    return "public enum Schema {}".data(using: .utf8)!
  }

  init(name: String, objectTypes: OrderedSet<GraphQLObjectType>, directoryPath: String) {
    self.name = name
    self.objectTypes = objectTypes

    self.path = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("Schema.swift").path
  }
}
