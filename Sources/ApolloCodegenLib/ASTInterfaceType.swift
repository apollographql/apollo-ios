import Foundation

// Represents an interface type
struct ASTInterfaceType: Codable, Equatable {
  
  // The name of the interface type
  let name: String
  
  // The names of the types which conform to this interface
  let types: [String]
  
  /// Initializer for testing
  init(name: String,
       types: [String]) {
    self.name = name
    self.types = types
  }
}
