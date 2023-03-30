import XCTest
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers
import Nimble

class SelectionSet_JSONInitializerTests: XCTestCase {

  func test__initFromJSON__withFragment_canAccessFragment() throws {
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

    class GivenFragment: MockFragment {
      override class var __parentType: ParentType { Types.Human }
      override class var __selections: [Selection] {[
        .field("height", Float.self)
      ]}
      var height: Float { __data["height"] }
    }

    class Hero: AbstractMockSelectionSet<Hero.Fragments, MockSchemaMetadata> {
      typealias Schema = MockSchemaMetadata

      override class var __parentType: ParentType { Types.Human }
      override class var __selections: [Selection] {[
        .field("__typename", String.self),
        .field("name", String?.self),
        .fragment(GivenFragment.self)
      ]}

      var name: String? { __data["name"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var givenFragment: GivenFragment { _toFragment() }
      }
    }

    let jsonObject: JSONObject = [
      "__typename": "Human", "name": "Luke Skywalker", "height": 1.72
    ]

    let data = try Hero(data: jsonObject)


    expect(data.fragments.givenFragment.height).to(equal(1.72))
  }

  func test__initFromJSON__withInclusionConditionOnField_canAccessFieldWhenVariableIsTrue() throws {
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
        .field("__typename", String.self),
        .include(if: "includeName", .field("name", String.self)),
      ]}

      var name: String? { __data["name"] }
    }

    let jsonObject: JSONObject = [
      "__typename": "Hero", "name": "R2-D2"
    ]

    let data = try Hero(data: jsonObject, variables: ["includeName" : true])
    expect(data.name).to(equal("R2-D2"))

    let dataWithNoName = try Hero(data: jsonObject, variables: ["includeName" : false])
    expect(dataWithNoName.name).to(beNil())
  }

  func test__initFromJSON__withInclusionConditionOnField_variableNotPresent_fieldIsNil() throws {
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
        .field("__typename", String.self),
        .include(if: "includeName", .field("name", String.self)),
      ]}

      var name: String? { __data["name"] }
    }

    let jsonObject: JSONObject = [
      "__typename": "Hero", "name": "R2-D2"
    ]

    let dataWithNoName = try Hero(data: jsonObject)
    expect(dataWithNoName.name).to(beNil())
  }

  // MARK: - Merged Only Selection Set Tests

  /// Confirms bug fix for issue [#2915](https://github.com/apollographql/apollo-ios/issues/2915).
  func test__initFromJSON__givenMergedOnlyNestedSelectionSet_withTypeCase_canConvertToTypeCase() throws {
    struct Types {
      static let Character = Interface(name: "Character")
      static let Hero = Interface(name: "Hero")
      static let Human = Object(typename: "Human", implementedInterfaces: [Character.self, Hero.self])
    }

    MockSchemaMetadata.stub_objectTypeForTypeName = {
      switch $0 {
      case "Human": return Types.Human
      default: XCTFail(); return nil
      }
    }

    class Character: MockSelectionSet {
      typealias Schema = MockSchemaMetadata

      override class var __parentType: ParentType { Types.Character }
      override class var __selections: [Selection] {[
        .field("__typename", String.self),
        .field("friend", Friend.self),
        .inlineFragment(AsHero.self),
        .inlineFragment(AsHuman.self),
      ]}

      var friend: Friend { __data["friend"] }
      var asHero: AsHero? { _asInlineFragment() }
      var asHuman: AsHuman? { _asInlineFragment() }

      class Friend: MockSelectionSet {
        typealias Schema = MockSchemaMetadata

        override class var __parentType: ParentType { Types.Character }
        override class var __selections: [Selection] {[
          .field("__typename", String.self),
          .inlineFragment(AsHuman.self),
        ]}

        var asHuman: AsHuman? { _asInlineFragment() }

        class AsHuman: ConcreteMockTypeCase<Character.Friend> {
          typealias Schema = MockSchemaMetadata

          override class var __parentType: ParentType { Types.Human }
          override class var __selections: [Selection] {[
            .field("name", String.self),
          ]}

          var name: String? { __data["name"] }
        }
      }

      class AsHero: ConcreteMockTypeCase<Character> {
        typealias Schema = MockSchemaMetadata

        override class var __parentType: ParentType { Types.Hero }
        override class var __selections: [Selection] {[
          .field("friend", Friend.self),
        ]}

        var friend: Friend { __data["friend"] }

        class Friend: MockSelectionSet {
          typealias Schema = MockSchemaMetadata

          override class var __parentType: ParentType { Types.Character }
          override class var __selections: [Selection] {[
            .field("heroName", String.self),
          ]}

          var heroName: String? { __data["heroName"] }
        }
      }

      class AsHuman: MockTypeCase {
        typealias Schema = MockSchemaMetadata

        override class var __parentType: ParentType { Types.Human }
        override class var __selections: [Selection] {[
          .field("name", String.self),
        ]}

        var name: String? { __data["name"] }
        var friend: Friend { __data["friend"] }

        class Friend: MockSelectionSet {
          typealias Schema = MockSchemaMetadata

          override class var __parentType: ParentType { Types.Character }

          var heroName: String? { __data["heroName"] }
          var asHuman: AsHuman? { _asInlineFragment() }

          class AsHuman: ConcreteMockTypeCase<Character.AsHuman.Friend> {
            typealias Schema = MockSchemaMetadata

            override class var __parentType: ParentType { Types.Human }

            var name: String? { __data["name"] }
            var heroName: String? { __data["heroName"] }
          }
        }
      }
    }

    let jsonObject: JSONObject = [
      "__typename": "Human", "name": "Anikan", "friend": [
        "__typename": "Human",
        "name": "Han",
        "heroName": "Han Solo"
      ]
    ]

    let data = try Character(data: jsonObject)
    expect(data.asHuman?.friend.asHuman).toNot(beNil())
    expect(data.asHuman?.friend.asHuman?.heroName).to(equal("Han Solo"))
  }
}
