import XCTest
import Nimble
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

class MutatingSelectionSetTests: XCTestCase {

  func test__selectionSet_dataDict_hasValueSemantics() {
    // given
    struct GivenSelectionSet: MockMutableRootSelectionSet {
      public var __data: DataDict = .empty()
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __selections: [Selection] { [
        .field("hero", Hero.self)
      ]}

      var hero: Hero {
        get { __data["hero"] }
        set { __data["hero"] = newValue }
      }

      init(
        __typename: String,
        hero: Hero
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": __typename,
            "hero": hero._fieldData,
          ], fulfilledFragments: [
            ObjectIdentifier(Self.self),
          ]))
      }

      struct Hero: MockMutableRootSelectionSet {
        public var __data: DataDict = .empty()
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __selections: [Selection] { [
          .field("name", String?.self)
        ]}

        var name: String? {
          get { __data["name"] }
          set { __data["name"] = newValue }
        }

        init(
          __typename: String,
          name: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": __typename,
              "name": name,
            ], fulfilledFragments: [
              ObjectIdentifier(Self.self),
            ]))
        }
      }
    }

    // when
    let data = GivenSelectionSet(
      __typename: "Query",
      hero: .init(
        __typename: "Hero",
        name: "Luke"
      )
    )

    let hero = data.hero
    var hero2 = hero

    hero2.name = "Leia"

    var data2 = data
    data2.hero = hero2

    // then
    expect(data.hero.name).to(equal("Luke"))
    expect(hero.name).to(equal("Luke"))
    expect(hero2.name).to(equal("Leia"))
    expect(data2.hero.name).to(equal("Leia"))
  }

}
