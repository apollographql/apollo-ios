#if !COCOAPODS
@testable import ApolloAPI
@testable import Apollo
#endif
import Foundation

/// An accumulator that converts data from a `Mock` to the correct values to create a `SelectionSet`.
final class TestMockSelectionSetMapper<T: SelectionSet>: GraphQLResultAccumulator {

  let underlyingMapper = GraphQLSelectionSetMapper<T>(handleMissingValues: .allowForAllFields)

  func accept(scalar: AnyHashable, info: FieldExecutionInfo) throws -> AnyHashable? {
    return scalar
  }

  func accept(customScalar: AnyHashable, info: FieldExecutionInfo) throws -> AnyHashable? {
    return customScalar
  }

  func acceptNullValue(info: FieldExecutionInfo) -> AnyHashable? {
    return underlyingMapper.acceptNullValue(info: info)
  }

  func acceptMissingValue(info: FieldExecutionInfo) throws -> AnyHashable? {
    return try underlyingMapper.acceptMissingValue(info: info)
  }

  func accept(list: [AnyHashable?], info: FieldExecutionInfo) -> AnyHashable? {
    return underlyingMapper.accept(list: list, info: info)
  }

  func accept(childObject: DataDict.SelectionSetData, info: FieldExecutionInfo) throws -> AnyHashable? {
    return try underlyingMapper.accept(childObject: childObject, info: info)
  }

  func accept(fieldEntry: AnyHashable?, info: FieldExecutionInfo) -> (key: String, value: AnyHashable)? {
    return underlyingMapper.accept(fieldEntry: fieldEntry, info: info)
  }

  func accept(
    fieldEntries: [(key: String, value: AnyHashable)],
    info: ObjectExecutionInfo
  ) throws -> DataDict.SelectionSetData {
    return try underlyingMapper.accept(fieldEntries: fieldEntries, info: info)
  }

  func finish(rootValue: DataDict.SelectionSetData, info: ObjectExecutionInfo) -> T {
    return underlyingMapper.finish(rootValue: rootValue, info: info)
  }
}
