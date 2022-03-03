import JavaScriptCore

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

public class GraphQLNamedType: JavaScriptObject {
  private(set) lazy var name: String = self["name"]
}

public class GraphQLScalarType: GraphQLNamedType {
  private(set) lazy var description: String? = self["description"]
  
  private(set) lazy var specifiedByURL: String? = self["specifiedByUrl"]
}

public class GraphQLEnumType: GraphQLNamedType {
  private(set) lazy var description: String? = self["description"]
  
  private(set) lazy var values: [GraphQLEnumValue] = try! invokeMethod("getValues")
}

public class GraphQLEnumValue: JavaScriptObject {
  private(set) lazy var name: String = self["name"]
  
  private(set) lazy var description: String? = self["description"]
    
  private(set) lazy var deprecationReason: String? = self["deprecationReason"]
}

public class GraphQLInputObjectType: GraphQLNamedType {
  private(set) lazy var description: String? = self["description"]
  
  private(set) lazy var fields: [String: GraphQLInputField] = try! invokeMethod("getFields")
}

public class GraphQLInputField: JavaScriptObject {
  private(set) lazy var name: String = self["name"]
  
  private(set) lazy var type: GraphQLType = self["type"]
  
  private(set) lazy var description: String? = self["description"]
  
  private(set) lazy var defaultValue: Any? = self["defaultValue"]
    
  private(set) lazy var deprecationReason: String? = self["deprecationReason"]
}

public class GraphQLCompositeType: GraphQLNamedType {
}

public class GraphQLObjectType: GraphQLCompositeType {
  private(set) lazy var description: String? = self["description"]
  
  private(set) lazy var fields: [String: GraphQLField] = try! invokeMethod("getFields")
  
  private(set) lazy var interfaces: [GraphQLInterfaceType] = try! invokeMethod("getInterfaces")
}

public class GraphQLAbstractType: GraphQLCompositeType {
}

public class GraphQLInterfaceType: GraphQLAbstractType {
  private(set) lazy var description: String? = self["description"]
  
  private(set) lazy var deprecationReason: String? = self["deprecationReason"]
  
  private(set) lazy var fields: [String: GraphQLField] = try! invokeMethod("getFields")
  
  private(set) lazy var interfaces: [GraphQLInterfaceType] = try! invokeMethod("getInterfaces")
}

public class GraphQLUnionType: GraphQLAbstractType {
  private(set) lazy var types: [GraphQLObjectType] = try! invokeMethod("getTypes")
}

public class GraphQLField: JavaScriptObject {
  private(set) lazy var name: String = self["name"]
  
  private(set) lazy var type: GraphQLType = self["type"]
  
  private(set) lazy var description: String? = self["description"]
  
  private(set) lazy var deprecationReason: String? = self["deprecationReason"]
}
