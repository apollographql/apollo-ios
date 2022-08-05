import XCTest
@testable import Apollo
@testable import ApolloAPI
import ApolloInternalTestHelpers
import Nimble

class SelectionSetTests: XCTestCase {

  func test__selection_givenOptionalField_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("name", String?.self)
      ]}

      var name: String? { __data["name"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "name": "Johnny Tsunami"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.name).to(equal("Johnny Tsunami"))
  }

  func test__selection_givenOptionalField_givenNilValue__returnsNil() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("name", String?.self)
      ]}

      var name: String? { __data["name"] }
    }

    let object: JSONObject = [
      "__typename": "Human"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.name).to(beNil())
  }

  // MARK: Scalar - Nested Array Tests

  func test__selection__nestedArrayOfScalar_nonNull_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("nestedList", [[String]].self)
      ]}

      var nestedList: [[String]] { __data["nestedList"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "nestedList": [["A"]]
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.nestedList).to(equal([["A"]]))
  }

  // MARK: Entity

  func test__selection_givenRequiredEntityField_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("friend", Friend.self)
      ]}

      var friend: Friend { __data["friend"] }

      class Friend: MockSelectionSet, SelectionSet {
        typealias Schema = MockSchemaConfiguration

        override class var selections: [Selection] {[
          .field("__typename", String.self),
        ]}
      }
    }

    let friendData: JSONObject = ["__typename": "Human"]

    let object: JSONObject = [
      "__typename": "Human",
      "friend": friendData
    ]

    let expected = Hero.Friend(data: DataDict(friendData, variables: nil))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.friend).to(equal(expected))
  }

  func test__selection_givenOptionalEntityField_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("friend", Hero?.self)
      ]}

      var friend: Hero? { __data["friend"] }
    }

    let friendData: JSONObject = ["__typename": "Human"]

    let object: JSONObject = [
      "__typename": "Human",
      "friend": friendData
    ]

    let expected = Hero(data: DataDict(friendData, variables: nil))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.friend).to(equal(expected))
  }

  func test__selection_givenOptionalEntityField_givenNilValue__returnsNil() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("friend", Hero?.self)
      ]}

      var friend: Hero? { __data["friend"] }
    }

    let object: JSONObject = [
      "__typename": "Human"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.friend).to(beNil())
  }

  // MARK: Entity - Array Tests

  func test__selection__arrayOfEntity_nonNull_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("friends", [Hero].self)
      ]}

      var friends: [Hero] { __data["friends"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "friends": [
        [
          "__typename": "Human",
          "friends": []
        ]
      ]
    ]

    let expected = Hero(data: DataDict(
      [
        "__typename": "Human",
        "friends": []
      ],
      variables: nil
    ))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.friends).to(equal([expected]))
  }

  func test__selection__arrayOfEntity_nullableEntity_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("friends", [Hero?].self)
      ]}

      var friends: [Hero?] { __data["friends"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "friends": [
        [
          "__typename": "Human",
          "friends": []
        ]
      ]
    ]

    let expected = Hero(data: DataDict(
      [
        "__typename": "Human",
        "friends": []
      ],
      variables: nil
    ))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.friends).to(equal([expected]))
  }

  func test__selection__arrayOfEntity_nullableEntity_givenNilValueInList__returnsArrayWithNil() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("friends", [Hero?].self)
      ]}

      var friends: [Hero?] { __data["friends"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "friends": [
        Hero?.none,
        ["__typename": "Human", "friends": []],
        Hero?.none
      ]
    ]

    let expected = Hero(data: DataDict(
      [
        "__typename": "Human",
        "friends": []
      ],
      variables: nil
    ))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.friends).to(equal([Hero?.none, expected, Hero?.none]))
  }

  func test__selection__arrayOfEntity_nullableList_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("friends", [Hero]?.self)
      ]}

      var friends: [Hero]? { __data["friends"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "friends": [
        [
          "__typename": "Human",
          "friends": []
        ]
      ]
    ]

    let expected = Hero(data: DataDict(
      [
        "__typename": "Human",
        "friends": []
      ],
      variables: nil
    ))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.friends).to(equal([expected]))
  }

  func test__selection__arrayOfEntity_nullableList_givenNoListValue__returnsNil() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("friends", [Hero]?.self)
      ]}

      var friends: [Hero]? { __data["friends"] }
    }

    let object: JSONObject = [
      "__typename": "Human"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.friends).to(beNil())
  }

  // MARK: Entity - Nested Array Tests

  func test__selection__nestedArrayOfEntity_nonNull_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("nestedList", [[Hero]].self)
      ]}

      var nestedList: [[Hero]] { __data["nestedList"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "nestedList": [[
        [
          "__typename": "Human",
          "nestedList": [[]]
        ]
      ]]
    ]

    let expected = Hero(data: DataDict(
      [
        "__typename": "Human",
        "nestedList": [[]]
      ],
      variables: nil
    ))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.nestedList).to(equal([[expected]]))
  }

  func test__selection__nestedArrayOfEntity_nullableInnerList_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("nestedList", [[Hero]?].self)
      ]}

      var nestedList: [[Hero]?] { __data["nestedList"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "nestedList": [[
        [
          "__typename": "Human",
          "nestedList": [[]]
        ]
      ]]
    ]

    let expected = Hero(data: DataDict(
      [
        "__typename": "Human",
        "nestedList": [[]]
      ],
      variables: nil
    ))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.nestedList).to(equal([[expected]]))
  }

  func test__selection__nestedArrayOfEntity_nullableInnerList_givenNilValues__returnsListWithNils() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("nestedList", [[Hero]?].self)
      ]}

      var nestedList: [[Hero]?] { __data["nestedList"] }
    }

    let nestedObjectData: JSONObject = [
      "__typename": "Human",
      "nestedList": [[]]
    ]

    let object: JSONObject = [
      "__typename": "Human",
      "nestedList": [
        [Hero]?.none,
        [nestedObjectData],
        [Hero]?.none,
      ]
    ]

    let expectedItem = Hero(data: DataDict(nestedObjectData, variables: nil))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.nestedList).to(equal([[Hero]?.none, [expectedItem], [Hero]?.none]))
  }

  func test__selection__nestedArrayOfEntity_nullableEntity_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("nestedList", [[Hero?]].self)
      ]}

      var nestedList: [[Hero?]] { __data["nestedList"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "nestedList": [[
        [
          "__typename": "Human",
          "nestedList": [[]]
        ]
      ]]
    ]

    let expected = Hero(data: DataDict(
      [
        "__typename": "Human",
        "nestedList": [[]]
      ],
      variables: nil
    ))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.nestedList).to(equal([[expected]]))
  }

  func test__selection__nestedArrayOfEntity_nullableOuterList_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .field("nestedList", [[Hero]]?.self)
      ]}

      var nestedList: [[Hero]]? { __data["nestedList"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "nestedList": [[
        [
          "__typename": "Human",
          "nestedList": [[]]
        ]
      ]]
    ]

    let expected = Hero(data: DataDict(
      [
        "__typename": "Human",
        "nestedList": [[]]
      ],
      variables: nil
    ))

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.nestedList).to(equal([[expected]]))
  }  

  // MARK: TypeCase Conversion Tests

  func test__asInlineFragment_givenObjectType_returnsTypeIfCorrectType() {
    // given
    struct Types {
      static let Human = Object(typename: "Human", implementedInterfaces: [])
      static let Droid = Object(typename: "Droid", implementedInterfaces: [])
    }

    MockSchemaConfiguration.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Types.Human
      case "Droid": return Types.Droid
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .inlineFragment(AsHuman.self),
        .inlineFragment(AsDroid.self),
      ]}

      var asHuman: AsHuman? { _asInlineFragment() }
      var asDroid: AsDroid? { _asInlineFragment() }

      class AsHuman: MockTypeCase, SelectionSet {
        typealias Schema = MockSchemaConfiguration

        override class var __parentType: ParentType { Types.Human }
        override class var selections: [Selection] {[
          .field("name", String.self)
        ]}
      }

      class AsDroid: MockTypeCase, SelectionSet {
        typealias Schema = MockSchemaConfiguration

        override class var __parentType: ParentType { Types.Droid }
        override class var selections: [Selection] {[
          .field("primaryFunction", String.self)
        ]}
      }
    }

    let object: JSONObject = [
      "__typename": "Droid",
      "name": "R2-D2"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.asHuman).to(beNil())
    expect(actual.asDroid).toNot(beNil())
  }

  func test__asInlineFragment_givenInterfaceType_typeForTypeNameImplementsInterface_returnsType() {
    // given
    struct Types {
      static let Humanoid = Interface(name: "Humanoid")
      static let Human = Object(typename: "Human", implementedInterfaces: [Humanoid])
    }

    MockSchemaConfiguration.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Types.Human
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .inlineFragment(AsHumanoid.self),
      ]}

      var asHumanoid: AsHumanoid? { _asInlineFragment() }

      class AsHumanoid: MockTypeCase, SelectionSet {
        typealias Schema = MockSchemaConfiguration

        override class var __parentType: ParentType { Types.Humanoid }
        override class var selections: [Selection] {[
          .field("name", String.self)
        ]}
      }

    }

    let object: JSONObject = [
      "__typename": "Human",
      "name": "Han Solo"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.asHumanoid).toNot(beNil())
  }

  func test__asInlineFragment_givenInterfaceType_typeForTypeNameDoesNotImplementInterface_returnsNil() {
    // given
    struct Types {
      static let Humanoid = Interface(name: "Humanoid")
      static let Droid = Object(typename: "Droid", implementedInterfaces: [])
    }

    MockSchemaConfiguration.stub_objectTypeForTypeName = {
      switch $0 {
      case "Droid": return Types.Droid
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .inlineFragment(AsHumanoid.self),
      ]}

      var asHumanoid: AsHumanoid? { _asInlineFragment() }

      class AsHumanoid: MockTypeCase, SelectionSet {
        typealias Schema = MockSchemaConfiguration

        override class var __parentType: ParentType { Types.Humanoid }
        override class var selections: [Selection] {[
          .field("name", String.self)
        ]}
      }

    }

    let object: JSONObject = [
      "__typename": "Droid",
      "name": "R2-D2"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.asHumanoid).to(beNil())
  }

  func test__asInlineFragment_givenUnionType_typeNameIsTypeInUnionPossibleTypes_returnsType() {
    // given
    enum Types {
      static let Human = Object(typename: "Human", implementedInterfaces: [])
      static let Character = Union(name: "Character", possibleTypes: [Types.Human])
    }

    MockSchemaConfiguration.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Types.Human
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .inlineFragment(AsCharacter.self),
      ]}

      var asCharacter: AsCharacter? { _asInlineFragment() }

      class AsCharacter: MockTypeCase, SelectionSet {
        typealias Schema = MockSchemaConfiguration

        override class var __parentType: ParentType { Types.Character }
        override class var selections: [Selection] {[
          .field("name", String.self)
        ]}
      }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "name": "Han Solo"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.asCharacter).toNot(beNil())
  }

  func test__asInlineFragment_givenUnionType_typeNameNotIsTypeInUnionPossibleTypes_returnsNil() {
    // given
    enum Types {
      static let Human = Object(typename: "Human", implementedInterfaces: [])
      static let Character = Union(name: "Character", possibleTypes: [])
    }

    MockSchemaConfiguration.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Types.Human
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .inlineFragment(AsCharacter.self),
      ]}

      var asCharacter: AsCharacter? { _asInlineFragment() }

      class AsCharacter: MockTypeCase, SelectionSet {
        typealias Schema = MockSchemaConfiguration

        override class var __parentType: ParentType { Types.Character }
        override class var selections: [Selection] {[
          .field("name", String.self)
        ]}
      }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "name": "Han Solo"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: nil))

    // then
    expect(actual.asCharacter).to(beNil())
  }

  // MARK: - To Fragment Conversion Tests

  func test__toFragment_givenInclusionCondition_true_returnsFragment() {
    // given
    class GivenFragment: MockFragment { }

    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .include(if: "includeFragment", .fragment(GivenFragment.self))
      ]}

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var givenFragment: GivenFragment? { _toFragment(if: "includeFragment") }
      }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "name": "Han Solo"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: ["includeFragment": true]))

    // then
    expect(actual.fragments.givenFragment).toNot(beNil())
  }

  func test__toFragment_givenInclusionCondition_false_returnsNil() {
    // given
    class GivenFragment: MockFragment { }

    class Hero: MockSelectionSet, SelectionSet {
      typealias Schema = MockSchemaConfiguration

      override class var selections: [Selection] {[
        .field("__typename", String.self),
        .include(if: "includeFragment", .fragment(GivenFragment.self))
      ]}

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var givenFragment: GivenFragment? { _toFragment(if: "includeFragment") }
      }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "name": "Han Solo"
    ]

    // when
    let actual = Hero(data: DataDict(object, variables: ["includeFragment": false]))

    // then
    expect(actual.fragments.givenFragment).to(beNil())
  }

}
