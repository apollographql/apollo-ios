@_spi(Execution) import Apollo
@_spi(Unsafe) import ApolloAPI
import Foundation

/// An accumulator that converts data from a `Mock` to the correct values to create a `SelectionSet`.
final class TestMockSelectionSetMapper<T: SelectionSet>: GraphQLResultAccumulator {

  var requiresCacheKeyComputation: Bool { underlyingMapper.requiresCacheKeyComputation }
  let underlyingMapper = DataDictMapper(handleMissingValues: .allowForAllFields)

  func accept(scalar: JSONValue, info: FieldExecutionInfo) throws -> DataDict.FieldValue? {
    return scalar
  }

  func accept(customScalar: JSONValue, info: FieldExecutionInfo) throws -> DataDict.FieldValue? {
    return customScalar
  }

  func acceptNullValue(info: FieldExecutionInfo) -> DataDict.FieldValue? {
    return underlyingMapper.acceptNullValue(info: info)
  }

  func acceptMissingValue(info: FieldExecutionInfo) throws -> DataDict.FieldValue? {
    return try underlyingMapper.acceptMissingValue(info: info)
  }

  func accept(list: [DataDict.FieldValue?], info: FieldExecutionInfo) -> DataDict.FieldValue? {
    return underlyingMapper.accept(list: list, info: info)
  }

  func accept(childObject: DataDict, info: FieldExecutionInfo) throws -> DataDict.FieldValue? {
    return try underlyingMapper.accept(childObject: childObject, info: info)
  }

  func accept(fieldEntry: DataDict.FieldValue?, info: FieldExecutionInfo) -> (key: String, value: DataDict.FieldValue)? {
    return underlyingMapper.accept(fieldEntry: fieldEntry, info: info)
  }

  func accept(
    fieldEntries: [(key: String, value: DataDict.FieldValue)],
    info: ObjectExecutionInfo
  ) throws -> DataDict {
    return try underlyingMapper.accept(fieldEntries: fieldEntries, info: info)
  }

  func finish(rootValue: DataDict, info: ObjectExecutionInfo) -> T {
    return T(_dataDict: underlyingMapper.finish(rootValue: rootValue, info: info))
  }
}
