import XCTest
import Nimble
@testable import Apollo
@testable import ApolloAPI
import ApolloTestSupport

/// Tests reading fields from a JSON network response using a GraphQLExecutor and a SelectionSetMapper
class GraphQLExecutor_SelectionSetMapper_FromResponse_Tests: XCTestCase {

  // MARK: - Helpers

  private static let executor: GraphQLExecutor = {
    let executor = GraphQLExecutor { object, info in
      return object[info.responseKeyForField]
    }
    executor.shouldComputeCachePath = false
    return executor
  }()

  private func readValues<T: RootSelectionSet>(
    _ selectionSet: T.Type,
    from object: JSONObject,
    variables: GraphQLOperation.Variables? = nil
  ) throws -> T {
    return try GraphQLExecutor_SelectionSetMapper_FromResponse_Tests.executor.execute(
      selectionSet: selectionSet,
      on: object,      
      variables: variables,
      accumulator: GraphQLSelectionSetMapper<T>()
    )
  }

  // MARK: - Tests

  // MARK: Nonnull Scalar

  func test__nonnull_scalar__givenData_getsValue() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("name", String.self)] }
    }
    let object: JSONObject = ["name": "Luke Skywalker"]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.name, "Luke Skywalker")
  }
  
  func test__nonnull_scalar__givenDataMissingKeyForField_throwsMissingValueError() {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("name", String.self)] }
    }
    let object: JSONObject = [:]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func test__nonnull_scalar__givenDataHasNullValueForField_throwsNullValueError() {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("name", String.self)] }
    }
    let object: JSONObject = ["name": NSNull()]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func test__nonnull_scalar__givenDataWithTypeConvertibleToFieldType_getsConvertedValue() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("name", String.self)] }
    }
    let object: JSONObject = ["name": 10]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.name, "10")
  }

  func test__nonnull_scalar__givenDataWithTypeNotConvertibleToFieldType_throwsCouldNotConvertError() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("name", String.self)] }
    }
    let object: JSONObject = ["name": 10.0]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if let error = error as? GraphQLResultError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertEqual(value as? Double, 10.0)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  // MARK: Optional Scalar
  
  func test__optional_scalar__givenData_getsValue() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("name", String?.self)] }
    }
    let object: JSONObject = ["name": "Luke Skywalker"]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.name, "Luke Skywalker")
  }

  func test__optional_scalar__givenDataMissingKeyForField_throwsMissingValueError() {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("name", String?.self)] }
    }
    let object: JSONObject = [:]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func test__optional_scalar__givenDataHasNullValueForField_returnsNilValueForField() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("name", String?.self)] }
    }
    let object: JSONObject = ["name": NSNull()]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertNil(data.name)
  }

  func test__optional_scalar__givenDataWithTypeConvertibleToFieldType_getsConvertedValue() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("name", String?.self)] }
    }
    let object: JSONObject = ["name": 10]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.name, "10")
  }

  func test__optional_scalar__givenDataWithTypeNotConvertibleToFieldType_throwsCouldNotConvertError() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("name", String?.self)] }
    }
    let object: JSONObject = ["name": 10.0]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if let error = error as? GraphQLResultError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertEqual(value as? Double, 10.0)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  // MARK: Nonnull Enum Value

  private enum MockEnum: String, EnumType {
    case SMALL
    case MEDIUM
    case LARGE
  }

  func test__nonnull_enum__givenData_getsValue() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("size", GraphQLEnum<MockEnum>.self)] }
    }
    let object: JSONObject = ["size": "SMALL"]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.size, GraphQLEnum(MockEnum.SMALL))
  }

  func test__nonnull_enum__givenDataIsNotAnEnumCase_getsValueAsUnknownCase() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("size", GraphQLEnum<MockEnum>.self)] }
    }
    let object: JSONObject = ["size": "GIGANTIC"]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.size, GraphQLEnum<MockEnum>.__unknown("GIGANTIC"))
  }

  func test__nonnull_enum__givenDataMissingKeyForField_throwsMissingValueError() {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("size", GraphQLEnum<MockEnum>.self)] }
    }
    let object: JSONObject = [:]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["size"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func test__nonnull_enum__givenDataHasNullValueForField_throwsNullValueError() {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("size", GraphQLEnum<MockEnum>.self)
      ]}
    }
    let object: JSONObject = ["size": NSNull()]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["size"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func test__nonnull_enum__givenDataWithType_Int_throwsCouldNotConvertError() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("size", GraphQLEnum<MockEnum>.self)] }
    }
    let object: JSONObject = ["size": 10]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if let error = error as? GraphQLResultError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["size"])
        XCTAssertEqual(value as? Int, 10)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func test__nonnull_enum__givenDataWithType_Double_throwsCouldNotConvertError() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("size", GraphQLEnum<MockEnum>.self)] }
    }
    let object: JSONObject = ["size": 10.0]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if let error = error as? GraphQLResultError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["size"])
        XCTAssertEqual(value as? Double, 10.0)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  // MARK: NonNull List Of NonNull Scalar

  func test__nonnull_list_nonnull_scalar__givenData_getsValue() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String].self)] }
    }
    let object: JSONObject = ["favorites": ["Purple", "Potatoes", "iPhone"]]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.favorites, ["Purple", "Potatoes", "iPhone"])
  }
  
  func test__nonnull_list_nonnull_scalar__givenEmptyDataArray_getsValueAsEmptyArray() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String].self)] }
    }
    let object: JSONObject = ["favorites": []]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.favorites, Array<String>())
  }

  func test__nonnull_list_nonnull_scalar__givenDataMissingKeyForField_throwsMissingValueError() {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String].self)] }
    }
    let object: JSONObject = [:]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["favorites"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func test__nonnull_list_nonnull_scalar__givenDataIsNullForField_throwsNullValueError() {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String].self)] }
    }
    let object: JSONObject = ["favorites": NSNull()]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["favorites"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func test__nonnull_list_nonnull_scalar__givenDataWithElementTypeConvertibleToFieldType_getsConvertedValue() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String].self)] }
    }
    let object: JSONObject = ["favorites": [10, 20, 30]]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.favorites, ["10", "20", "30"])
  }

  func test__nonnull_list_nonnull_enum__givenDataWithStringsNotEnumValue_getsValueAsUnknownCase() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("favorites", [GraphQLEnum<MockEnum>].self)
      ] }
    }
    let object: JSONObject = ["favorites": ["10", "20", "30"]]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.favorites, [
                    GraphQLEnum<MockEnum>.__unknown("10"),
                    GraphQLEnum<MockEnum>.__unknown("20"),
                    GraphQLEnum<MockEnum>.__unknown("30")])
  }

  func test__nonnull_list_nonnull_scalar__givenDataWithElementTypeNotConvertibleToFieldType_throwsCouldNotConvertError() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String].self)] }
    }
    let object: JSONObject = ["favorites": [10.0, 20.0, 30]]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if let error = error as? GraphQLResultError,
         case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["favorites", "0"])
        XCTAssertEqual(value as? Double, 10.0)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  // MARK: Optional List Of NonNull Scalar

  func test__optional_list_nonnull_scalar__givenData_getsValue() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String]?.self)] }
    }
    let object: JSONObject = ["favorites": ["Purple", "Potatoes", "iPhone"]]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.favorites, ["Purple", "Potatoes", "iPhone"])
  }
  
  func test__optional_list_nonnull_scalar__givenEmptyDataArray_getsValueAsEmptyArray() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String]?.self)] }
    }
    let object: JSONObject = ["favorites": []]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.favorites, Array<String>())
  }

  func test__optional_list_nonnull_scalar__givenDataMissingKeyForField_throwsMissingValueError() {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String]?.self)] }
    }
    let object: JSONObject = [:]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["favorites"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func test__optional_list_nonnull_scalar__givenDataIsNullForField_valueIsNil() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String]?.self)] }
    }
    let object: JSONObject = ["favorites": NSNull()]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertNil(data.favorites)
  }

  func test__optional_list_nonnull_scalar__givenDataWithElementTypeConvertibleToFieldType_getsConvertedValue() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String]?.self)] }
    }
    let object: JSONObject = ["favorites": [10, 20, 30]]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.favorites, ["10", "20", "30"])
  }

  func test__optional_list_nonnull_scalar__givenDataWithElementTypeNotConvertibleToFieldType_throwsCouldNotConvertError() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String]?.self)] }
    }
    let object: JSONObject = ["favorites": [4.0, 20.0, 30]]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if let error = error as? GraphQLResultError,
         case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["favorites", "0"])
        XCTAssertEqual(value as? Double, 4.0)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  // MARK: NonNull List Of Optional Scalar

  func test__nonnull_list_optional_scalar__givenData_getsValue() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String?].self)] }
    }
    let object: JSONObject = ["favorites": ["Purple", "Potatoes", "iPhone"]]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.favorites, ["Purple", "Potatoes", "iPhone"])
  }

  func test__nonnull_list_optional_scalar__givenEmptyDataArray_getsValueAsEmptyArray() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String?].self)] }
    }
    let object: JSONObject = ["favorites": []]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.favorites, Array<String>())
  }

  func test__nonnull_list_optional_scalar__givenDataMissingKeyForField_throwsMissingValueError() {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String?].self)] }
    }
    let object: JSONObject = [:]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["favorites"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func test__nonnull_list_nonnull_optional__givenDataIsNullForField_throwsNullValueError() {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String?].self)] }
    }
    let object: JSONObject = ["favorites": NSNull()]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["favorites"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func test__nonnull_list_nonnull_optional__givenDataIsArrayWithNullElement_valueIsArrayWithValuesIncludingNilElement() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String?].self)] }
    }
    let object: JSONObject = ["favorites": ["Red", NSNull(), "Bird"]]

    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.favorites! as [String?], ["Red", nil, "Bird"])
  }

  // MARK: Optional List Of Optional Scalar

  func test__optional_list_optional_scalar__givenData_getsValue() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String?]?.self)] }
    }
    let object: JSONObject = ["favorites": ["Purple", "Potatoes", "iPhone"]]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.favorites, ["Purple", "Potatoes", "iPhone"])
  }

  func test__optional_list_optional_enum__givenDataWithUnknownEnumCaseElement_getsValueWithUnknownEnumCaseElement() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("favorites", [GraphQLEnum<MockEnum>?]?.self)
      ] }
    }
    let object: JSONObject = ["favorites": ["Purple"]]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.favorites, [GraphQLEnum<MockEnum>.__unknown("Purple")])
  }

  func test__optional_list_optional_enum__givenDataWithNonConvertibleTypeElement_getsValueWithUnknownEnumCaseElement() {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [
        .field("favorites", [GraphQLEnum<MockEnum>?]?.self)
      ] }
    }
    let object: JSONObject = ["favorites": [10]]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if let error = error as? GraphQLResultError,
         case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["favorites", "0"])
        XCTAssertEqual(value as? Int, 10)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  // MARK: Nonnull Nested Selection Set

  func test__nonnull_nestedObject__givenData_getsValue() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("child", Child.self)
      ]}

      class Child: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("name", String.self)
        ]}
      }
    }
    let object: JSONObject = ["child": ["name": "Luke Skywalker"]]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.child?.name, "Luke Skywalker")
  }

  func test__nonnull_nestedObject__givenDataMissingKeyForField_throwsMissingValueError() {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("child", Child.self)
      ]}

      class Child: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("name", String.self)
        ]}
      }
    }
    let object: JSONObject = ["child": [:]]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["child", "name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  func test__nonnull_nestedObject__givenDataHasNullValueForField_throwsNullValueError() {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("child", Child.self)
      ]}

      class Child: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("name", String.self)
        ]}
      }
    }
    let object: JSONObject = ["child": ["name": NSNull()]]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["child", "name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  // MARK: - Fragments

  func test__fragment__asObjectType_matchingParentType_selectsFragmentFields() throws {
    // given
    class MockChildObject: Object {
      override class var __typename: String { "MockChildObject" }
    }

    class MockFragment: MockSelectionSet, Fragment {
      override class var __parentType: ParentType { .Object(MockChildObject.self) }
      override class var selections: [Selection] {[
        .field("child", Child.self)
      ]}

      class Child: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("name", String.self)
        ]}
      }
    }

    class GivenSelectionSet: MockSelectionSet, HasFragments {
      override class var __parentType: ParentType { .Object(MockChildObject.self) }
      override class var selections: [Selection] {[
        .fragment(MockFragment.self)
      ]}

      struct Fragments: ResponseObject {
        let data: ResponseDict
        var childFragment: MockFragment { _toFragment() }
      }
    }

    MockSchemaConfiguration.stub_objectTypeForTypeName =  { _ in return MockChildObject.self }

    let object: JSONObject = [
      "__typename": "MockChildObject",
      "child": [
        "name": "Han Solo"
      ]
    ]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.child?.name, "Han Solo")
    XCTAssertEqual(data.fragments.childFragment.child?.name, "Han Solo")
  }

  // MARK: - Boolean Conditions

  // MARK: Include
  func test__booleanCondition_include_singleField__givenVariableIsTrue_getsValueForConditionalField() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .include(if: "variable", .field("name", String.self))
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker"]
    let variables = ["variable": true]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(equal("Luke Skywalker"))
  }

  func test__booleanCondition_include_singleField__givenVariableIsFalse_doesNotGetsValueForConditionalField() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .include(if: "variable", .field("name", String.self))
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker"]
    let variables = ["variable": false]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(beNil())
  }

  func test__booleanCondition_include_singleField__givenVariableIsFalse_givenOtherSelection_doesNotGetsValueForConditionalField_doesGetOtherSelection() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("id", String.self),
        .include(if: "variable", .field("name", String.self))
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker", "id": "1234"]
    let variables = ["variable": false]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(beNil())
    expect(data.id).to(equal("1234"))
  }

  func test__booleanCondition_include_multipleFields__givenVariableIsTrue_getsValuesForConditionalFields() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .include(if: "variable", [
          .field("name", String.self),
          .field("id", String.self),
        ])
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker", "id": "1234"]
    let variables = ["variable": true]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(equal("Luke Skywalker"))
    expect(data.id).to(equal("1234"))
  }

  func test__booleanCondition_include_multipleFields__givenVariableIsFalse_doesNotGetValuesForConditionalFields() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .include(if: "variable", [
          .field("name", String.self),
          .field("id", String.self),
        ])
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker", "id": "1234"]
    let variables = ["variable": false]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(beNil())
    expect(data.id).to(beNil())
  }

  func test__booleanCondition_include_fragment__givenVariableIsTrue_getsValuesForFragmentFields() throws {
    // given
    class MockFragment: MockSelectionSet, Fragment {
      override class var selections: [Selection] {[
        .field("name", String.self),
      ]}
    }

    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("id", String.self),
        .include(if: "variable", .fragment(MockFragment.self))
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker", "id": "1234"]
    let variables = ["variable": true]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.id).to(equal("1234"))
    expect(data.name).to(equal("Luke Skywalker"))
  }

  func test__booleanCondition_include_fragment__givenVariableIsFalse_doesNotGetValuesForFragmentFields() throws {
    // given
    class MockFragment: MockSelectionSet, Fragment {
      override class var selections: [Selection] {[
        .field("name", String.self),
      ]}
    }

    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("id", String.self),
        .include(if: "variable", .fragment(MockFragment.self))
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker", "id": "1234"]
    let variables = ["variable": false]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.id).to(equal("1234"))
    expect(data.name).to(beNil())
  }

  func test__booleanCondition_include_typeCase__givenVariableIsTrue_typeCaseMatchesParentType_getsValuesForTypeCaseFields() throws {
    // given
    class Person: Object {}
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("id", String.self),
        .include(if: "variable", .typeCase(AsPerson.self))
      ]}

      class AsPerson: MockTypeCase {
        override class var __parentType: ParentType { .Object(Person.self)}
        override class var selections: [Selection] {[
          .field("name", String.self),
        ]}
      }
    }
    MockSchemaConfiguration.stub_objectTypeForTypeName = { _ in Person.self }
    let object: JSONObject = ["__typename": "Person",
                              "name": "Luke Skywalker",
                              "id": "1234"]
    let variables = ["variable": true]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.id).to(equal("1234"))
    expect(data.name).to(equal("Luke Skywalker"))
  }

  func test__booleanCondition_include_typeCase__givenVariableIsFalse_typeCaseMatchesParentType_doesNotGetValuesForTypeCaseFields() throws {
    // given
    class Person: Object {}
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("id", String.self),
        .include(if: "variable", .typeCase(AsPerson.self))
      ]}

      class AsPerson: MockTypeCase {
        override class var __parentType: ParentType { .Object(Person.self)}
        override class var selections: [Selection] {[
          .field("name", String.self),
        ]}
      }
    }
    MockSchemaConfiguration.stub_objectTypeForTypeName = { _ in Person.self }
    let object: JSONObject = ["__typename": "Person",
                              "name": "Luke Skywalker",
                              "id": "1234"]
    let variables = ["variable": false]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.id).to(equal("1234"))
    expect(data.name).to(beNil())
  }

  func test__booleanCondition_include_typeCase__givenVariableIsTrue_typeCaseDoesNotMatchParentType_doesNotGetValuesForTypeCaseFields() throws {
    // given
    class Person: Object {}
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("id", String.self),
        .include(if: "variable", .typeCase(AsPerson.self))
      ]}

      class AsPerson: MockTypeCase {
        override class var __parentType: ParentType { .Object(Person.self)}
        override class var selections: [Selection] {[
          .field("name", String.self),
        ]}
      }
    }
    MockSchemaConfiguration.stub_objectTypeForTypeName = { _ in Object.self }
    let object: JSONObject = ["__typename": "Person",
                              "name": "Luke Skywalker",
                              "id": "1234"]
    let variables = ["variable": true]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.id).to(equal("1234"))
    expect(data.name).to(beNil())
  }

  func test__booleanCondition_include_singleFieldOnNestedTypeCase__givenVariableIsTrue_typeCaseMatchesParentType_getsValuesForTypeCaseFields() throws {
    // given
    class Person: Object {}
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("id", String.self),
        .typeCase(AsPerson.self)
      ]}

      class AsPerson: MockTypeCase {
        override class var __parentType: ParentType { .Object(Person.self)}
        override class var selections: [Selection] {[
          .include(if: "variable", .field("name", String.self)),
        ]}
      }
    }
    MockSchemaConfiguration.stub_objectTypeForTypeName = { _ in Person.self }
    let object: JSONObject = ["__typename": "Person",
                              "name": "Luke Skywalker",
                              "id": "1234"]
    let variables = ["variable": true]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.id).to(equal("1234"))
    expect(data.name).to(equal("Luke Skywalker"))
  }

  func test__booleanCondition_include_singleFieldOnNestedTypeCase__givenVariableIsFalse_typeCaseMatchesParentType_getsValuesForTypeCaseFields() throws {
    // given
    class Person: Object {}
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("id", String.self),
        .typeCase(AsPerson.self)
      ]}

      class AsPerson: MockTypeCase {
        override class var __parentType: ParentType { .Object(Person.self)}
        override class var selections: [Selection] {[
          .include(if: "variable", .field("name", String.self)),
        ]}
      }
    }
    MockSchemaConfiguration.stub_objectTypeForTypeName = { _ in Person.self }
    let object: JSONObject = ["__typename": "Person",
                              "name": "Luke Skywalker",
                              "id": "1234"]
    let variables = ["variable": false]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.id).to(equal("1234"))
    expect(data.name).to(beNil())
  }

  func test__booleanCondition_include_typeCaseOnNamedFragment__givenVariableIsTrue_typeCaseMatchesParentType_getsValuesForTypeCaseFields() throws {
    // given
    class Person: Object {}
    class MockFragment: MockSelectionSet, Fragment {
      override class var selections: [Selection] {[
        .field("name", String.self),
      ]}
    }
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("id", String.self),
        .include(if: "variable", .typeCase(AsPerson.self))
      ]}

      class AsPerson: MockTypeCase {
        override class var __parentType: ParentType { .Object(Person.self)}
        override class var selections: [Selection] {[
          .fragment(MockFragment.self),
        ]}
      }
    }
    MockSchemaConfiguration.stub_objectTypeForTypeName = { _ in Person.self }
    let object: JSONObject = ["__typename": "Person",
                              "name": "Luke Skywalker",
                              "id": "1234"]
    let variables = ["variable": true]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.id).to(equal("1234"))
    expect(data.name).to(equal("Luke Skywalker"))
  }

  // MARK: Skip
  func test__booleanCondition_skip_singleField__givenVariableIsFalse_getsValueForConditionalField() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .skip(if: "variable", .field("name", String.self))
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker"]
    let variables = ["variable": false]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(equal("Luke Skywalker"))
  }

  func test__booleanCondition_skip_singleField__givenVariableIsTrue_doesNotGetsValueForConditionalField() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .skip(if: "variable", .field("name", String.self))
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker"]
    let variables = ["variable": true]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(beNil())
  }

  func test__booleanCondition_skip_multipleFields__givenVariableIsFalse_getsValuesForConditionalFields() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .skip(if: "variable", [
          .field("name", String.self),
          .field("id", String.self),
        ])
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker", "id": "1234"]
    let variables = ["variable": false]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(equal("Luke Skywalker"))
    expect(data.id).to(equal("1234"))
  }

  func test__booleanCondition_skip_multipleFields__givenVariableIsTrue_doesNotGetValuesForConditionalFields() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .skip(if: "variable", [
          .field("name", String.self),
          .field("id", String.self),
        ])
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker", "id": "1234"]
    let variables = ["variable": true]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(beNil())
    expect(data.id).to(beNil())
  }

  func test__booleanCondition_skip_singleField__givenVariableIsTrue_givenFieldIdSelectedByAnotherSelection_getsValueForField() throws {
    // given
    class MockFragment: MockSelectionSet, Fragment {
      override class var selections: [Selection] {[
        .field("name", String.self),
      ]}
    }

    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .skip(if: "variable", .field("name", String.self)),
        .fragment(MockFragment.self)
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker"]
    let variables = ["variable": true]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(equal("Luke Skywalker"))
  }

  // MARK: Skip & Include
  /// Compliance with spec: https://spec.graphql.org/draft/#note-f3059

  func test__booleanCondition_bothSkipAndInclude_multipleFields__givenSkipIsTrue_includeIsTrue_doesNotGetValuesForConditionalFields() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .skip(if: "skip",
          .include(if: "include", [
            .field("name", String.self),
            .field("id", String.self),
        ]))
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker", "id": "1234"]
    let variables = ["skip": true,
                     "include": true]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(beNil())
    expect(data.id).to(beNil())
  }

  func test__booleanCondition_bothSkipAndInclude_multipleFields__givenSkipIsTrue_includeIsFalse_doesNotGetValuesForConditionalFields() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .skip(if: "skip",
          .include(if: "include", [
            .field("name", String.self),
            .field("id", String.self),
        ]))
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker", "id": "1234"]
    let variables = ["skip": true,
                     "include": false]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(beNil())
    expect(data.id).to(beNil())
  }

  func test__booleanCondition_bothSkipAndInclude_multipleFields__givenSkipIsFalse_includeIsFalse_doesNotGetValuesForConditionalFields() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .skip(if: "skip",
          .include(if: "include", [
            .field("name", String.self),
            .field("id", String.self),
        ]))
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker", "id": "1234"]
    let variables = ["skip": false,
                     "include": false]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(beNil())
    expect(data.id).to(beNil())
  }

  func test__booleanCondition_bothSkipAndInclude_multipleFields__givenSkipIsFalse_includeIsTrue_getValuesForConditionalFields() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .skip(if: "skip",
          .include(if: "include", [
            .field("name", String.self),
            .field("id", String.self),
        ]))
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker", "id": "1234"]
    let variables = ["skip": false,
                     "include": true]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(equal("Luke Skywalker"))
    expect(data.id).to(equal("1234"))
  }

  func test__booleanCondition_bothSkipAndInclude_onSeperateFieldsForSameSelection__givenSkipIsTrue_includeIsTrue_getsValuesForField() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .skip(if: "skip", .field("name", String.self)),
        .include(if: "include", .field("name", String.self))
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker", "id": "1234"]
    let variables = ["skip": true,
                     "include": true]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(equal("Luke Skywalker"))
  }

  func test__booleanCondition_bothSkipAndInclude_onSeperateFieldsForSameSelection__givenSkipIsFalse_includeIsFalse_getsValuesForField() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .skip(if: "skip", .field("name", String.self)),
        .include(if: "include", .field("name", String.self))
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker", "id": "1234"]
    let variables = ["skip": false,
                     "include": false]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(equal("Luke Skywalker"))
  }

  func test__booleanCondition_bothSkipAndInclude_onSeperateFieldsForSameSelection__givenSkipIsFalse_includeIsTrue_getsValuesForField() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .skip(if: "skip", .field("name", String.self)),
        .include(if: "include", .field("name", String.self))
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker", "id": "1234"]
    let variables = ["skip": false,
                     "include": true]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(equal("Luke Skywalker"))
  }

  func test__booleanCondition_bothSkipAndInclude_onSeperateFieldsForSameSelection__givenSkipIsTrue_includeIsFalse_doesNotGetValuesForConditionalFields() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .skip(if: "skip", .field("name", String.self)),
        .include(if: "include", .field("name", String.self))
      ]}
    }
    let object: JSONObject = ["name": "Luke Skywalker", "id": "1234"]
    let variables = ["skip": true,
                     "include": false]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object, variables: variables)

    // then
    expect(data.name).to(beNil())
  }

}
