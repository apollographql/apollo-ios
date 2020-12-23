import JavaScriptCore

/// The output of the frontend compiler.
public struct CompilationResult: Decodable {
  var operations: [OperationDefinition]
  var fragments: [FragmentDefinition]
  var typesUsed: [GraphQLNamedType]
  
  public struct OperationDefinition: Decodable, CustomStringConvertible {
    var operationName: String
    var operationType: OperationType
    
    var variables: [VariableDefinition]
    
    var rootType: GraphQLCompositeType
    var selectionSet: SelectionSet
    
    var source: String
    var filePath: String
    
    var operationIdentifier: String {
      // TODO: Compute this from source + referenced fragments
      fatalError()
    }
    
    public var description: String {
      return "<OperationDefinition: \(operationType) \(operationName)>"
    }
  }
  
  public enum OperationType: String, Decodable, Equatable {
    case query
    case mutation
    case subscription
  }
  
  public struct VariableDefinition: Decodable {
    var name: String
    var type: GraphQLType
    var defaultValue: GraphQLValue?
  }
  
  public struct FragmentDefinition: Decodable {
    var fragmentName: String
    var type: GraphQLCompositeType
    var selectionSet: SelectionSet
    
    var source: String
    var filePath: String
  }
  
  public struct SelectionSet: Decodable {
    var possibleTypes: [GraphQLObjectType]
    var selections: [Selection]
  }
  
  public enum Selection: Decodable {
    case field(Field)
    case fragmentSpread(FragmentSpread)
    case typeCondition(TypeCondition)
    case booleanCondition(BooleanCondition)
    
    enum CodingKeys: CodingKey {
      case kind
    }
    
    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let kind = try container.decode(String.self, forKey: .kind)
      
      switch kind {
      case "Field":
        self = .field(try Field(from: decoder))
      case "FragmentSpread":
        self = .fragmentSpread(try FragmentSpread(from: decoder))
      case "TypeCondition":
        self = .typeCondition(try TypeCondition(from: decoder))
      case "BooleanCondition":
        self = .booleanCondition(try BooleanCondition(from: decoder))
      default:
        throw DecodingError.dataCorruptedError(forKey: .kind, in: container, debugDescription: """
          Unknown selection kind "\(kind)"
          """)
      }
    }
  }
  
  public struct Field: Decodable, CustomStringConvertible {
    var name: String
    var alias: String?
    
    var responseKey: String {
      alias ?? name
    }
    
    var arguments: [Argument]?
    
    var type: GraphQLType
    
    var selectionSet: SelectionSet?
    
    var deprecationReason: String?
    
    var isDeprecated: Bool {
      return deprecationReason != nil
    }
    
    public var description: String {
      return "\(responseKey): \(type)"
    }
  }
  
  public struct Argument: Decodable {
    var name: String
    var value: GraphQLValue
  }
  
  public struct FragmentSpread: Decodable {
    var fragmentName: String
    var selectionSet: SelectionSet
  }
  
  public struct TypeCondition: Decodable {
    var type: GraphQLCompositeType
    var selectionSet: SelectionSet
  }
  
  public struct BooleanCondition: Decodable {
    var variableName: String
    var isInverted: Bool
    var selectionSet: SelectionSet
    
    enum CodingKeys: String, CodingKey {
      case variableName
      case isInverted = "inverted"
      case selectionSet
    }
  }
}

// Type references

enum GraphQLTypeReferenceError: Error {
  case syntaxError(String)
  case namedTypeNotFound(String)
}

extension CodingUserInfoKey {
  /// Resolving type names requires access to a GraphQL schema during decoding.
  static var graphQLSchema = CodingUserInfoKey(rawValue: "graphQLSchema")!
}

// Decoding a `GraphQLNamedType` resolves the type from the schema by name.

// Unfortunately, we need a workaround for the lack of support for `self = ...` in class initializers
// See https://forums.swift.org/t/allow-self-x-in-class-convenience-initializers/15924/32

protocol GraphQLTypeNameDecodable: Decodable { }
extension GraphQLNamedType: GraphQLTypeNameDecodable { }

extension GraphQLTypeNameDecodable {
  public init(from decoder: Decoder) throws {
    guard let schema = decoder.userInfo[.graphQLSchema] as? GraphQLSchema else {
      preconditionFailure("GraphQL type decoding requires a GraphQL schema to be provided")
    }
    
    let container = try decoder.singleValueContainer()
    let typeName = try container.decode(String.self)
    
    guard let graphQLType = try schema.getType(named: typeName) else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: """
      Could not find GraphQL type "\(typeName)" in schema
      """)
    }
    
    guard let expectedGraphQLType = graphQLType as? Self else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: """
      Expected "\(graphQLType)" to be \(Self.self) but found \(type(of: graphQLType))
      """)
    }
    
    self = expectedGraphQLType
  }
}
