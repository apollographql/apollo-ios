#if !COCOAPODS
import ApolloMigrationAPI
#endif

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

  init(handleMissingValues: HandleMissingValues = .disallow) {
    self.handleMissingValues = handleMissingValues
  }

  public func accept(scalar: AnyHashable, info: FieldExecutionInfo) throws -> AnyHashable? {
    switch info.field.type.namedType {
    case let .scalar(decodable as any JSONDecodable.Type):
      // This will convert a JSON value to the expected value type.
      return try decodable.init(_jsonValue: scalar)._asAnyHashable
    default:
      preconditionFailure()
    }
  }

  public func accept(customScalar: AnyHashable, info: FieldExecutionInfo) throws -> AnyHashable? {
    switch info.field.type.namedType {
    case let .customScalar(decodable as any JSONDecodable.Type):
      // This will convert a JSON value to the expected value type,
      // which could be a custom scalar or an enum.
      return try decodable.init(_jsonValue: customScalar)._asAnyHashable
    default:
      preconditionFailure()
    }
  }

  public func acceptNullValue(info: FieldExecutionInfo) -> AnyHashable? {
    return DataDict._NullValue
  }

  public func acceptMissingValue(info: FieldExecutionInfo) throws -> AnyHashable? {
    switch handleMissingValues {
    case .allowForOptionalFields where info.field.type.isNullable: fallthrough
    case .allowForAllFields:
      return nil

    default:
      throw JSONDecodingError.missingValue
    }
  }

  public func accept(list: [AnyHashable?], info: FieldExecutionInfo) -> AnyHashable? {
    return list
  }

  public func accept(childObject: DataDict, info: FieldExecutionInfo) throws -> AnyHashable? {
    return childObject
  }

  public func accept(
    fieldEntry: AnyHashable?,
    info: FieldExecutionInfo
  ) -> (key: String, value: AnyHashable)? {
    guard let fieldEntry = fieldEntry else { return nil }
    return (info.responseKeyForField, fieldEntry)
  }

  public func accept(
    fieldEntries: [(key: String, value: AnyHashable)],
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
