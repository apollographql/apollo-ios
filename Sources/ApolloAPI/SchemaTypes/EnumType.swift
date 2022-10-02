/// A protocol that an enum in a generated GraphQL schema conforms to.
///
/// When used as an input value or the value of a field in a generated ``SelectionSet``, each
/// generated ``EnumType`` will be wrapped in a ``GraphQLEnum`` which provides support for handling
/// unknown enum cases that were not included in the schema at the time of code generation.
///
/// # See Also
/// [GraphQLSpec - Enums](https://spec.graphql.org/draft/#sec-Enums)
public protocol EnumType:
  RawRepresentable,
  JSONEncodable,
  GraphQLOperationVariableValue
where RawValue == String {}
