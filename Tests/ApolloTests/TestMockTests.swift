import XCTest
import Nimble
@testable import Apollo
import ApolloTestSupport
import ApolloAPI

class TestMockTests: XCTestCase {

  func test__mock_givenObject__hasTypenameSet() throws {
    // given
    let mock = Mock<Dog>()

    // then
    expect(mock._data["__typename"] as? String).to(equal("Dog"))
    expect(mock.__typename).to(equal("Dog"))
  }

  func test__mock__setScalarField__fieldIsSet() throws {
    // given
    let mock = Mock<Dog>()

    // when
    mock.species = "Canine"

    // then
    expect(mock._data["species"] as? String).to(equal("Canine"))
    expect(mock.species).to(equal("Canine"))
  }

  func test__mock__setScalarField_toNil__fieldIsSetToNil() throws {
    // given
    let mock = Mock<Dog>()

    // when
    mock.species = "Canine"
    mock.species = nil

    // then
    expect(mock._data["species"]).to(beNil())
    expect(mock.species).to(beNil())
  }

  func test__mock__setListOfScalarField__fieldIsSet() throws {
    // given
    let mock = Mock<Dog>()

    // when
    mock.listOfStrings = ["a", "b", "c"]

    // then
    expect(mock._data["listOfStrings"] as? [String]).to(equal(["a", "b", "c"]))
    expect(mock.listOfStrings).to(equal(["a", "b", "c"]))
  }

  func test__mock__setObjectField__fieldIsSet() throws {
    // given
    let mock = Mock<Dog>()
    let height = Mock<Height>()

    // when
    height.meters = 1
    mock.height = height
    height.feet = 2
    mock.height?.yards = 3

    // then
    expect(mock._data["height"] as? Mock<Height>).to(beIdenticalTo(height))
    expect(mock.height?.meters).to(equal(1))
    expect(mock.height?.feet).to(equal(2))
    expect(mock.height?.yards).to(equal(3))
  }

  func test__mock__setNonOptionalObjectField_toNil__fieldIsSetToNil() throws {
    // given
    let mock = Mock<Dog>()
    let height = Mock<Height>()

    // when
    height.meters = 1
    mock.height = height

    mock.height = nil

    // then
    expect(mock.height).to(beNil())
  }

  func test__mock__setListOfObjectsField__fieldIsSet() throws {
    // given
    let mock = Mock<Dog>()
    let cat1 = Mock<Cat>()
    let cat2 = Mock<Cat>()
    let cat3 = Mock<Cat>()

    // when
    mock.listOfObjects = [cat1, cat2, cat3]

    // then
    expect(mock._data["listOfObjects"] as? [Mock<Cat>]).to(equal([cat1, cat2, cat3]))
    expect(mock.listOfObjects).to(equal([cat1, cat2, cat3]))
  }

  func test__mock__setNestedListOfObjectsField__fieldIsSet() throws {
    // given
    let mock = Mock<Dog>()
    let cat1 = Mock<Cat>()
    let cat2 = Mock<Cat>()
    let cat3 = Mock<Cat>()

    // when
    mock.nestedListOfObjects = [[cat1, cat2, cat3]]

    // then
    expect(mock._data["nestedListOfObjects"] as? [[Mock<Cat>]]).to(equal([[cat1, cat2, cat3]]))
    expect(mock.nestedListOfObjects).to(equal([[cat1, cat2, cat3]]))
  }

  func test__mock__setListOfOptionalObjectsField__fieldIsSet() throws {
    // given
    let mock = Mock<Dog>()
    let cat1 = Mock<Cat>()
    let cat2 = Mock<Cat>()

    // when
    mock.listOfOptionalObjects = [cat1, nil, cat2, nil]

    // then
    expect(mock._data["listOfOptionalObjects"] as? [Mock<Cat>?]).to(equal([cat1, nil, cat2, nil]))
    expect(mock.listOfOptionalObjects).to(equal([cat1, nil, cat2, nil]))
  }

  func test__mock__setEnumField__fieldIsSet() throws {
    // given
    let mock = Mock<Dog>()

    // when
    mock.speciesType = .case(.canine)

    // then
    expect(mock._data["speciesType"] as? GraphQLEnum<Species>).to(equal(.case(.canine)))
    expect(mock.speciesType).to(equal(.case(.canine)))
  }

  func test__mock__setInterfaceField__fieldIsSet() throws {
    // given
    let mock = Mock<Dog>()
    let cat = Mock<Cat>()

    // when
    mock.bestFriend = cat

    // then
    expect(mock._data["bestFriend"] as? Mock<Cat>).to(beIdenticalTo(cat))
    expect(mock.bestFriend as? Mock<Cat>).to(beIdenticalTo(cat))
  }

  func test__mock__setUnionField__fieldIsSet() throws {
    // given
    let mock = Mock<Dog>()
    let cat = Mock<Cat>()

    // when
    mock.unionField = cat

    // then
    expect(mock._data["unionField"] as? Mock<Cat>).to(beIdenticalTo(cat))
    expect(mock.unionField as? Mock<Cat>).to(beIdenticalTo(cat))
  }

  func test__mock__setListOfInterfacesField__fieldIsSet() throws {
    // given
    let mock = Mock<Dog>()
    let cat1 = Mock<Cat>()
    let cat2 = Mock<Cat>()
    let dog1 = Mock<Dog>()

    let list: [AnyMock] = [cat1, cat2, dog1]
    let expected = NSArray(array: list)

    // when
    mock.listOfInterfaces = list

    // then
    expect(expected.isEqual(mock._data["listOfInterfaces"] as? [AnyMock])).to(beTrue())
    expect(expected.isEqual(mock.listOfInterfaces as [AnyMock]?)).to(beTrue())
  }

  func test__mock__setNestedListOfInterfacesField__fieldIsSet() throws {
    // given
    let mock = Mock<Dog>()
    let cat1 = Mock<Cat>()
    let cat2 = Mock<Cat>()
    let dog1 = Mock<Dog>()

    let list: [[AnyMock]] = [[cat1, cat2, dog1]]
    let expected = NSArray(array: list)

    // when
    mock.nestedListOfInterfaces = list

    // then
    expect(expected.isEqual(mock._data["nestedListOfInterfaces"] as? [[AnyMock]])).to(beTrue())
    expect(expected.isEqual(mock.nestedListOfInterfaces as [[AnyMock]]?)).to(beTrue())
  }

  func test__mock__setListOfOptionalInterfacesField__fieldIsSet() throws {
    // given
    let mock = Mock<Dog>()
    let cat1 = Mock<Cat>()
    let cat2 = Mock<Cat>()

    let list: [AnyMock?] = [cat1, nil, cat2, nil]
    let expected = NSArray(array: list as [Any])

    // when
    mock.listOfOptionalInterfaces = list

    // then
    expect(expected.isEqual(mock._data["listOfOptionalInterfaces"] as? [AnyMock?])).to(beTrue())
    expect(expected.isEqual(mock.listOfOptionalInterfaces as [AnyMock?]?)).to(beTrue())
  }

  // MARK: SelectionSet Mock Data Conversion Tests

  func test___selectionSetMockData__givenObjectFieldSetToOtherObject__convertsObjectToDict() throws {
    // given
    let mock = Mock<Dog>()
    let height = Mock<Height>()

    // when
    height.meters = 1
    height.feet = 2
    mock.height = height
    mock.height?.yards = 3

    let actual = mock._selectionSetMockData
    let heightDict = actual["height"] as? JSONObject

    // then
    expect(actual["height"]).to(beAKindOf(JSONObject.self))
    expect(heightDict?["meters"] as? Int).to(equal(1))
    expect(heightDict?["feet"] as? Int).to(equal(2))
    expect(heightDict?["yards"] as? Int).to(equal(3))
  }

  func test___selectionSetMockData__givenListOfObjectsFieldSet__convertsObjectsToDict() throws {
    // given
    let mock = Mock<Dog>()
    let cat = Mock<Cat>()

    // when
    cat.id = "10"
    mock.listOfObjects = [cat]

    let actual = mock._selectionSetMockData
    let listDict = actual["listOfObjects"] as? [JSONObject]

    // then
    expect(listDict).toNot(beNil())
    expect(listDict?[0]["id"] as? String).to(equal("10"))
  }

  func test___selectionSetMockData__givenOptionalListOfObjectsFieldSet__convertsObjectsToDict() throws {
    // given
    let mock = Mock<Dog>()
    let cat = Mock<Cat>()

    // when
    cat.id = "10"
    mock.listOfOptionalObjects = [cat, nil]

    let actual = mock._selectionSetMockData
    let listDict = actual["listOfOptionalObjects"] as? [JSONObject?]

    // then
    expect(listDict).toNot(beNil())
    expect(listDict?[0]?["id"] as? String).to(equal("10"))
  }

  func test___selectionSetMockData__givenCustomScalarField__convertsObjectToDictWithCustomScalarIntact() throws {
    // given
    let mock = Mock<Dog>()
    let customScalar = MockCustomScalar(value: 12)

    // when
    mock.customScalar = customScalar

    let actual = mock._selectionSetMockData
    let actualCustomScalar = actual["customScalar"] as? MockCustomScalar
    // then
    expect(actualCustomScalar?.value).to(equal(12))
  }

  // MARK: Hashable Tests

  func test__hashable__mockIsHashableByData() throws {
    // given
    let mock1 = Mock<Dog>()
    let mock2 = Mock<Dog>()
    let mock3 = Mock<Dog>()
    let mock4 = Mock<Dog>()

    mock1.id = "1"
    mock1.listOfOptionalInterfaces = [nil, Mock<Cat>()]

    mock2.id = "2"
    mock2.listOfOptionalInterfaces = [nil, Mock<Cat>()]

    mock3.id = "1"
    mock3.listOfOptionalInterfaces = [nil, Mock<Dog>()]

    mock4.id = "1"
    mock4.listOfOptionalInterfaces = [nil, Mock<Cat>()]

    // when
    let mocks = Set([mock1, mock2, mock3, mock4])

    // then
    expect(mocks).to(equal(Set([mock1, mock2, mock3])))
  }

}

// MARK: - Generated Example

// MARK: Generated Schema
enum TestMockSchema: SchemaConfiguration {
  static func objectType(forTypename typename: String) -> Object? {
    return nil
  }

  static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
    return nil
  }

  struct Interfaces {
    static let Animal = Interface(name: "Animal")
  }
  struct Types {
    static let Dog = Object(
      typename: "Dog",
      implementedInterfaces: [TestMockSchema.Interfaces.Animal]
    )
    static let Cat = Object(
      typename: "Cat",
      implementedInterfaces: [Interfaces.Animal]
    )
    static let Height = Object(
      typename: "Height",
      implementedInterfaces: []
    )
  }
}

// MARK: Generated Test Mocks Schema
extension MockObject {
  typealias Animal = Interface
  typealias ClassroomPet = Union
}

class Dog: MockObject {
  static let objectType: Object = TestMockSchema.Types.Dog
  static let _mockFields = MockFields()

  struct MockFields {
    @Field<String>("id") public var id
    @Field<String>("species") public var species
    @Field<GraphQLEnum<Species>>("speciesType") public var speciesType
    @Field<MockCustomScalar>("customScalar") public var customScalar
    @Field<Height>("height") public var height
    @Field<[String]>("listOfStrings") public var listOfStrings
    @Field<Animal>("bestFriend") public var bestFriend
    @Field<ClassroomPet>("unionField") public var unionField
    @Field<[Cat]>("listOfObjects") public var listOfObjects
    @Field<[[Cat]]>("nestedListOfObjects") public var nestedListOfObjects
    @Field<[Cat?]>("listOfOptionalObjects") public var listOfOptionalObjects
    @Field<[Animal]>("listOfInterfaces") public var listOfInterfaces
    @Field<[[Animal]]>("nestedListOfInterfaces") public var nestedListOfInterfaces
    @Field<[Animal?]>("listOfOptionalInterfaces") public var listOfOptionalInterfaces
  }
}

class Cat: MockObject {
  static let objectType: Object = TestMockSchema.Types.Cat
  static let _mockFields = MockFields()

  struct MockFields {
    @Field<String>("id") public var id
    @Field<Height>("height") public var height
    @Field<Animal>("bestFriend") public var bestFriend
    @Field<[Animal]>("predators") public var predators
    @Field<String>("species") public var species
    @Field<GraphQLEnum<Species>>("speciesType") public var speciesType
  }
}

class Height: MockObject {
  static let objectType: Object = TestMockSchema.Types.Height
  static let _mockFields = MockFields()

  struct MockFields {
    @Field<Int>("meters") public var meters
    @Field<Int>("feet") public var feet
    @Field<Int>("yards") public var yards
    @Field<Int>("inches") public var inches
  }
}

enum Species: String, EnumType {
  case canine
  case feline
}

struct MockCustomScalar: CustomScalarType, Hashable {
  let value: Int

  init(value: Int) {
    self.value = value
  }

  init(_jsonValue value: ApolloAPI.JSONValue) throws {
    self.value = value as! Int
  }

  var _jsonValue: ApolloAPI.JSONValue { value }
}
