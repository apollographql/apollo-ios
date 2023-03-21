import XCTest
@testable import Apollo
@testable import ApolloAPI
import ApolloInternalTestHelpers
import Nimble

class SelectionSetTests: XCTestCase {

  func test__selection_givenOptionalField_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
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
    let actual = try! Hero(data: object)

    // then
    expect(actual.name).to(equal("Johnny Tsunami"))
  }

  func test__selection_givenOptionalField_missingValue__returnsNil() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
        .field("__typename", String.self),
        .field("name", String?.self)
      ]}

      var name: String? { __data["name"] }
    }

    let object: JSONObject = [
      "__typename": "Human"
    ]

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.name).to(beNil())
  }

  func test__selection_givenOptionalField_givenNilValue__returnsNil() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
        .field("__typename", String.self),
        .field("name", String?.self)
      ]}

      var name: String? { __data["name"] }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "name": String?.none
    ]

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.name).to(beNil())
  }

  // MARK: Scalar - Nested Array Tests

  func test__selection__nestedArrayOfScalar_nonNull_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
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
    let actual = try! Hero(data: object)

    // then
    expect(actual.nestedList).to(equal([["A"]]))
  }

  // MARK: Entity

  func test__selection_givenRequiredEntityField_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
        .field("__typename", String.self),
        .field("friend", Friend.self)
      ]}

      var friend: Friend { __data["friend"] }

      class Friend: MockSelectionSet {
        typealias Schema = MockSchemaMetadata

        override class var __selections: [Selection] {[
          .field("__typename", String.self),
        ]}
      }
    }

    let friendData: JSONObject = ["__typename": "Human"]

    let object: JSONObject = [
      "__typename": "Human",
      "friend": friendData
    ]

    let expected = try! Hero.Friend(data: friendData)

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.friend).to(equal(expected))
  }

  func test__selection_givenOptionalEntityField_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
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

    let expected = try! Hero(data: friendData, variables: nil)

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.friend).to(equal(expected))
  }

  func test__selection_givenOptionalEntityField_givenNilValue__returnsNil() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
        .field("__typename", String.self),
        .field("friend", Hero?.self)
      ]}

      var friend: Hero? { __data["friend"] }
    }

    let object: JSONObject = [
      "__typename": "Human"
    ]

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.friend).to(beNil())
  }

  // MARK: Entity - Array Tests

  func test__selection__arrayOfEntity_nonNull_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
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

    let expected = try! Hero(
      data: [
        "__typename": "Human",
        "friends": []
      ],
      variables: nil
    )

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.friends).to(equal([expected]))
  }

  func test__selection__arrayOfEntity_nullableEntity_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
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

    let expected = try! Hero(
      data: [
        "__typename": "Human",
        "friends": []
      ],
      variables: nil
    )

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.friends).to(equal([expected]))
  }

  func test__selection__arrayOfEntity_nullableEntity_givenNilValueInList__returnsArrayWithNil() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
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

    let expected = try! Hero(
      data: [
        "__typename": "Human",
        "friends": []
      ],
      variables: nil
    )

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.friends).to(equal([Hero?.none, expected, Hero?.none]))
  }

  func test__selection__arrayOfEntity_nullableList_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
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

    let expected = try! Hero(
      data: [
        "__typename": "Human",
        "friends": []
      ],
      variables: nil
    )

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.friends).to(equal([expected]))
  }

  func test__selection__arrayOfEntity_nullableList_givenNoListValue__returnsNil() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
        .field("__typename", String.self),
        .field("friends", [Hero]?.self)
      ]}

      var friends: [Hero]? { __data["friends"] }
    }

    let object: JSONObject = [
      "__typename": "Human"
    ]

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.friends).to(beNil())
  }

  // MARK: Entity - Nested Array Tests

  func test__selection__nestedArrayOfEntity_nonNull_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
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

    let expected = try! Hero(
      data: [
        "__typename": "Human",
        "nestedList": [[]]
      ],
      variables: nil
    )

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.nestedList).to(equal([[expected]]))
  }

  func test__selection__nestedArrayOfEntity_nullableInnerList_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
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

    let expected = try! Hero(
      data: [
        "__typename": "Human",
        "nestedList": [[]]
      ],
      variables: nil
    )

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.nestedList).to(equal([[expected]]))
  }

  func test__selection__nestedArrayOfEntity_nullableInnerList_givenNilValues__returnsListWithNils() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
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

    let expectedItem = try! Hero(data: nestedObjectData, variables: nil)

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.nestedList).to(equal([[Hero]?.none, [expectedItem], [Hero]?.none]))
  }

  func test__selection__nestedArrayOfEntity_nullableEntity_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
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
    
    let expected = try! Hero(
      data: [
        "__typename": "Human",
        "nestedList": [[]]
      ],
      variables: nil
    )

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.nestedList).to(equal([[expected]]))
  }

  func test__selection__nestedArrayOfEntity_nullableOuterList_givenValue__returnsValue() {
    // given
    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
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

    let expected = try! Hero(
      data: [
        "__typename": "Human",
        "nestedList": [[]]
      ],
      variables: nil
    )

    // when
    let actual = try! Hero(data: object)

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

    MockSchemaMetadata.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Types.Human
      case "Droid": return Types.Droid
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
        .field("__typename", String.self),
        .inlineFragment(AsHuman.self),
        .inlineFragment(AsDroid.self),
      ]}

      var asHuman: AsHuman? { _asInlineFragment() }
      var asDroid: AsDroid? { _asInlineFragment() }

      class AsHuman: MockTypeCase {
        typealias Schema = MockSchemaMetadata

        override class var __parentType: ParentType { Types.Human }
        override class var __selections: [Selection] {[
          .field("name", String?.self)
        ]}
      }

      class AsDroid: MockTypeCase {
        typealias Schema = MockSchemaMetadata

        override class var __parentType: ParentType { Types.Droid }
        override class var __selections: [Selection] {[
          .field("primaryFunction", String?.self)
        ]}
      }
    }

    let object: JSONObject = [
      "__typename": "Droid",
      "name": "R2-D2"
    ]

    // when
    let actual = try! Hero(data: object)

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

    MockSchemaMetadata.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Types.Human
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
        .field("__typename", String.self),
        .inlineFragment(AsHumanoid.self),
      ]}

      var asHumanoid: AsHumanoid? { _asInlineFragment() }

      class AsHumanoid: MockTypeCase {
        typealias Schema = MockSchemaMetadata

        override class var __parentType: ParentType { Types.Humanoid }
        override class var __selections: [Selection] {[
          .field("name", String.self)
        ]}
      }

    }

    let object: JSONObject = [
      "__typename": "Human",
      "name": "Han Solo"
    ]

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.asHumanoid).toNot(beNil())
  }

  func test__asInlineFragment_givenInterfaceType_typeForTypeNameDoesNotImplementInterface_returnsNil() {
    // given
    struct Types {
      static let Humanoid = Interface(name: "Humanoid")
      static let Droid = Object(typename: "Droid", implementedInterfaces: [])
    }

    MockSchemaMetadata.stub_objectTypeForTypeName = {
      switch $0 {
      case "Droid": return Types.Droid
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
        .field("__typename", String.self),
        .inlineFragment(AsHumanoid.self),
      ]}

      var asHumanoid: AsHumanoid? { _asInlineFragment() }

      class AsHumanoid: MockTypeCase {
        typealias Schema = MockSchemaMetadata

        override class var __parentType: ParentType { Types.Humanoid }
        override class var __selections: [Selection] {[
          .field("name", String.self)
        ]}
      }

    }

    let object: JSONObject = [
      "__typename": "Droid",
      "name": "R2-D2"
    ]

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.asHumanoid).to(beNil())
  }

  func test__asInlineFragment_givenUnionType_typeNameIsTypeInUnionPossibleTypes_returnsType() {
    // given
    enum Types {
      static let Human = Object(typename: "Human", implementedInterfaces: [])
      static let Character = Union(name: "Character", possibleTypes: [Types.Human])
    }

    MockSchemaMetadata.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Types.Human
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
        .field("__typename", String.self),
        .inlineFragment(AsCharacter.self),
      ]}

      var asCharacter: AsCharacter? { _asInlineFragment() }

      class AsCharacter: MockTypeCase {
        typealias Schema = MockSchemaMetadata

        override class var __parentType: ParentType { Types.Character }
        override class var __selections: [Selection] {[
          .field("name", String.self)
        ]}
      }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "name": "Han Solo"
    ]

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.asCharacter).toNot(beNil())
  }

  func test__asInlineFragment_givenUnionType_typeNameNotIsTypeInUnionPossibleTypes_returnsNil() {
    // given
    enum Types {
      static let Human = Object(typename: "Human", implementedInterfaces: [])
      static let Character = Union(name: "Character", possibleTypes: [])
    }

    MockSchemaMetadata.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Types.Human
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
        .field("__typename", String.self),
        .inlineFragment(AsCharacter.self),
      ]}

      var asCharacter: AsCharacter? { _asInlineFragment() }

      class AsCharacter: MockTypeCase {
        typealias Schema = MockSchemaMetadata

        override class var __parentType: ParentType { Types.Character }
        override class var __selections: [Selection] {[
          .field("name", String.self)
        ]}
      }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "name": "Han Solo"
    ]

    // when
    let actual = try! Hero(data: object)

    // then
    expect(actual.asCharacter).to(beNil())
  }

  // MARK: - To Fragment Conversion Tests

  func test__toFragment_givenInclusionCondition_true_returnsFragment() {
    // given
    class GivenFragment: MockFragment { }

    class Hero: AbstractMockSelectionSet<Hero.Fragments> {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
        .field("__typename", String.self),
        .include(if: "includeFragment", .fragment(GivenFragment.self))
      ]}

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var givenFragment: GivenFragment? { _toFragment(if: "includeFragment") }
      }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "name": "Han Solo"
    ]

    // when
    let actual = try! Hero(data: object, variables: ["includeFragment": true])

    // then
    expect(actual.fragments.givenFragment).toNot(beNil())
  }

  func test__toFragment_givenInclusionCondition_false_returnsNil() {
    // given
    class GivenFragment: MockFragment { }

    class Hero: AbstractMockSelectionSet<Hero.Fragments> {
      typealias Schema = MockSchemaMetadata

      override class var __selections: [Selection] {[
        .field("__typename", String.self),
        .include(if: "includeFragment", .fragment(GivenFragment.self))
      ]}

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var givenFragment: GivenFragment? { _toFragment(if: "includeFragment") }
      }
    }

    let object: JSONObject = [
      "__typename": "Human",
      "name": "Han Solo"
    ]

    // when
    let actual = try! Hero(data: object, variables: ["includeFragment": false])

    // then
    expect(actual.fragments.givenFragment).to(beNil())
  }

  // MARK: - Initializer Tests

  func test__selectionInitializer_givenInitTypeWithTypeCondition__canConvertToConditionalType() {
    // given
    struct Types {
      static let Animal = Interface(name: "Animal")
      static let Human = Object(typename: "Human", implementedInterfaces: [Animal])
    }

    MockSchemaMetadata.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Types.Human
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __parentType: ParentType { Types.Human }
      override class var __selections: [Selection] {[
        .inlineFragment(AsAnimal.self)
      ]}

      var asAnimal: AsAnimal? { _asInlineFragment() }

      class AsAnimal: ConcreteMockTypeCase<Hero> {
        typealias Schema = MockSchemaMetadata

        override class var __parentType: ParentType { Types.Animal }
        override class var __selections: [Selection] {[
          .field("name", String.self)
        ]}
        var name: String { __data["name"] }

        convenience init(
          __typename: String,
          name: String
        ) {
          let objectType = Object(
            typename: __typename,
            implementedInterfaces: [Types.Animal]
          )
          self.init(_dataDict: DataDict(
            data: [
              "__typename": objectType.typename,
              "name": name
            ]
          ))
        }
      }

    }

    // when
    let actual = Hero.AsAnimal(__typename: "Droid", name: "Artoo").asRootEntityType

    // then
    expect(actual.asAnimal?.name).to(equal("Artoo"))
  }

  func test__selectionInitializer_givenInitNestedTypeWithTypeCondition__canConvertToConditionalType() {
    // given
    struct Types {
      static let Query = Object(typename: "Query", implementedInterfaces: [])
      static let Animal = Interface(name: "Animal")
      static let Human = Object(typename: "Human", implementedInterfaces: [Animal])
    }

    MockSchemaMetadata.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Types.Human
      default: XCTFail(); return nil
      }
    }

    class Data: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __parentType: ParentType { Types.Query }
      override class var __selections: [Selection] {[
        .field("hero", Hero.self)
      ]}

      public var hero: Hero { __data["hero"] }

      convenience init(
        hero: Hero
      ) {
        let objectType = Types.Query
        self.init(_dataDict: DataDict(data: [
          "__typename": objectType.typename,
          "hero": hero._fieldData
        ]))
      }

      class Hero: MockSelectionSet {
        typealias Schema = MockSchemaMetadata

        override class var __parentType: ParentType { Types.Human }
        override class var __selections: [Selection] {[
          .inlineFragment(AsAnimal.self)
        ]}

        var asAnimal: AsAnimal? { _asInlineFragment() }

        class AsAnimal: ConcreteMockTypeCase<Hero> {
          typealias Schema = MockSchemaMetadata

          override class var __parentType: ParentType { Types.Animal }
          override class var __selections: [Selection] {[
            .field("name", String.self)
          ]}
          var name: String { __data["name"] }

          convenience init(
            __typename: String,
            name: String
          ) {
            let objectType = Object(
              typename: __typename,
              implementedInterfaces: [Types.Animal]
            )
            self.init(_dataDict: DataDict(data: [
              "__typename": objectType.typename,
              "name": name
            ]))
          }
        }
      }
    }

    // when
    let actual = Data(
      hero: .AsAnimal(__typename: "Droid", name: "Artoo").asRootEntityType
    )

    // then
    expect(actual.hero.asAnimal?.name).to(equal("Artoo"))
  }

  func test__selectionInitializer_givenInitTypeWithInclusionCondition__canConvertToConditionalType() {
    // given
    struct Types {
      static let Human = Object(typename: "Human", implementedInterfaces: [])
    }

    MockSchemaMetadata.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Types.Human
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __parentType: ParentType { Types.Human }
      override class var __selections: [Selection] {[
        .include(if: "a", .inlineFragment(IfA.self))
      ]}

      var ifA: IfA? { _asInlineFragment(if: "a") }

      class IfA: ConcreteMockTypeCase<Hero> {
        typealias Schema = MockSchemaMetadata

        typealias RootEntityType = Hero
        override class var __parentType: ParentType { Types.Human }
        override class var __selections: [Selection] {[
          .field("name", String.self)
        ]}
        var name: String { __data["name"] }

        convenience init(
          name: String
        ) {
          let objectType = Types.Human
          self.init(_dataDict: DataDict(data: [
            "__typename": objectType.typename,
            "name": name
          ]))
        }
      }

    }

    // when
    let actual = Hero.IfA(name: "Han Solo").asRootEntityType

    // then
    expect(actual.ifA?.name).to(equal("Han Solo"))
  }

  func test__selectionInitializer_givenInitTypeWithInclusionCondition__cannotConvertToOtherConditionalType() {
    // given
    struct Types {
      static let Human = Object(typename: "Human", implementedInterfaces: [])
    }

    MockSchemaMetadata.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Types.Human
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __parentType: ParentType { Types.Human }
      override class var __selections: [Selection] {[
        .include(if: "a", .inlineFragment(IfA.self)),
        .include(if: "b", .inlineFragment(IfB.self))
      ]}

      var ifA: IfA? { _asInlineFragment(if: "a") }
      var ifB: IfB? { _asInlineFragment(if: "b") }

      class IfA: ConcreteMockTypeCase<Hero> {
        typealias Schema = MockSchemaMetadata
        override class var __parentType: ParentType { Types.Human }
        override class var __selections: [Selection] {[
          .field("name", String.self)
        ]}
        var name: String { __data["name"] }

        convenience init(
          name: String
        ) {
          let objectType = Types.Human
          self.init(_dataDict: DataDict(data: [
            "__typename": objectType.typename,
            "name": name
          ]))
        }
      }
      class IfB: ConcreteMockTypeCase<Hero> {
        typealias Schema = MockSchemaMetadata
        override class var __parentType: ParentType { Types.Human }
        override class var __selections: [Selection] {[
        ]}
      }
    }

    // when
    let actual = Hero.IfA(name: "Han Solo").asRootEntityType

    // then
    expect(actual.ifA).toNot(beNil())
    expect(actual.ifB).to(beNil())
  }

  func test__selectionInitializer_givenInitNestedTypeWithInclusionCondition__cannotConvertToOtherConditionalType() {
    // given
    struct Types {
      static let Human = Object(typename: "Human", implementedInterfaces: [])
      static let Query = Object(typename: "Query", implementedInterfaces: [])
    }

    MockSchemaMetadata.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Types.Human
      default: XCTFail(); return nil
      }
    }

    class Data: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __parentType: ParentType { Types.Query }
      override class var __selections: [Selection] {[
        .field("hero", Hero.self)
      ]}

      public var hero: Hero { __data["hero"] }

      convenience init(
        hero: Hero
      ) {
        let objectType = Types.Query
        self.init(_dataDict: DataDict(data: [
          "__typename": objectType.typename,
          "hero": hero._fieldData
        ]
                                     ))
      }

      class Hero: MockSelectionSet {
        typealias Schema = MockSchemaMetadata

        override class var __parentType: ParentType { Types.Human }
        override class var __selections: [Selection] {[
          .include(if: "a", .inlineFragment(IfA.self)),
          .include(if: "b", .inlineFragment(IfB.self))
        ]}

        var ifA: IfA? { _asInlineFragment(if: "a") }
        var ifB: IfB? { _asInlineFragment(if: "b") }

        class IfA: ConcreteMockTypeCase<Hero> {
          typealias Schema = MockSchemaMetadata
          override class var __parentType: ParentType { Types.Human }
          override class var __selections: [Selection] {[
            .field("name", String.self),
            .field("friend", Friend.self)
          ]}
          var name: String { __data["name"] }
          var friend: Friend { __data["friend"] }

          convenience init(
            name: String,
            friend: Friend? = nil
          ) {
            let objectType = Types.Human
            self.init(_dataDict: DataDict(data: [
              "__typename": objectType.typename,
              "name": name,
              "friend": friend._fieldData
            ]))
          }

          class Friend: MockSelectionSet {
            typealias Schema = MockSchemaMetadata

            override class var __parentType: ParentType { Types.Human }
            override class var __selections: [Selection] {[
              .include(if: !"c", .inlineFragment(IfNotC.self))
            ]}

            var ifNotC: IfNotC? { _asInlineFragment(if: !"c") }

            class IfNotC: ConcreteMockTypeCase<Friend> {
              typealias Schema = MockSchemaMetadata
              override class var __parentType: ParentType { Types.Human }
              override class var __selections: [Selection] {[
                .field("name", String.self)
              ]}
              var name: String { __data["name"] }

              convenience init(
                name: String
              ) {
                let objectType = Types.Human
                self.init(_dataDict: DataDict(data: [
                  "__typename": objectType.typename,
                  "name": name
                ]))
              }
            }
          }
        }

        class IfB: ConcreteMockTypeCase<Hero> {
          typealias Schema = MockSchemaMetadata
          override class var __parentType: ParentType { Types.Human }
          override class var __selections: [Selection] {[]}

          convenience init() {
            let objectType = Types.Human
            self.init(_dataDict: DataDict(data: [
              "__typename": objectType.typename
            ]))
          }
        }
      }
    }

    // when
    let actual = Data(
      hero: .IfA(
        name: "Han Solo",
        friend: Data.Hero.IfA.Friend.IfNotC(name: "Leia Organa").asRootEntityType
      ).asRootEntityType
    )

    // then
    expect(actual.hero.ifA).toNot(beNil())
    expect(actual.hero.ifA?.friend.ifNotC).toNot(beNil())
    expect(actual.hero.ifB).to(beNil())
  }

  func test__selectionInitializer_givenInitMultipleTypesWithConflictingInclusionConditions__canConvertToAllConditionalTypes() {
    // given
    struct Types {
      static let Human = Object(typename: "Human", implementedInterfaces: [])
    }

    MockSchemaMetadata.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Types.Human
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __parentType: ParentType { Types.Human }
      override class var __selections: [Selection] {[
        .include(if: "a", .inlineFragment(IfA.self))
      ]}

      var ifA: IfA? { _asInlineFragment(if: "a") }

      class IfA: ConcreteMockTypeCase<Hero> {
        typealias Schema = MockSchemaMetadata
        override class var __parentType: ParentType { Types.Human }
        override class var __selections: [Selection] {[
          .field("name", String.self)
        ]}
        var name: String { __data["name"] }

        convenience init(
          name: String
        ) {
          let objectType = Types.Human
          self.init(_dataDict: DataDict(data: [
            "__typename": objectType.typename,
            "name": name
          ]))
        }
      }

    }

    // when
    let actual = Hero.IfA(name: "Han Solo").asRootEntityType

    // then
    expect(actual.ifA?.name).to(equal("Han Solo"))
  }

  // MARK: Initializer - Optional Field Tests

  func test__selectionInitializer_givenOptionalField__fieldIsPresentWithOptionalNilValue() {
    // given
    struct Types {
      static let Human = Object(typename: "Human", implementedInterfaces: [])
    }

    MockSchemaMetadata.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Types.Human
      default: XCTFail(); return nil
      }
    }

    class Hero: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __parentType: ParentType { Types.Human }
      override class var __selections: [Selection] {[
        .field("name", String?.self)
      ]}

      var name: String? { __data["name"] }

      convenience init(
        name: String? = nil
      ) {
        let objectType = Types.Human
        self.init(_dataDict: DataDict(data: [
          "__typename": objectType.typename,
          "name": name
        ]))
      }
    }

    // when
    let actual = Hero(name: nil)

    // then
    expect(actual.name).to(beNil())
    expect(actual.__data._data.keys.contains("name")).to(beTrue())

    guard let nameValue = actual.__data._data["name"] else {
      fail("name should be Optional.some(Optional.none)")
      return
    }
    expect(nameValue).to(beNil())

    guard let nameValue = nameValue as? String? else {
      fail("name should be Optional.some(Optional.none).")
      return
    }
    expect(nameValue).to(beNil())
  }

}
