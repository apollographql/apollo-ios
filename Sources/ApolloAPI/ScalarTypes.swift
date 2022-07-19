/// An abstract protocol that a GraphQL "`scalar`" type must conform to.
///
/// - See: [GraphQL Spec - Scalars](http://spec.graphql.org/June2018/#sec-Scalars)
public protocol AnyScalarType: JSONEncodable, AnyHashableConvertible {}

/// A protocol that represents any GraphQL "`scalar`" defined in the GraphQL Specification.
///
/// - See: [GraphQL Spec - Scalars](http://spec.graphql.org/June2018/#sec-Scalars)
///
/// Conforming types are:
///   * `String`
///   * `Int`
///   * `Bool`
///   * `Float`
///   * `Double`
public protocol ScalarType:
  AnyScalarType,
  JSONDecodable,
  GraphQLOperationVariableValue {}

extension String: ScalarType {}
extension Int: ScalarType {}
extension Bool: ScalarType {}
extension Float: ScalarType {}
extension Double: ScalarType {}

/// A protocol a custom GraphQL "`scalar`" must conform to.
///
/// Custom scalars defined in a schema are generated to conform to the ``CustomScalarType``
/// protocol. By default, these are generated as typealiases to `String`. You can edit the
/// implementation of a custom scalar in the generated file. *Changes to generated custom scalar
/// types will not be overwritten when running code generation again.*
///
/// - See: [GraphQL Spec - Scalars](http://spec.graphql.org/June2018/#sec-Scalars)
public protocol CustomScalarType:
  AnyScalarType,
  JSONDecodable,
  OutputTypeConvertible,
  GraphQLOperationVariableValue
{
  var jsonValue: JSONValue { get }
}

extension CustomScalarType {
  @inlinable public static var asOutputType: Selection.Field.OutputType {
    .nonNull(.customScalar(self))
  }
}

extension Array: AnyScalarType where Array.Element: AnyScalarType & Hashable {}

extension Optional: AnyScalarType where Wrapped: AnyScalarType & Hashable {}
