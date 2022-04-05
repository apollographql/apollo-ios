import JavaScriptCore

/// The output of the frontend compiler.
public class CompilationResult: JavaScriptObject {
  lazy var referencedTypes: [GraphQLNamedType] = self["referencedTypes"]

  lazy var operations: [OperationDefinition] = self["operations"]

  lazy var fragments: [FragmentDefinition] = self["fragments"]
  
  public class OperationDefinition: JavaScriptObject, Equatable {
    lazy var name: String = self["name"]
    
    lazy var operationType: OperationType = self["operationType"]
    
    lazy var variables: [VariableDefinition] = self["variables"]
    
    lazy var rootType: GraphQLCompositeType = self["rootType"]
    
    lazy var selectionSet: SelectionSet = self["selectionSet"]
    
    lazy var source: String = self["source"]
    
    lazy var filePath: String = self["filePath"]
    
    lazy var operationIdentifier: String = {
      return ""
    }()    

    override public var debugDescription: String {
      "\(name) on \(rootType.debugDescription)"
    }

    public static func ==(lhs: OperationDefinition, rhs: OperationDefinition) -> Bool {
      return lhs.name == rhs.name
    }

    lazy var nameWithSuffix: String = {
      let suffix: String
      switch operationType {
        case .query: suffix = "Query"
        case .mutation: suffix = "Mutation"
        case .subscription: suffix = "Subscription"
      }

      guard !name.hasSuffix(suffix) else {
        return name
      }

      return name+suffix
    }()
  }
  
  public enum OperationType: String, Equatable, JavaScriptValueDecodable {
    case query
    case mutation
    case subscription
    
    init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
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
    lazy var parentType: GraphQLCompositeType = self["parentType"]
    
    lazy var selections: [Selection] = self["selections"]

    required convenience init(
      parentType: GraphQLCompositeType,
      selections: [Selection] = []
    ) {
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

  public class InlineFragment: JavaScriptObject, Hashable {
    lazy var selectionSet: SelectionSet = self["selectionSet"]

    lazy var inclusionConditions: [InclusionCondition]? = self["inclusionConditions"]

    public override var debugDescription: String {
      selectionSet.debugDescription
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(selectionSet)
      hasher.combine(inclusionConditions)
    }

    public static func ==(lhs: InlineFragment, rhs: InlineFragment) -> Bool {
      return lhs.selectionSet == rhs.selectionSet &&
      lhs.inclusionConditions == rhs.inclusionConditions
    }
  }

  /// Represents an individual selection that includes a named fragment in a selection set.
  /// (ie. `...FragmentName`)
  public class FragmentSpread: JavaScriptObject, Hashable {
    lazy var fragment: FragmentDefinition = self["fragment"]

    lazy var inclusionConditions: [InclusionCondition]? = self["inclusionConditions"]

    lazy var directives: [Directive]? = self["directives"]

    var parentType: GraphQLCompositeType { fragment.type }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(fragment)
      hasher.combine(inclusionConditions)
      hasher.combine(directives)
    }

    public static func ==(lhs: FragmentSpread, rhs: FragmentSpread) -> Bool {
      return lhs.fragment == rhs.fragment &&
      lhs.inclusionConditions == rhs.inclusionConditions &&
      lhs.directives == rhs.directives
    }
  }
  
  public enum Selection: JavaScriptValueDecodable, CustomDebugStringConvertible, Hashable {
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

    var selectionSet: SelectionSet? {
      switch self {
      case let .field(field): return field.selectionSet
      case let .inlineFragment(inlineFragment): return inlineFragment.selectionSet
      case let .fragmentSpread(fragmentSpread): return fragmentSpread.fragment.selectionSet
      }
    }

    public var debugDescription: String {
      switch self {
      case let .field(field):
        return "field - " + field.debugDescription
      case let .inlineFragment(fragment):
        return "inlineFragment - " + fragment.debugDescription
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
    
    lazy var type: GraphQLType = self["type"]!

    lazy var arguments: [Argument]? = self["arguments"]

    lazy var inclusionConditions: [InclusionCondition]? = self["inclusionConditions"]

    lazy var directives: [Directive]? = self["directives"]
    
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
      inclusionConditions: [InclusionCondition]? = nil,
      directives: [Directive]? = nil,
      type: GraphQLType,
      selectionSet: SelectionSet? = nil,
      deprecationReason: String? = nil,
      description: String? = nil
    ) {
      self.init(nil)
      self.name = name
      self.alias = alias
      self.type = type
      self.arguments = arguments
      self.inclusionConditions = inclusionConditions
      self.directives = directives
      self.selectionSet = selectionSet
      self.deprecationReason = deprecationReason
      self.description = description
    }

    public var debugDescription: String {
      TemplateString("""
      \(name): \(type.debugDescription)\(ifLet: directives, {
          " \($0.map{"\($0.debugDescription)"}, separator: " ")"
        })
      """).description
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(name)
      hasher.combine(alias)
      hasher.combine(type)
      hasher.combine(arguments)
      hasher.combine(directives)
      hasher.combine(selectionSet)
    }

    public static func ==(lhs: Field, rhs: Field) -> Bool {
      return lhs.name == rhs.name &&
      lhs.alias == rhs.alias &&
      lhs.type == rhs.type &&
      lhs.arguments == rhs.arguments &&
      lhs.directives == rhs.directives &&
      lhs.selectionSet == rhs.selectionSet
    }
  }
  
  public class Argument: JavaScriptObject, Hashable {
    lazy var name: String = self["name"]

    lazy var type: GraphQLType = self["type"]

    lazy var value: GraphQLValue = self["value"]

    public func hash(into hasher: inout Hasher) {
      hasher.combine(name)
      hasher.combine(type)
      hasher.combine(value)
    }

    public static func ==(lhs: Argument, rhs: Argument) -> Bool {
      return lhs.name == rhs.name &&
      lhs.type == rhs.type &&
      lhs.value == rhs.value
    }
  }

  public class Directive: JavaScriptObject, Hashable {
    lazy var name: String = self["name"]

    lazy var arguments: [Argument]? = self["arguments"]

    public func hash(into hasher: inout Hasher) {
      hasher.combine(name)
      hasher.combine(arguments)
    }

    public static func == (lhs: Directive, rhs: Directive) -> Bool {
      return lhs.name == rhs.name &&
      lhs.arguments == rhs.arguments
    }

    public override var debugDescription: String {
      TemplateString("""
      "@\(name)\(ifLet: arguments, {
          "(\($0.map { "\($0.name): \($0.value)" }, separator: ","))"
        })
      """).description
    }
  }

  public enum InclusionCondition: JavaScriptValueDecodable, Hashable {
    case included
    case skipped
    case variable(String, isInverted: Bool)

    init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
      if jsValue.isString, let value = jsValue.toString() {
        switch value {
        case "INCLUDED":
          self = .included
          return
        case "SKIPPED":
          self = .skipped
          return
        default:
          preconditionFailure("Unrecognized value for include condition. Got \(value)")          
        }
      }

      precondition(jsValue.isObject, "Expected JavaScript object but found: \(jsValue)")

      self = .variable(jsValue["variable"].toString(), isInverted: jsValue["isInverted"].toBool())
    }

    static func include(if variable: String) -> Self {
      .variable(variable, isInverted: false)
    }

    static func skip(if variable: String) -> Self {
      .variable(variable, isInverted: true)
    }
  }

}
