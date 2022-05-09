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

  func test__mock__setInterfaceField__fieldIsSet() throws {
    // given
    let mock = Mock<Dog>()
    let cat = Mock<Cat>()

    // when
//    mock.bestFriend = cat

    // then
//    expect(mock._data["height"] as? Mock<Height>).to(beIdenticalTo(height))
//    expect(mock.height?.meters).to(equal(1))
  }

}

class Dog: Object {
  override public class var __typename: StaticString { "Dog" }
  override public class var __metadata: Metadata { _metadata }
  private static let _metadata: Metadata = Metadata(
    implements: [
      Animal.self
    ]
  )
}

class Cat: Object {
  override public class var __typename: StaticString { "Dog" }
  override public class var __metadata: Metadata { _metadata }
  private static let _metadata: Metadata = Metadata(
    implements: [
      Animal.self
    ]
  )
}

class Height: Object {
  override public class var __typename: StaticString { "Height" }
}

class Animal: Interface {}

// MARK: Mockable Extensions

extension Dog: Mockable {
  static let __mockFields = MockFields()

  struct MockFields {
    @Field<String>("id") public var id
    @Field<Height>("height") public var height
    @Field<Animal>("bestFriend") public var bestFriend
    @Field<[Animal]>("predators") public var predators
    @Field<String>("species") public var species
  }
}

extension Cat: Mockable {
  static let __mockFields = MockFields()

  struct MockFields {
    @Field<String>("id") public var id
    @Field<Height>("height") public var height
    @Field<Animal>("bestFriend") public var bestFriend
    @Field<[Animal]>("predators") public var predators
    @Field<String>("species") public var species
  }
}

extension Height: Mockable {
  static let __mockFields = MockFields()

  struct MockFields {
    @Field<Int>("meters") public var meters
    @Field<Int>("feet") public var feet
    @Field<Int>("yards") public var yards
    @Field<Int>("inches") public var inches
  }
}

