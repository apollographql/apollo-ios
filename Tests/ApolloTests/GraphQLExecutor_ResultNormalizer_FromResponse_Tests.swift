import XCTest
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

class GraphQLExecutor_ResultNormalizer_FromResponse_Tests: XCTestCase {

  // MARK: - Helpers

  private static let executor: GraphQLExecutor = {
    let executor = GraphQLExecutor(executionSource: NetworkResponseExecutionSource())
    executor.shouldComputeCachePath = true
    return executor
  }()

  private func normalizeRecords<S: RootSelectionSet>(
    _ selectionSet: S.Type,
    with variables: GraphQLOperation.Variables? = nil,
    from object: JSONObject
  ) throws -> RecordSet {
    return try GraphQLExecutor_ResultNormalizer_FromResponse_Tests.executor.execute(
      selectionSet: selectionSet,
      on: object,
      withRootCacheReference: CacheReference.RootQuery,
      variables: variables,
      accumulator: ResultNormalizerFactory.networkResponseDataNormalizer()
    )
  }

  // MARK: - Tests

  func test__execute__givenObjectWithNoCacheKey_normalizesRecordToPathFromQueryRoot() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var __selections: [Selection] {[
        .field("hero", Hero.self)
      ]}

      class Hero: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("name", String.self)
        ]}
      }
    }

    let object: JSONObject = [
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ]

    // when
    let records = try normalizeRecords(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(records["QUERY_ROOT"]?["hero"] as? CacheReference,
                   CacheReference("QUERY_ROOT.hero"))
    
    let hero = try XCTUnwrap(records["QUERY_ROOT.hero"])
    XCTAssertEqual(hero["name"] as? String, "R2-D2")
  }
  
  func test__execute__givenObjectWithNoCacheKey_forFieldWithStringArgument_normalizesRecordToPathFromQueryRootIncludingArgument() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var __selections: [Selection] {[
        .field("hero", Hero.self, arguments: ["episode": .variable("episode")])
      ]}

      class Hero: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("name", String.self)
        ]}
      }
    }
    
    let variables = ["episode": "JEDI"]

    let object: JSONObject = [
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ]

    // when
    let records = try normalizeRecords(GivenSelectionSet.self, with: variables, from: object)

    // then
    XCTAssertEqual(records["QUERY_ROOT"]?["hero(episode:JEDI)"] as? CacheReference,
                   CacheReference("QUERY_ROOT.hero(episode:JEDI)"))
    
    let hero = try XCTUnwrap(records["QUERY_ROOT.hero(episode:JEDI)"])
    XCTAssertEqual(hero["name"] as? String, "R2-D2")
  }

  func test__execute__givenObjectWithNoCacheKey_forFieldWithEnumArgument_normalizesRecordToPathFromQueryRootIncludingArgument() throws {
    // given
    enum MockEnum: String, EnumType {
      case NEWHOPE
      case EMPIRE
      case JEDI
    }

    class GivenSelectionSet: MockSelectionSet {
      override class var __selections: [Selection] {[
        .field("hero", Hero.self, arguments: ["episode": .variable("episode")])
      ]}

      class Hero: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("name", String.self)
        ]}
      }
    }

    let variables = ["episode": MockEnum.EMPIRE]

    let object: JSONObject = [
      "hero": ["__typename": "Droid", "name": "R2-D2"]
    ]

    // when
    let records = try normalizeRecords(GivenSelectionSet.self, with: variables, from: object)

    // then
    XCTAssertEqual(records["QUERY_ROOT"]?["hero(episode:EMPIRE)"] as? CacheReference,
                   CacheReference("QUERY_ROOT.hero(episode:EMPIRE)"))

    let hero = try XCTUnwrap(records["QUERY_ROOT.hero(episode:EMPIRE)"])
    XCTAssertEqual(hero["name"] as? String, "R2-D2")
  }

  func test__execute__givenObjectWithNoCacheKey_andNestedArrayOfObjectsWithNoCacheKey_normalizesRecordsToPathsFromQueryRoot() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var __selections: [Selection] {[
        .field("hero", Hero.self)
      ]}

      class Hero: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("name", String.self),
          .field("friends", [Friend].self)
        ]}

        class Friend: MockSelectionSet {
          override class var __selections: [Selection] {[
            .field("name", String.self)
          ]}
        }
      }
    }    

    let object: JSONObject = [
      "hero": [
        "__typename": "Droid",
        "name": "R2-D2",
        "friends": [
          ["__typename": "Human", "name": "Luke Skywalker"],
          ["__typename": "Human", "name": "Han Solo"],
          ["__typename": "Human", "name": "Leia Organa"]
        ]
      ]
    ]

    // when
    let records = try normalizeRecords(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(records["QUERY_ROOT"]?["hero"] as? CacheReference,
                   CacheReference("QUERY_ROOT.hero"))
    
    let hero = try XCTUnwrap(records["QUERY_ROOT.hero"])
    XCTAssertEqual(hero["name"] as? String, "R2-D2")
    XCTAssertEqual(hero["friends"] as? [CacheReference],
                   [CacheReference("QUERY_ROOT.hero.friends.0"),
                    CacheReference("QUERY_ROOT.hero.friends.1"),
                    CacheReference("QUERY_ROOT.hero.friends.2")])
    
    let luke = try XCTUnwrap(records["QUERY_ROOT.hero.friends.0"])
    XCTAssertEqual(luke["name"] as? String, "Luke Skywalker")
  }

  func test__execute__givenObjectWithCacheKey_andNestedArrayOfObjectsWithCacheKey_normalizesRecordsToIndividualReferences() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var __selections: [Selection] {[
        .field("hero", Hero.self)
      ]}

      class Hero: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("id", String.self),
          .field("name", String.self),
          .field("friends", [Friend].self)
        ]}

        class Friend: MockSelectionSet {
          override class var __selections: [Selection] {[
            .field("id", String.self),
            .field("name", String.self)
          ]}
        }
      }
    }

    MockSchemaMetadata.stub_cacheKeyInfoForType_Object = IDCacheKeyProvider.resolver

    let object: JSONObject = [
      "hero": [
        "__typename": "Droid",
        "id": "2001",
        "name": "R2-D2",
        "friends": [
          ["__typename": "Human", "id": "1000", "name": "Luke Skywalker"],
          ["__typename": "Human", "id": "1002", "name": "Han Solo"],
          ["__typename": "Human", "id": "1003", "name": "Leia Organa"]
        ]
      ]
    ]

    // when
    let records = try normalizeRecords(GivenSelectionSet.self, from: object)

    // then
    XCTAssertEqual(records["QUERY_ROOT"]?["hero"] as? CacheReference,
                   CacheReference("Droid:2001"))

    let hero = try XCTUnwrap(records["Droid:2001"])
    XCTAssertEqual(hero["name"] as? String, "R2-D2")
    XCTAssertEqual(hero["friends"] as? [CacheReference],
                   [CacheReference("Human:1000"),
                    CacheReference("Human:1002"),
                    CacheReference("Human:1003")])

    let luke = try XCTUnwrap(records["Human:1000"])
    XCTAssertEqual(luke["name"] as? String, "Luke Skywalker")

    let han = try XCTUnwrap(records["Human:1002"])
    XCTAssertEqual(han["name"] as? String, "Han Solo")

    let leia = try XCTUnwrap(records["Human:1003"])
    XCTAssertEqual(leia["name"] as? String, "Leia Organa")
  }
  
  func test__execute__givenFieldForObjectWithNoCacheKey_andAliasedFieldForSameFieldName_normalizesRecordsForBothFieldsIntoOneRecord() throws {
    // given
    class GivenSelectionSet: MockSelectionSet {
      override class var __selections: [Selection] {[
        .field("hero", Hero.self),
        .field("hero", alias: "r2", R2.self)
      ]}

      class Hero: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("__typename", String.self),
          .field("name", String.self)
        ]}
      }

      class R2: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("catchphrase", String.self)
        ]}
      }
    }

    let object: JSONObject = [
        "hero": ["__typename": "Droid", "name": "R2-D2"],
        "r2": ["__typename": "Droid", "catchphrase": "Beeeeeeeeeeeeeep"]
    ]

    // when
    let records = try normalizeRecords(GivenSelectionSet.self, from: object)

    // then
    let hero = try XCTUnwrap(records["QUERY_ROOT.hero"])
    XCTAssertEqual(hero["__typename"] as? String, "Droid")
    XCTAssertEqual(hero["name"] as? String, "R2-D2")
    XCTAssertEqual(hero["catchphrase"] as? String, "Beeeeeeeeeeeeeep")
  }

  func test__execute__givenDifferentAliasedFieldsOnTwoTypeCasesWithSameAlias_givenIsFirstType_hasRecordWithFieldValueUsingNonaliasedFieldName() throws {
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

    class GivenSelectionSet: MockSelectionSet {
      override class var __selections: [Selection] {[
        .field("hero", Hero.self),
      ]}

      class Hero: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("__typename", String.self),
          .inlineFragment(AsHuman.self),
          .inlineFragment(AsDroid.self),
        ]}

        class AsHuman: MockTypeCase {
          override class var __parentType: ParentType { Types.Human }
          override class var __selections: [Selection] {[
            .field("name", alias: "property", String.self)
          ]}
        }

        class AsDroid: MockTypeCase {
          override class var __parentType: ParentType { Types.Droid }
          override class var __selections: [Selection] {[
            .field("primaryFunction", alias: "property", String.self)
          ]}
        }
      }
    }

    let object: JSONObject = [
      "hero": ["__typename": "Human", "property": "Han Solo"]
    ]

    // when
    let records = try normalizeRecords(GivenSelectionSet.self, from: object)

    // then
    let hero = try XCTUnwrap(records["QUERY_ROOT.hero"])
    XCTAssertEqual(hero["name"] as? String, "Han Solo")
    XCTAssertNil(hero["property"])
    XCTAssertNil(hero["primaryFunction"])
  }

  func test__execute__givenDifferentAliasedFieldsOnTwoTypeCasesWithSameAlias_givenIsSecondType_hasRecordWithFieldValueUsingNonaliasedFieldName() throws {
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

    class GivenSelectionSet: MockSelectionSet {
      override class var __selections: [Selection] {[
        .field("hero", Hero.self),
      ]}

      class Hero: MockSelectionSet {
        override class var __selections: [Selection] {[
          .inlineFragment(AsHuman.self),
          .inlineFragment(AsDroid.self),
        ]}

        class AsHuman: MockTypeCase {
          override class var __parentType: ParentType { Types.Human }
          override class var __selections: [Selection] {[
            .field("__typename", String.self),
            .field("name", alias: "property", String.self)
          ]}
        }

        class AsDroid: MockTypeCase {
          override class var __parentType: ParentType { Types.Droid }
          override class var __selections: [Selection] {[
            .field("__typename", String.self),
            .field("primaryFunction", alias: "property", String.self)
          ]}
        }
      }
    }

    let object: JSONObject = [
        "hero": ["__typename": "Droid", "property": "Astromech"]
    ]

    // when
    let records = try normalizeRecords(GivenSelectionSet.self, from: object)

    // then
    let hero = try XCTUnwrap(records["QUERY_ROOT.hero"])
    XCTAssertEqual(hero["primaryFunction"] as? String, "Astromech")
    XCTAssertNil(hero["property"])
    XCTAssertNil(hero["name"])
  }

  func test__execute__givenSameFieldWithDifferentArgumentValueOnSameNestedFieldOnTwoTypeCases_givenIsFirstType_hasRecordForFieldNameWithFirstTypesArgument() throws {
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
    class GivenSelectionSet: MockSelectionSet {
      override class var __selections: [Selection] {[
        .field("hero", Hero.self),
      ]}

      class Hero: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("__typename", String.self),
          .inlineFragment(AsHuman.self),
          .inlineFragment(AsDroid.self),
        ]}

        class AsHuman: MockTypeCase {
          override class var __parentType: ParentType { Types.Human }
          override class var __selections: [Selection] {[
            .field("friend", Friend.self),
          ]}

          class Friend: MockSelectionSet {
            override class var __selections: [Selection] {[
              .field("height", Double.self, arguments: ["unit": "FOOT"])
            ]}
          }
        }

        class AsDroid: MockTypeCase {
          override class var __parentType: ParentType { Types.Droid }
          override class var __selections: [Selection] {[
            .field("friend", Friend.self),
          ]}

          class Friend: MockSelectionSet {
            override class var __selections: [Selection] {[
              .field("height", Double.self, arguments: ["unit": "METER"])
            ]}
          }
        }
      }
    }

    let object: JSONObject = [
      "hero": [
        "name": "Luke Skywalker",
        "__typename": "Human",
        "friend": ["__typename": "Human", "name": "Han Solo", "height": 5.905512],
      ]
    ]

    // when
    let records = try normalizeRecords(GivenSelectionSet.self, from: object)

    // then
    let han = try XCTUnwrap(records["QUERY_ROOT.hero.friend"])
    XCTAssertEqual(han["height(unit:FOOT)"] as? Double, 5.905512)
    XCTAssertNil(han["height(unit:METER)"])
    XCTAssertNil(han["height"])
  }

  func test__execute__givenSameFieldWithDifferentArgumentValueOnSameNestedFieldOnTwoTypeCases_givenIsSecondType_hasRecordForFieldNameWithFirstTypesArgument() throws {
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

    class GivenSelectionSet: MockSelectionSet {
      override class var __selections: [Selection] {[
        .field("hero", Hero.self),
      ]}

      class Hero: MockSelectionSet {
        override class var __selections: [Selection] {[
          .field("__typename", String.self),
          .inlineFragment(AsHuman.self),
          .inlineFragment(AsDroid.self),
        ]}

        class AsHuman: MockTypeCase {
          override class var __parentType: ParentType { Types.Human }
          override class var __selections: [Selection] {[
            .field("friend", Friend.self),
          ]}

          class Friend: MockSelectionSet {
            override class var __selections: [Selection] {[
              .field("height", Double.self, arguments: ["unit": "FOOT"])
            ]}
          }
        }

        class AsDroid: MockTypeCase {
          override class var __parentType: ParentType { Types.Droid }
          override class var __selections: [Selection] {[
            .field("friend", Friend.self),
          ]}

          class Friend: MockSelectionSet {
            override class var __selections: [Selection] {[
              .field("height", Double.self, arguments: ["unit": "METER"])
            ]}
          }
        }
      }
    }

    let object: JSONObject = [
      "hero": [
        "name": "Luke Skywalker",
        "__typename": "Droid",
        "friend": ["__typename": "Human", "name": "Luke Skywalker", "height": 1.72],
      ]
    ]

    // when
    let records = try normalizeRecords(GivenSelectionSet.self, from: object)

    // then
    let luke = try XCTUnwrap(records["QUERY_ROOT.hero.friend"])
    XCTAssertEqual(luke["height(unit:METER)"] as? Double, 1.72)
    XCTAssertNil(luke["height(unit:FOOT)"])
    XCTAssertNil(luke["height"])
  }
}
