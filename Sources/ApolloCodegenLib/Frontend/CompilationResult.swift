import JavaScriptCore

/// The output of the frontend compiler.
public class CompilationResult: JavaScriptObject {
  lazy var referencedTypes: ReferencedTypes = ReferencedTypes(self["referencedTypes"])

  lazy var operations: [OperationDefinition] = self["operations"]

  lazy var fragments: [FragmentDefinition] = self["fragments"]

  public final class ReferencedTypes {
    let allTypes: Set<GraphQLNamedType>

    let objects: Set<GraphQLObjectType>
    let interfaces: Set<GraphQLInterfaceType>
    let unions: Set<GraphQLUnionType>
    let scalars: Set<GraphQLScalarType>
    let enums: Set<GraphQLEnumType>
    let inputObjects: Set<GraphQLInputObjectType>

    init(_ types: [GraphQLNamedType]) {
      self.allTypes = Set(types)

      var objects = Set<GraphQLObjectType>()
      var interfaces = Set<GraphQLInterfaceType>()
      var unions = Set<GraphQLUnionType>()
      var scalars = Set<GraphQLScalarType>()
      var enums = Set<GraphQLEnumType>()
      var inputObjects = Set<GraphQLInputObjectType>()

      for type in allTypes {
        switch type {
        case let type as GraphQLObjectType: objects.insert(type)
        case let type as GraphQLInterfaceType: interfaces.insert(type)
        case let type as GraphQLUnionType: unions.insert(type)
        case let type as GraphQLScalarType: scalars.insert(type)
        case let type as GraphQLEnumType: enums.insert(type)
        case let type as GraphQLInputObjectType: inputObjects.insert(type)
        default: continue
        }
      }

      self.objects = objects
      self.interfaces = interfaces
      self.unions = unions
      self.scalars = scalars
      self.enums = enums
      self.inputObjects = inputObjects
    }

    private var typeToUnionMap: [GraphQLObjectType: Set<GraphQLUnionType>] = [:]

    public func unions(including type: GraphQLObjectType) -> Set<GraphQLUnionType> {
      if let unions = typeToUnionMap[type] {
        return unions
      }

      let matchingUnions = unions.filter { $0.types.contains(type) }
      typeToUnionMap[type] = matchingUnions
      return matchingUnions
    }
  }
  
  public class OperationDefinition: JavaScriptObject {
    lazy var name: String = self["name"]
    
    lazy var operationType: OperationType = self["operationType"]
    
    lazy var variables: [VariableDefinition] = self["variables"]
    
    lazy var rootType: GraphQLCompositeType = self["rootType"]
    
    lazy var selectionSet: SelectionSet = self["selectionSet"]
    
    lazy var source: String = self["source"]
    
    lazy var filePath: String = self["filePath"]
    
    lazy var operationIdentifier: String = {
      // TODO: Compute this from source + referenced fragments
      fatalError()
    }()

    /// Computes the fragments that the operation uses by all selections on the operation.
    #warning("TODO: Implement this and unit test. Probably want to implement fragments used for each SelectionSet and agregate them here.")
//    public internal(set) lazy var fragmentsUsed: Set<FragmentDefinition> = []
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
  
  public class FragmentDefinition: JavaScriptObject, Hashable {
    lazy var name: String = self["name"]
    
    lazy var type: GraphQLCompositeType = self["typeCondition"]
    
    lazy var selectionSet: SelectionSet = self["selectionSet"]
    
    lazy var source: String = self["source"]
    
    lazy var filePath: String = self["filePath"]

    public override var debugDescription: String {
      "\(name) on \(type.debugDescription)"
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(name)
    }

    public static func ==(lhs: FragmentDefinition, rhs: FragmentDefinition) -> Bool {
      return lhs.name == rhs.name
    }
  }
  
  public class SelectionSet: JavaScriptWrapper, Hashable, CustomDebugStringConvertible {
    lazy var parentType: GraphQLCompositeType = self["parentType"]!
    
    lazy var selections: [Selection] = self["selections"]!

    required convenience init(parentType: GraphQLCompositeType, selections: [Selection]) {
      self.init(nil)
      self.parentType = parentType
      self.selections = selections
    }

    public var debugDescription: String {
      let selectionDescriptions = selections.map(\.debugDescription).joined(separator: "\n")
      return """
      ... on \(parentType) {
        \(indented: selectionDescriptions)
      }
      """
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(parentType)
      hasher.combine(selections)
    }

    public static func ==(lhs: SelectionSet, rhs: SelectionSet) -> Bool {
      return lhs.parentType == rhs.parentType &&
      lhs.selections == rhs.selections
    }
  }
  
  public enum Selection: JavaScriptValueDecodable, CustomDebugStringConvertible, Hashable {
    case field(Field)
    case inlineFragment(SelectionSet)
    case fragmentSpread(FragmentDefinition)
    
    init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
      precondition(jsValue.isObject, "Expected JavaScript object but found: \(jsValue)")

      let kind: String = jsValue["kind"].toString()

      switch kind {
      case "Field":
        self = .field(Field(JavaScriptObject(jsValue, bridge: bridge)))
      case "InlineFragment":
        let selectionSet: SelectionSet = bridge.fromJSValue(jsValue["selectionSet"])
        self = .inlineFragment(selectionSet)
      case "FragmentSpread":
        self = .fragmentSpread(bridge.fromJSValue(jsValue["fragment"]))
      default:
        preconditionFailure("""
          Unknown GraphQL selection of kind "\(kind)"
          """)
      }
    }

    var selectionSet: SelectionSet? {
      switch self {
      case let .field(field): return field.selectionSet
      case let .inlineFragment(selectionSet): return selectionSet
      case let .fragmentSpread(fragment): return fragment.selectionSet
      }
    }

    public var debugDescription: String {
      switch self {
      case let .field(field):
        return "field - " + field.debugDescription
      case let .inlineFragment(fragment):
        return "fragment - " + fragment.debugDescription
      case let .fragmentSpread(fragment):
        return "fragment - " + fragment.debugDescription
      }
    }
  }
  
  public class Field: JavaScriptWrapper, Hashable, CustomDebugStringConvertible {
    lazy var name: String = self["name"]!
    
    lazy var alias: String? = self["alias"]
    
    var responseKey: String {
      alias ?? name
    }
    
    lazy var arguments: [Argument]? = self["arguments"]
    
    lazy var type: GraphQLType = self["type"]!
    
    lazy var selectionSet: SelectionSet? = self["selectionSet"]
    
    lazy var deprecationReason: String? = self["deprecationReason"]
    
    var isDeprecated: Bool {
      return deprecationReason != nil
    }
    
    lazy var description: String? = self["description"]

    required convenience init(
      name: String,
      alias: String? = nil,
      arguments: [Argument]? = nil,
      type: GraphQLType,
      selectionSet: SelectionSet? = nil,
      deprecationReason: String? = nil,
      description: String? = nil
    ) {
      self.init(nil)
      self.name = name
      self.alias = alias
      self.arguments = arguments
      self.type = type
      self.selectionSet = selectionSet
      self.deprecationReason = deprecationReason
      self.description = description
    }

    public var debugDescription: String {
      "\(name): \(type)"
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(name)
      hasher.combine(alias)
      hasher.combine(arguments)
      hasher.combine(type)
      hasher.combine(selectionSet)
    }

    public static func ==(lhs: Field, rhs: Field) -> Bool {
      return lhs.name == rhs.name &&
      lhs.alias == rhs.alias &&
      lhs.arguments == rhs.arguments &&
      lhs.type == rhs.type &&
      lhs.selectionSet == rhs.selectionSet
    }
  }
  
  public class Argument: JavaScriptObject, Hashable {
    lazy var name: String = self["name"]
    
    lazy var value: GraphQLValue = self["value"]

    public func hash(into hasher: inout Hasher) {
      hasher.combine(name)
      hasher.combine(value)
    }

    public static func ==(lhs: Argument, rhs: Argument) -> Bool {
      return lhs.name == rhs.name &&
      lhs.value == rhs.value
    }
  }

}
