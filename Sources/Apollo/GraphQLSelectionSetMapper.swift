#if !COCOAPODS
import ApolloAPI
#endif

#warning("TODO: kill this and replace with DataDict Mapper!")
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

  public func accept(scalar: JSONValue, info: FieldExecutionInfo) throws -> DataDict.FieldValue? {
    try dataDictMapper.accept(scalar: scalar, info: info)
  }

  public func accept(customScalar: JSONValue, info: FieldExecutionInfo) throws -> DataDict.FieldValue? {
    try dataDictMapper.accept(customScalar: customScalar, info: info)
  }

  public func acceptNullValue(info: FieldExecutionInfo) -> DataDict.FieldValue? {
    return DataDict._NullValue
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

  public func accept(list: [DataDict.FieldValue?], info: FieldExecutionInfo) -> DataDict.FieldValue? {
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

  public func finish(rootValue: DataDict, info: ObjectExecutionInfo) -> T {
    return T.init(_dataDict: rootValue)
  }
}
