import JavaScriptCore

/// The output of the frontend compiler.
public class CompilationResult: JavaScriptObject {
  lazy var operations: [OperationDefinition] = self["operations"]
  
  lazy var fragments: [FragmentDefinition] = self["fragments"]

  lazy var typesUsed: [GraphQLNamedType] = self["typesUsed"]
  
  public class OperationDefinition: JavaScriptObject, CustomStringConvertible {
    lazy var name: String = self["name"]
    
    lazy var operationType: OperationType = self["operationType"]
    
    lazy var variables: [VariableDefinition] = self["variables"]
    
    lazy var rootType: GraphQLCompositeType = self["rootType"]
    
    lazy var selectionSet: SelectionSet = self["selectionSet"]
    
    lazy var source: String = self["source"]
    
    lazy var filePath: String = self["filePath"]
    
    var operationIdentifier: String {
      // TODO: Compute this from source + referenced fragments
      fatalError()
    }
    
    public var description: String {
      return "<OperationDefinition: \(operationType) \(name)>"
    }
  }
  
  public enum OperationType: String, Equatable, JavaScriptValueDecodable {
    case query
    case mutation
    case subscription
    
    init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
      // No way to use guard when delegating to a failable initializer directly, but since this is a value type
      // we can initialize a local variable instead and assign it to `self` on success.
      // See https://forums.swift.org/t/theres-no-way-to-channel-a-fail-able-initializer-to-a-throwing-one-is-there/19322
      let rawValue: String = .fromJSValue(jsValue, bridge: bridge)
      guard let operationType = Self(rawValue: rawValue) else {
        preconditionFailure("Unknown GraphQL operation type: \(rawValue)")
      }
      
      self = operationType
    }
  }
  
  public class VariableDefinition: JavaScriptObject {
    lazy var name: String = self["name"]
    
    lazy var type: GraphQLType = self["type"]
    
    lazy var defaultValue: GraphQLValue? = self["defaultValue"]
  }
  
  public class FragmentDefinition: JavaScriptObject {
    lazy var name: String = self["name"]
    
    lazy var type: GraphQLCompositeType = self["type"]
    
    lazy var selectionSet: SelectionSet = self["selectionSet"]
    
    lazy var source: String = self["source"]
    
    lazy var filePath: String = self["filePath"]
  }
  
  public class SelectionSet: JavaScriptObject {
    lazy var possibleTypes: [GraphQLObjectType] = self["possibleTypes"]
    
    lazy var selections: [Selection] = self["selections"]    
  }
  
  public enum Selection: JavaScriptValueDecodable {
    case field(Field)
    case fragmentSpread(FragmentSpread)
    case typeCondition(TypeCondition)
    case booleanCondition(BooleanCondition)
    
    init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
      precondition(jsValue.isObject, "Expected JavaScript object but found: \(jsValue)")

      let kind: String = jsValue["kind"].toString()

      switch kind {
      case "Field":
        self = .field(Field(jsValue, bridge: bridge))
      case "FragmentSpread":
        self = .fragmentSpread(FragmentSpread(jsValue, bridge: bridge))
      case "TypeCondition":
        self = .typeCondition(TypeCondition(jsValue, bridge: bridge))
      case "BooleanCondition":
        self = .booleanCondition(BooleanCondition(jsValue, bridge: bridge))
      default:
        preconditionFailure("""
          Unknown GraphQL value of kind "\(kind)"
          """)
      }
    }
  }
  
  public class Field: JavaScriptObject, CustomStringConvertible {
    lazy var name: String = self["name"]
    
    lazy var alias: String? = self["alias"]
    
    var responseKey: String {
      alias ?? name
    }
    
    lazy var arguments: [Argument]? = self["arguments"]
    
    lazy var type: GraphQLType = self["type"]
    
    lazy var selectionSet: SelectionSet? = self["selectionSet"]
    
    lazy var deprecationReason: String? = self["deprecationReason"]
    
    var isDeprecated: Bool {
      return deprecationReason != nil
    }
    
    public var description: String {
      return "\(responseKey): \(type)"
    }
  }
  
  public class Argument: JavaScriptObject {
    lazy var name: String = self["name"]
    
    lazy var value: GraphQLValue = self["value"]
  }
  
  public class FragmentSpread: JavaScriptObject {
    lazy var fragment: FragmentDefinition = self["fragment"]
    
    lazy var selectionSet: SelectionSet = self["selectionSet"]
  }
  
  public class TypeCondition: JavaScriptObject {
    lazy var type: GraphQLCompositeType = self["type"]
    
    lazy var selectionSet: SelectionSet = self["selectionSet"]
  }
  
  public class BooleanCondition: JavaScriptObject {
    lazy var variableName: String = self["variableName"]
    
    lazy var isInverted: Bool = self["inverted"]
    
    lazy var selectionSet: SelectionSet = self["selectionSet"]
  }
}
