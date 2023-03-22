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

  func accept(scalar: AnyHashable, info: FieldExecutionInfo) throws -> AnyHashable? {
    switch info.field.type.namedType {
    case let .scalar(decodable as any JSONDecodable.Type):
      // This will convert a JSON value to the expected value type,
      // which could be a custom scalar or an enum.
      return try decodable.init(_jsonValue: scalar)._asAnyHashable
    default:
      preconditionFailure()
    }
  }

  func accept(customScalar: AnyHashable, info: FieldExecutionInfo) throws -> AnyHashable? {
    switch info.field.type.namedType {
    case let .customScalar(decodable as any JSONDecodable.Type):
      // This will convert a JSON value to the expected value type,
      // which could be a custom scalar or an enum.
      return try decodable.init(_jsonValue: customScalar)._asAnyHashable
    default:
      preconditionFailure()
    }
  }

  func acceptNullValue(info: FieldExecutionInfo) -> AnyHashable? {
    return stripNullValues ? nil : NSNull()
  }

  func acceptMissingValue(info: FieldExecutionInfo) throws -> AnyHashable? {
    guard allowMissingValuesForOptionalFields && info.field.type.isNullable else {
      throw JSONDecodingError.missingValue
    }
    return nil
  }

  func accept(list: [AnyHashable?], info: FieldExecutionInfo) -> AnyHashable? {
    return list
  }

  func accept(childObject: DataDict, info: FieldExecutionInfo) throws -> AnyHashable? {
    return childObject
  }

  func accept(fieldEntry: AnyHashable?, info: FieldExecutionInfo) -> (key: String, value: AnyHashable)? {
    guard let fieldEntry = fieldEntry else { return nil }
    return (info.responseKeyForField, fieldEntry)
  }
 
  func accept(
    fieldEntries: [(key: String, value: AnyHashable)],
    info: ObjectExecutionInfo
  ) throws -> DataDict {
    var data = DataDict.SelectionSetData.init(fieldEntries, uniquingKeysWith: { (_, last) in last })
    data["__fulfilled"] = info.fulfilledFragments
    return DataDict(data: data)
  }

  func finish(rootValue: DataDict, info: ObjectExecutionInfo) -> T {
    return T.init(_dataDict: rootValue)
  }
}
