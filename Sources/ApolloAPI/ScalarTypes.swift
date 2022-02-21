public protocol AnyScalarType {}

public protocol ScalarType:
  AnyScalarType,
  JSONDecodable,
  JSONEncodable,
  Cacheable,
  GraphQLOperationVariableValue {}

extension String: ScalarType {}
extension Int: ScalarType {}
extension Bool: ScalarType {}
extension Float: ScalarType {}
extension Double: ScalarType {}

extension ScalarType {
  public static func value(with cacheData: JSONValue, in transaction: CacheTransaction) throws -> Self {
    return cacheData as! Self
  }  
}

public protocol CustomScalarType:
  AnyScalarType,
  JSONDecodable,
  JSONEncodable,
  Cacheable,
  OutputTypeConvertible,
  GraphQLOperationVariableValue
{
  var jsonValue: Any { get }
}

extension CustomScalarType {
  public static func value(with cacheData: JSONValue, in: CacheTransaction) throws -> Self {
    try Self.init(jsonValue: cacheData)
  }

  @inlinable public static var asOutputType: Selection.Field.OutputType {
    .nonNull(.customScalar(self))
  }
}
