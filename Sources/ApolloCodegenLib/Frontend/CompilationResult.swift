import JavaScriptCore

/// The output of the frontend compiler.
public class CompilationResult: JavaScriptObject {
  private(set) lazy var operations: [OperationDefinition] = self["operations"]
  
  private(set) lazy var fragments: [FragmentDefinition] = self["fragments"]

  private(set) lazy var referencedTypes: [GraphQLNamedType] = self["referencedTypes"]
  
  public class OperationDefinition: JavaScriptObject {
    private(set) lazy var name: String = self["name"]
    
    private(set) lazy var operationType: OperationType = self["operationType"]
    
    private(set) lazy var variables: [VariableDefinition] = self["variables"]
    
    private(set) lazy var rootType: GraphQLCompositeType = self["rootType"]
    
    private(set) lazy var selectionSet: SelectionSet = self["selectionSet"]
    
    private(set) lazy var source: String = self["source"]
    
    private(set) lazy var filePath: String = self["filePath"]
    
    var operationIdentifier: String {
      // TODO: Compute this from source + referenced fragments
      fatalError()
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
    private(set) lazy var name: String = self["name"]
    
    private(set) lazy var type: GraphQLType = self["type"]
    
    private(set) lazy var defaultValue: GraphQLValue? = self["defaultValue"]
  }
  
  public class FragmentDefinition: JavaScriptObject {
    private(set) lazy var name: String = self["name"]
    
    private(set) lazy var type: GraphQLCompositeType = self["type"]
    
    private(set) lazy var selectionSet: SelectionSet = self["selectionSet"]
    
    private(set) lazy var source: String = self["source"]
    
    private(set) lazy var filePath: String = self["filePath"]
  }
  
  public class SelectionSet: JavaScriptObject {
    private(set) lazy var parentType: GraphQLCompositeType = self["parentType"]
    
    private(set) lazy var selections: [Selection] = self["selections"]
  }
  
  public enum Selection: JavaScriptValueDecodable {
    case field(Field)
    case inlineFragment(InlineFragment)
    case fragmentSpread(FragmentSpread)
    
    init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
      precondition(jsValue.isObject, "Expected JavaScript object but found: \(jsValue)")

      let kind: String = jsValue["kind"].toString()

      switch kind {
      case "Field":
        self = .field(Field(jsValue, bridge: bridge))
      case "InlineFragment":
        self = .inlineFragment(InlineFragment(jsValue, bridge: bridge))
      case "FragmentSpread":
        self = .fragmentSpread(FragmentSpread(jsValue, bridge: bridge))
      default:
        preconditionFailure("""
          Unknown GraphQL selection of kind "\(kind)"
          """)
      }
    }
  }
  
  public class Field: JavaScriptObject {
    private(set) lazy var name: String = self["name"]
    
    private(set) lazy var alias: String? = self["alias"]
    
    var responseKey: String {
      alias ?? name
    }
    
    private(set) lazy var arguments: [Argument]? = self["arguments"]
    
    private(set) lazy var type: GraphQLType = self["type"]
    
    private(set) lazy var selectionSet: SelectionSet? = self["selectionSet"]
    
    private(set) lazy var deprecationReason: String? = self["deprecationReason"]
    
    var isDeprecated: Bool {
      return deprecationReason != nil
    }
    
    private(set) lazy var description: String? = self["description"]
  }
  
  public class Argument: JavaScriptObject {
    private(set) lazy var name: String = self["name"]
    
    private(set) lazy var value: GraphQLValue = self["value"]
  }
  
  public class InlineFragment: JavaScriptObject {
    private(set) lazy var typeCondition: GraphQLCompositeType? = self["typeCondition"]
    
    private(set) lazy var selectionSet: SelectionSet = self["selectionSet"]
  }
  
  public class FragmentSpread: JavaScriptObject {
    private(set) lazy var fragment: FragmentDefinition = self["fragment"]
  }
}
