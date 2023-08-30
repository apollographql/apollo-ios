#if !COCOAPODS
import ApolloAPI
#endif

let Null = AnyHashable(Optional<AnyHashable>.none)

/// An accumulator that converts executed data to the correct values to create a `SelectionSet`.
final class GraphQLSelectionSetMapper<T: SelectionSet>: GraphQLResultAccumulator {

  let requiresCacheKeyComputation: Bool = false

  let stripNullValues: Bool
  let handleMissingValues: HandleMissingValues

  enum HandleMissingValues {
    case disallow
    case allowForOptionalFields
    /// Using this option will result in an unsafe `SelectionSet` that will crash
    /// when a required field that has missing data is accessed.
    case allowForAllFields
  }

  init(
    stripNullValues: Bool = true,
    handleMissingValues: HandleMissingValues = .disallow
  ) {
    self.stripNullValues = stripNullValues
    self.handleMissingValues = handleMissingValues
  }

  func accept(scalar: AnyHashable, info: FieldExecutionInfo) throws -> AnyHashable? {
    switch info.field.type.namedType {
    case let .scalar(decodable as any JSONDecodable.Type):
      // This will convert a JSON value to the expected value type.
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
    return stripNullValues ? nil : Null
  }

  func acceptMissingValue(info: FieldExecutionInfo) throws -> AnyHashable? {
    switch handleMissingValues {
    case .allowForOptionalFields where info.field.type.isNullable: fallthrough
    case .allowForAllFields:
      return nil

    default:
      throw JSONDecodingError.missingValue
    }
  }

  func accept(list: [AnyHashable?], info: FieldExecutionInfo) -> AnyHashable? {
    return list
  }

  func accept(childObject: DataDict, info: FieldExecutionInfo) throws -> AnyHashable? {
    return childObject
  }

  func accept(fieldEntry: AnyHashable?, info: FieldExecutionInfo) -> (key: String, value: AnyHashable)? {
    guard let fieldEntry = fieldEntry else { return nil }
//    if fieldEntry is NSNull {
//      return (info.responseKeyForField, AnyHashable(Optional<AnyHashable>.none))
//    }
    return (info.responseKeyForField, fieldEntry)
  }
 
  func accept(
    fieldEntries: [(key: String, value: AnyHashable)],
    info: ObjectExecutionInfo
  ) throws -> DataDict {
    return DataDict(
      data: .init(fieldEntries, uniquingKeysWith: { (_, last) in last }),
      fulfilledFragments: info.fulfilledFragments
    )
  }

  func finish(rootValue: DataDict, info: ObjectExecutionInfo) -> T {
    return T.init(_dataDict: rootValue)
  }
}
