#if !COCOAPODS
import ApolloAPI
#endif

/// An accumulator that maps executed data to create a `SelectionSet`.
@_spi(Execution)
public final class GraphQLSelectionSetMapper<T: SelectionSet>: GraphQLResultAccumulator {

  let dataDictMapper: DataDictMapper

  public var requiresCacheKeyComputation: Bool {
    dataDictMapper.requiresCacheKeyComputation
  }

  public var handleMissingValues: DataDictMapper.HandleMissingValues {
    dataDictMapper.handleMissingValues
  }

  public init(handleMissingValues: DataDictMapper.HandleMissingValues = .disallow) {
    self.dataDictMapper = DataDictMapper(handleMissingValues: handleMissingValues)
  }

  public func accept(scalar: AnyHashable, info: FieldExecutionInfo) throws -> AnyHashable? {
    try dataDictMapper.accept(scalar: scalar, info: info)
  }

  public func accept(customScalar: AnyHashable, info: FieldExecutionInfo) throws -> AnyHashable? {
    try dataDictMapper.accept(customScalar: customScalar, info: info)
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

  public func accept(fieldEntry: AnyHashable?, info: FieldExecutionInfo) -> (key: String, value: AnyHashable)? {
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

  public func finish(rootValue: DataDict, info: ObjectExecutionInfo) -> T {
    return T.init(_dataDict: rootValue)
  }
}
