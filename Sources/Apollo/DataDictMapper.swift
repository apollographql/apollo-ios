@_spi(Execution) @_spi(Internal) @_spi(Unsafe) import ApolloAPI
import Foundation

/// An accumulator that converts executed data to the correct values for use in a selection set.
@_spi(Execution)
public class DataDictMapper: GraphQLResultAccumulator {

  public let requiresCacheKeyComputation: Bool = false

  let handleMissingValues: HandleMissingValues

  public enum HandleMissingValues {
    case disallow
    case allowForOptionalFields
    /// Using this option will result in an unsafe `SelectionSet` that will crash
    /// when a required field that has missing data is accessed.
    case allowForAllFields
  }

  public init(handleMissingValues: HandleMissingValues = .disallow) {
    self.handleMissingValues = handleMissingValues
  }

  public func accept(scalar: JSONValue, info: FieldExecutionInfo) throws -> DataDict.FieldValue? {
    switch info.field.type.namedType {
    case let .scalar(decodable):
      // This will convert a JSON value to the expected value type.
      return try decodable.init(_jsonValue: scalar)
    default:
      preconditionFailure()
    }
  }

  public func accept(customScalar: JSONValue, info: FieldExecutionInfo) throws -> DataDict.FieldValue? {
    switch info.field.type.namedType {
    case let .customScalar(decodable):
      // This will convert a JSON value to the expected value type,
      // which could be a custom scalar or an enum.
      return try decodable.init(_jsonValue: customScalar)
    default:
      preconditionFailure()
    }
  }

  public func acceptNullValue(info: FieldExecutionInfo) -> DataDict.FieldValue? {
    return NSNull()
  }

  public func acceptMissingValue(info: FieldExecutionInfo) throws -> DataDict.FieldValue? {
    switch handleMissingValues {
    case .allowForOptionalFields where info.field.type.isNullable: fallthrough
    case .allowForAllFields:
      return nil

    default:
      throw JSONDecodingError.missingValue
    }
  }

  public func accept(list: [JSONValue?], info: FieldExecutionInfo) -> DataDict.FieldValue? {
    return list as DataDict.FieldValue
  }

  public func accept(childObject: DataDict, info: FieldExecutionInfo) throws -> DataDict.FieldValue? {
    return childObject
  }

  public func accept(
    fieldEntry: DataDict.FieldValue?,
    info: FieldExecutionInfo
  ) -> (key: String, value: DataDict.FieldValue)? {
    guard let fieldEntry = fieldEntry else { return nil }
    return (info.responseKeyForField, fieldEntry)
  }

  public func accept(
    fieldEntries: [(key: String, value: DataDict.FieldValue)],
    info: ObjectExecutionInfo
  ) throws -> DataDict {
    return DataDict(
      data: .init(fieldEntries, uniquingKeysWith: { (_, last) in last }),
      fulfilledFragments: info.fulfilledFragments,
      deferredFragments: info.deferredFragments
    )
  }

  public func finish(rootValue: DataDict, info: ObjectExecutionInfo) -> DataDict {
    return rootValue
  }
}
