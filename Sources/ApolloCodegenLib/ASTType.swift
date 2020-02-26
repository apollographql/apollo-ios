import Foundation

class ASTType: Codable {
  // What are the other types?
  enum Kind: String, Codable {
    case EnumType
    case InputObjectType
  }

  let kind: Kind
  let name: String
  let description: String
  let values: [ASTEnumValue]?
  let fields: [ASTTypeField]?
}

class ASTEnumValue: Codable {
  let name: String
  let description: String
  let isDeprecated: Bool
}

class ASTTypeField: Codable {
  let name: String
  let type: String
  let description: String?
}
