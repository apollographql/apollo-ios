public protocol GraphQLOperation: class {
  static var operationString: String { get }
  static var requestString: String { get }
  
  static var selectionSet: [Selection] { get }
  
  var variables: GraphQLMap? { get }
  
  associatedtype Data
  func parseData(reader: GraphQLResultReader) throws -> Data
}

public extension GraphQLOperation {
  static var requestString: String {
    return operationString
  }
  
  var variables: GraphQLMap? {
    return nil
  }
}

public extension GraphQLOperation where Data: GraphQLMappable {
  func parseData(reader: GraphQLResultReader) throws -> Data {
    let values = try reader.execute(selectionSet: type(of: self).selectionSet)
    return Data.init(values: values)
  }
}

public protocol GraphQLQuery: GraphQLOperation {}

public protocol GraphQLMutation: GraphQLOperation {}

public protocol GraphQLFragment: GraphQLMappable {
  static var possibleTypes: [String] { get }
  static var selectionSet: [Selection] { get }
}
