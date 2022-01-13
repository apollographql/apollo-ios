import Foundation
import OrderedCollections

/// Generates a file containing schema metadata used when converting data to `Object` types at runtime.
struct SchemaFileGenerator: FileGenerator, Equatable {
  /// The schema module name.
  let name: String
  /// The `OrderedSet` of `GraphQLObjectType` objects used to build the file content.
  let objectTypes: OrderedSet<GraphQLObjectType>
  let path: String

  var data: Data {
    #warning("TODO: need correct data template")
    return "public enum Schema {}".data(using: .utf8)!
  }

  /// Designated initializer.
  ///
  /// - Parameters:
  ///  - name: The schema module name.
  ///  - interfaceType: The `OrderedSet` of `GraphQLObjectType` objects used to build the file content.
  ///  - directoryPath: The **directory** path that the file should be written to, used to build the `path` property value.
  init(name: String, objectTypes: OrderedSet<GraphQLObjectType>, directoryPath: String) {
    self.name = name
    self.objectTypes = objectTypes

    self.path = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent("Schema.swift").path
  }
}
