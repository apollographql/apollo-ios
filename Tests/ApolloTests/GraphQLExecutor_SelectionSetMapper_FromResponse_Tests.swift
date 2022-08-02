import XCTest
import Nimble
@testable import Apollo
@testable import ApolloAPI
import ApolloInternalTestHelpers

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
      if case let error as GraphQLExecutionError = error {
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
      if case let error as GraphQLExecutionError = error {
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
    let object: JSONObject = ["name": false]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if let error = error as? GraphQLExecutionError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertEqual(value as? Bool, false)
        XCTAssertTrue(expectedType == String.self)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  // MARK: Custom Scalar

  func test__nonnull_customScalar_asString__givenDataAsInt_getsValue() throws {
    // given
    typealias GivenCustomScalar = String

    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("customScalar", GivenCustomScalar.self)] }
    }
    let object: JSONObject = ["customScalar": Int(12345678)]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.customScalar, "12345678")
  }

  func test__nonnull_customScalar_asString__givenDataAsDouble_getsValue() throws {
    // given
    typealias GivenCustomScalar = String

    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("customScalar", GivenCustomScalar.self)] }
    }
    let object: JSONObject = ["customScalar": Double(1234.5678)]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.customScalar, "1234.5678")
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
      if case let error as GraphQLExecutionError = error {
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
    let object: JSONObject = ["name": false]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if let error = error as? GraphQLExecutionError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertEqual(value as? Bool, false)
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
    XCTAssertEqual(data.size, GraphQLEnum<MockEnum>.unknown("GIGANTIC"))
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
      if case let error as GraphQLExecutionError = error {
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
      if case let error as GraphQLExecutionError = error {
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
      if let error = error as? GraphQLExecutionError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
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
      if let error = error as? GraphQLExecutionError, case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
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
      if case let error as GraphQLExecutionError = error {
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
      if case let error as GraphQLExecutionError = error {
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
                    GraphQLEnum<MockEnum>.unknown("10"),
                    GraphQLEnum<MockEnum>.unknown("20"),
                    GraphQLEnum<MockEnum>.unknown("30")])
  }

  func test__nonnull_list_nonnull_scalar__givenDataWithElementTypeNotConvertibleToFieldType_throwsCouldNotConvertError() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] { [.field("favorites", [String].self)] }
    }
    let object: JSONObject = ["favorites": [true, false, true]]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if let error = error as? GraphQLExecutionError,
         case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["favorites", "0"])
        XCTAssertEqual(value as? Bool, true)
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
      if case let error as GraphQLExecutionError = error {
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
    let object: JSONObject = ["favorites": [true, false, false]]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if let error = error as? GraphQLExecutionError,
         case JSONDecodingError.couldNotConvert(let value, let expectedType) = error.underlying {
        XCTAssertEqual(error.path, ["favorites", "0"])
        XCTAssertEqual(value as? Bool, true)
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
      if case let error as GraphQLExecutionError = error {
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
      if case let error as GraphQLExecutionError = error {
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
    XCTAssertEqual(data.favorites, [GraphQLEnum<MockEnum>.unknown("Purple")])
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
      if let error = error as? GraphQLExecutionError,
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
    let object: JSONObject = [
      "child":
        [
          "__typename": "Child",
          "name": "Luke Skywalker"
        ]
    ]

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
    let object: JSONObject = ["child": ["__typename": "Child"]]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if case let error as GraphQLExecutionError = error {
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
    let object: JSONObject = [
      "child": [
        "__typename": "Child",
        "name": NSNull()
      ]
    ]

    // when
    XCTAssertThrowsError(try readValues(GivenSelectionSet.self, from: object)) { (error) in
      // then
      if case let error as GraphQLExecutionError = error {
        XCTAssertEqual(error.path, ["child", "name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }

  // MARK: - Inline Fragments

  func test__inlineFragment__withoutExplicitTypeNameSelection_selectsTypenameField() throws {
    // given
    struct Types {
      static let Human = Object(__typename: "Human", __implementedInterfaces: [])
      static let MockChildObject = Object(__typename: "MockChildObject", __implementedInterfaces: [])
    }

    class GivenSelectionSet: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration
      override class var __parentType: ParentType { .Object(Object.mock) }
      override class var selections: [Selection] {[
        .field("child", Child.self),
      ]}

      class Child: MockSelectionSet, SelectionSet {
        typealias Schema = MockSchemaConfiguration

        override class var __parentType: ParentType { .Object(Types.MockChildObject) }
        override class var selections: [Selection] {[
          .inlineFragment(AsHuman.self)
        ]}

        class AsHuman: MockTypeCase {
          override class var __parentType: ParentType { .Object(Types.Human)}
          override class var selections: [Selection] {[
            .field("name", String.self),
          ]}
        }
      }
    }

    MockSchemaConfiguration.stub_graphQLTypeForTypeName =  { typeName in
      switch typeName {
      case "Human":
        return Types.Human
      default:
        fail()
        return nil
      }
    }

    let object: JSONObject = [
      "child": [
        "__typename": "Human",
        "name": "Han Solo"
      ]
    ]

    // when
    let data = try readValues(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(data.child?.__typename, "Human")
    XCTAssertEqual(data.child?.name, "Han Solo")
  }

  // MARK: - Fragments

  func test__fragment__asObjectType_matchingParentType_selectsFragmentFields() throws {
    // given
    struct Types {
      static let MockChildObject = Object(__typename: "MockChildObject", __implementedInterfaces: [])
    }

    class GivenFragment: MockFragment {
      override class var __parentType: ParentType { .Object(Types.MockChildObject) }
      override class var selections: [Selection] {[
        .field("child", Child.self)
      ]}

      class Child: MockSelectionSet {
        override class var selections: [Selection] {[
          .field("name", String.self)
        ]}
      }
    }

    class GivenSelectionSet: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var __parentType: ParentType { .Object(Types.MockChildObject) }
      override class var selections: [Selection] {[
        .fragment(GivenFragment.self)
      ]}

      struct Fragments: FragmentContainer {
        let __data: DataDict
        var childFragment: GivenFragment { _toFragment() }

        init(data: DataDict) { __data = data }
      }
    }

    MockSchemaConfiguration.stub_graphQLTypeForTypeName =  { _ in return Types.MockChildObject }

    let object: JSONObject = [
      "__typename": "MockChildObject",
      "child": [
        "__typename": "Human",
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
    class GivenFragment: MockFragment {
      override class var selections: [Selection] {[
        .field("name", String.self),
      ]}
    }

    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("id", String.self),
        .include(if: "variable", .fragment(GivenFragment.self))
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
    class GivenFragment: MockFragment {
      override class var selections: [Selection] {[
        .field("name", String.self),
      ]}
    }

    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("id", String.self),
        .include(if: "variable", .fragment(GivenFragment.self))
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
    struct Types {
      static let Person = Object(__typename: "Person", __implementedInterfaces: [])
    }

    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("id", String.self),
        .include(if: "variable", .inlineFragment(AsPerson.self))
      ]}

      class AsPerson: MockTypeCase {
        override class var __parentType: ParentType { .Object(Types.Person)}
        override class var selections: [Selection] {[
          .field("name", String.self),
        ]}
      }
    }
    MockSchemaConfiguration.stub_graphQLTypeForTypeName = { _ in Types.Person }
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
    struct Types {
      static let Person = Object(__typename: "Person", __implementedInterfaces: [])
    }

    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("id", String.self),
        .include(if: "variable", .inlineFragment(AsPerson.self))
      ]}

      class AsPerson: MockTypeCase {
        override class var __parentType: ParentType { .Object(Types.Person)}
        override class var selections: [Selection] {[
          .field("name", String.self),
        ]}
      }
    }
    MockSchemaConfiguration.stub_graphQLTypeForTypeName = { _ in Types.Person }
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
    struct Types {
      static let Person = Object(__typename: "Person", __implementedInterfaces: [])
    }

    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("id", String.self),
        .include(if: "variable", .inlineFragment(AsPerson.self))
      ]}

      class AsPerson: MockTypeCase {
        override class var __parentType: ParentType { .Object(Types.Person)}
        override class var selections: [Selection] {[
          .field("name", String.self),
        ]}
      }
    }
    MockSchemaConfiguration.stub_graphQLTypeForTypeName = { _ in Object.mock }
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
    struct Types {
      static let Person = Object(__typename: "Person", __implementedInterfaces: [])
    }

    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("id", String.self),
        .inlineFragment(AsPerson.self)
      ]}

      class AsPerson: MockTypeCase {
        override class var __parentType: ParentType { .Object(Types.Person)}
        override class var selections: [Selection] {[
          .include(if: "variable", .field("name", String.self)),
        ]}
      }
    }
    MockSchemaConfiguration.stub_graphQLTypeForTypeName = { _ in Types.Person }
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
    struct Types {
      static let Person = Object(__typename: "Person", __implementedInterfaces: [])
    }

    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("id", String.self),
        .inlineFragment(AsPerson.self)
      ]}

      class AsPerson: MockTypeCase {
        override class var __parentType: ParentType { .Object(Types.Person)}
        override class var selections: [Selection] {[
          .include(if: "variable", .field("name", String.self)),
        ]}
      }
    }
    MockSchemaConfiguration.stub_graphQLTypeForTypeName = { _ in Types.Person }
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
    struct Types {
      static let Person = Object(__typename: "Person", __implementedInterfaces: [])
    }

    class GivenFragment: MockFragment {
      override class var selections: [Selection] {[
        .field("name", String.self),
      ]}
    }
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("id", String.self),
        .include(if: "variable", .inlineFragment(AsPerson.self))
      ]}

      class AsPerson: MockTypeCase {
        override class var __parentType: ParentType { .Object(Types.Person)}
        override class var selections: [Selection] {[
          .fragment(GivenFragment.self),
        ]}
      }
    }
    MockSchemaConfiguration.stub_graphQLTypeForTypeName = { _ in Types.Person }
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
        .include(if: !"variable", .field("name", String.self))
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
        .include(if: !"variable", .field("name", String.self))
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
        .include(if: !"variable", [
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
        .include(if: !"variable", [
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
    class GivenFragment: MockFragment {
      override class var selections: [Selection] {[
        .field("name", String.self),
      ]}
    }

    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .include(if: !"variable", .field("name", String.self)),
        .fragment(GivenFragment.self)
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
        .include(if: !"skip" && "include", [
          .field("name", String.self),
          .field("id", String.self),
        ])
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
        .include(if: !"skip" && "include", [
          .field("name", String.self),
          .field("id", String.self),
        ])
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
        .include(if: !"skip" && "include", [
          .field("name", String.self),
          .field("id", String.self),
        ])
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
        .include(if: !"skip" && "include", [
          .field("name", String.self),
          .field("id", String.self),
        ])
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
        .include(if: !"skip", .field("name", String.self)),
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

  func test__booleanCondition_bothSkipAndInclude_onSeperateFieldsForSameSelectionMergedAsOrCondition__givenSkipIsTrue_includeIsTrue_getsValuesForField() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .include(if: "include" || !"skip", .field("name", String.self))
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
        .include(if: !"skip", .field("name", String.self)),
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

  func test__booleanCondition_bothSkipAndInclude_onSeperateFieldsForSameSelectionMergedAsOrCondition__givenSkipIsFalse_includeIsFalse_getsValuesForField() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .include(if: "include" || !"skip", .field("name", String.self))
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
        .include(if: !"skip", .field("name", String.self)),
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

  func test__booleanCondition_bothSkipAndInclude_onSeperateFieldsForSameSelectionMergedAsOrCondition__givenSkipIsFalse_includeIsTrue_getsValuesForField() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .include(if: "include" || !"skip", .field("name", String.self))
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
        .include(if: !"skip", .field("name", String.self)),
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

  func test__booleanCondition_bothSkipAndInclude_onSeperateFieldsForSameSelectionMergedAsOrCondition__givenSkipIsTrue_includeIsFalse_doesNotGetValuesForConditionalFields() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .include(if: "include" || !"skip", .field("name", String.self))
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

  func test__booleanCondition_bothSkipAndInclude_mergedAsComplexLogicalCondition_correctlyEvaluatesConditionalSelections() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var selections: [Selection] {[
        .include(if: ("a" && !"b" && "c") || "d" || !"e", .field("name", String?.self))
      ]}

      var name: String? { __data["name"] }
    }

    let tests: [(variables: [String: Bool], expectedResult: Bool)] = [
      (["a": true,  "b": false, "c": true,  "d": true,  "e": true],  true),  // a && b && c -> true
      (["a": false, "b": false, "c": true,  "d": false, "e": true],  false), // a is false
      (["a": true,  "b": true,  "c": true,  "d": false, "e": true],  false), // b is true
      (["a": true,  "b": false, "c": false, "d": false, "e": true],  false), // c is false
      (["a": false, "b": false, "c": false, "d": true,  "e": true],  true),  // d is true
      (["a": false, "b": false, "c": false, "d": false, "e": false], true),  // e is false
      (["a": false, "b": false, "c": false, "d": true,  "e": true],  true),  // d is true
      (["a": false, "b": false, "c": false, "d": false, "e": true],  false), // e is true
    ]

    let object: JSONObject = ["name": "Luke Skywalker", "id": "1234"]

    for test in tests {
      // when
      let data = try readValues(GivenSelectionSet.self, from: object, variables: test.variables)

      // then
      if test.expectedResult {
        expect(data.name).to(equal("Luke Skywalker"))
      } else {
        expect(data.name).to(beNil())
      }
    }
  }
}
