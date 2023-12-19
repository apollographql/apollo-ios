#if !COCOAPODS
import ApolloAPI
#endif

/// An accumulator that maps executed data to create a `SelectionSet`.
final class GraphQLSelectionSetMapper<T: SelectionSet>: GraphQLResultAccumulator {

  let dataDictMapper: DataDictMapper

  var requiresCacheKeyComputation: Bool {
    dataDictMapper.requiresCacheKeyComputation
  }

  var handleMissingValues: DataDictMapper.HandleMissingValues {
    dataDictMapper.handleMissingValues
  }

  init(handleMissingValues: DataDictMapper.HandleMissingValues = .disallow) {
    self.dataDictMapper = DataDictMapper(handleMissingValues: handleMissingValues)
  }

  func accept(scalar: AnyHashable, info: FieldExecutionInfo) throws -> AnyHashable? {
    try dataDictMapper.accept(scalar: scalar, info: info)
  }

  func accept(customScalar: AnyHashable, info: FieldExecutionInfo) throws -> AnyHashable? {
    try dataDictMapper.accept(customScalar: customScalar, info: info)
  }

  func acceptNullValue(info: FieldExecutionInfo) -> AnyHashable? {
    return DataDict._NullValue
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
    return (info.responseKeyForField, fieldEntry)
  }

  func accept(
    fieldEntries: [(key: String, value: AnyHashable)],
    info: ObjectExecutionInfo
  ) throws -> DataDict {
    return DataDict(
      data: .init(fieldEntries, uniquingKeysWith: { (_, last) in last }),
      fulfilledFragments: info.fulfilledFragments,
      deferredFragments: info.deferredFragments
    )
  }

  func finish(rootValue: DataDict, info: ObjectExecutionInfo) -> T {
    return T.init(_dataDict: rootValue)
  }
}
