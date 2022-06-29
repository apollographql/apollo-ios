import JavaScriptCore
import OrderedCollections

// These classes correspond directly to the ones in
// https://github.com/graphql/graphql-js/tree/master/src/type
// and are partially described in https://graphql.org/graphql-js/type/

/// A GraphQL schema.
public class GraphQLSchema: JavaScriptObject {  
  func getType(named typeName: String) throws -> GraphQLNamedType? {
    try invokeMethod("getType", with: typeName)
  }
  
  func getPossibleTypes(_ abstractType: GraphQLAbstractType) throws -> [GraphQLObjectType] {
    return try invokeMethod("getPossibleTypes", with: abstractType)
  }
  
  func getImplementations(interfaceType: GraphQLInterfaceType) throws -> InterfaceImplementations {
    return try invokeMethod("getImplementations", with: interfaceType)
  }
  
  class InterfaceImplementations: JavaScriptObject {
    private(set) lazy var objects: [GraphQLObjectType] = self["objects"]
    private(set) lazy var interfaces: [GraphQLInterfaceType] = self["interfaces"]
  }
    
  func isSubType(abstractType: GraphQLAbstractType, maybeSubType: GraphQLNamedType) throws -> Bool {
    return try invokeMethod("isSubType", with: abstractType, maybeSubType)
  }
}

public class GraphQLNamedType: JavaScriptObject, Hashable {
  lazy var name: String = self["name"]

  lazy var documentation: String? = self["description"]

  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }

  public static func ==(lhs: GraphQLNamedType, rhs: GraphQLNamedType) -> Bool {
    return lhs.name == rhs.name
  }
}

public class GraphQLScalarType: GraphQLNamedType {
  
  lazy var specifiedByURL: String? = self["specifiedByUrl"]

  var isCustomScalar: Bool {
    guard self.specifiedByURL == nil else { return true }

    switch name {
    case "String", "Int", "Float", "Boolean", "ID":
      return false
    default:
      return true
    }    
  }

  var isSwiftType: Bool {
    switch name {
    case "String", "Int", "Float", "Boolean":
      return true
    default:
      return false
    }
  }
}

public class GraphQLEnumType: GraphQLNamedType {
  lazy var values: [GraphQLEnumValue] = try! invokeMethod("getValues")
}

public class GraphQLEnumValue: JavaScriptObject {
  lazy var name: String = self["name"]
  
  lazy var documentation: String? = self["description"]
    
  lazy var deprecationReason: String? = self["deprecationReason"]
}

public class GraphQLInputObjectType: GraphQLNamedType {
  lazy var fields: OrderedDictionary<String, GraphQLInputField> = try! invokeMethod("getFields")
}

public class GraphQLInputField: JavaScriptObject {
  lazy var name: String = self["name"]
  
  lazy var type: GraphQLType = self["type"]
  
  lazy var documentation: String? = self["description"]
  
  lazy var defaultValue: GraphQLValue? = {
    let node: JavaScriptObject? = self["astNode"]
    return node?["defaultValue"]
  }()
    
  private(set) lazy var deprecationReason: String? = self["deprecationReason"]
}

public class GraphQLCompositeType: GraphQLNamedType {
  public override var debugDescription: String {
    "Type - \(name)"
  }
}

protocol GraphQLInterfaceImplementingType: GraphQLCompositeType {
  var interfaces: [GraphQLInterfaceType] { get }
}

extension GraphQLInterfaceImplementingType {
  func implements(_ interface: GraphQLInterfaceType) -> Bool {
    interfaces.contains(interface)
  }
}

public class GraphQLObjectType: GraphQLCompositeType, GraphQLInterfaceImplementingType {
  lazy var fields: [String: GraphQLField] = try! invokeMethod("getFields")
  
  lazy var interfaces: [GraphQLInterfaceType] = try! invokeMethod("getInterfaces")

  public override var debugDescription: String {
    "Object - \(name)"
  }
}

public class GraphQLAbstractType: GraphQLCompositeType {
}

public class GraphQLInterfaceType: GraphQLAbstractType, GraphQLInterfaceImplementingType {  
  lazy var deprecationReason: String? = self["deprecationReason"]
  
  lazy var fields: [String: GraphQLField] = try! invokeMethod("getFields")
  
  lazy var interfaces: [GraphQLInterfaceType] = try! invokeMethod("getInterfaces")

  public override var debugDescription: String {
    "Interface - \(name)"
  }
}

public class GraphQLUnionType: GraphQLAbstractType {
  lazy var types: [GraphQLObjectType] = try! invokeMethod("getTypes")

  public override var debugDescription: String {
    "Union - \(name)"
  }
}

public class GraphQLField: JavaScriptObject, Hashable {

  lazy var name: String = self["name"]
  
  lazy var type: GraphQLType = self["type"]

  lazy var arguments: [GraphQLFieldArgument] = self["args"]
  
  lazy var documentation: String? = self["description"]
  
  lazy var deprecationReason: String? = self["deprecationReason"]

  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(type)
    hasher.combine(arguments)
  }

  public static func == (lhs: GraphQLField, rhs: GraphQLField) -> Bool {
    lhs.name == rhs.name &&
    lhs.type == rhs.type &&
    lhs.arguments == rhs.arguments
  }

  public override var debugDescription: String {
    "\(name): \(type.debugDescription)"
  }
}

public class GraphQLFieldArgument: JavaScriptObject, Hashable {

  lazy var name: String = self["name"]

  lazy var type: GraphQLType = self["type"]

  lazy var documentation: String? = self["description"]

  lazy var deprecationReason: String? = self["deprecationReason"]

  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(type)
  }

  public static func == (lhs: GraphQLFieldArgument, rhs: GraphQLFieldArgument) -> Bool {
    lhs.name == rhs.name &&
    lhs.type == rhs.type
  }
  
}
