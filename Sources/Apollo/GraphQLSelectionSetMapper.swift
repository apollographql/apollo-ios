#if !COCOAPODS
import ApolloAPI
#endif

import Foundation

/// An accumulator that converts executed data to the correct values to create a `SelectionSet`.
final class GraphQLSelectionSetMapper<T: SelectionSet>: GraphQLResultAccumulator {

  let stripNullValues: Bool
  let allowMissingValuesForOptionalFields: Bool

  init(
    stripNullValues: Bool = true,
    allowMissingValuesForOptionalFields: Bool = false
  ) {
    self.stripNullValues = stripNullValues
    self.allowMissingValuesForOptionalFields = allowMissingValuesForOptionalFields
  }

  func accept(scalar: JSONValue, info: FieldExecutionInfo) throws -> JSONValue? {
    switch info.field.type.namedType {
    case let .scalar(decodable as any JSONDecodable.Type):
      // This will convert a JSON value to the expected value type,
      // which could be a custom scalar or an enum.
      return try decodable.init(_jsonValue: scalar)._asAnyHashable
    default:
      preconditionFailure()
    }
  }

  func accept(customScalar: JSONValue, info: FieldExecutionInfo) throws -> JSONValue? {
    switch info.field.type.namedType {
    case let .customScalar(decodable as any JSONDecodable.Type):
      // This will convert a JSON value to the expected value type,
      // which could be a custom scalar or an enum.
      return try decodable.init(_jsonValue: customScalar)._asAnyHashable
    default:
      preconditionFailure()
    }
  }

  func acceptNullValue(info: FieldExecutionInfo) -> JSONValue? {
    return stripNullValues ? nil : NSNull()
  }

  func acceptMissingValue(info: FieldExecutionInfo) throws -> JSONValue? {
    guard allowMissingValuesForOptionalFields && info.field.type.isNullable else {
      throw JSONDecodingError.missingValue
    }
    return nil
  }

  func accept(list: [JSONValue?], info: FieldExecutionInfo) -> JSONValue? {
    return list
  }

  func accept(childObject: JSONObject, info: FieldExecutionInfo) throws -> JSONValue? {
    return childObject
  }

  func accept(fieldEntry: JSONValue?, info: FieldExecutionInfo) -> (key: String, value: JSONValue)? {
    guard let fieldEntry = fieldEntry else { return nil }
    return (info.responseKeyForField, fieldEntry)
  }

  func accept(
    fieldEntries: [(key: String, value: JSONValue)],
    info: ObjectExecutionInfo
  ) throws -> JSONObject {
    return .init(fieldEntries, uniquingKeysWith: { (_, last) in last })
  }

  func finish(rootValue: JSONObject, info: ObjectExecutionInfo) -> T {
    return T.init(unsafeData: rootValue, variables: info.variables)
  }
}
