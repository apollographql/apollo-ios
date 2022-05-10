public protocol AnyScalarType {}

public protocol ScalarType:
  AnyScalarType,
  JSONDecodable,
  JSONEncodable,
  GraphQLOperationVariableValue {}

extension String: ScalarType {}
extension Int: ScalarType {}
extension Bool: ScalarType {}
extension Float: ScalarType {}
extension Double: ScalarType {}

#warning("TODO: combine scalar and custom scalar type")
public protocol CustomScalarType:
  AnyScalarType,
  JSONDecodable,
  JSONEncodable,
  OutputTypeConvertible,
  GraphQLOperationVariableValue
{
  var jsonValue: Any { get }
}

extension CustomScalarType {
  @inlinable public static var asOutputType: Selection.Field.OutputType {
    .nonNull(.customScalar(self))
  }
}
