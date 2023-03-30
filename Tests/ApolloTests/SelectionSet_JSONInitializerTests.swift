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

}
