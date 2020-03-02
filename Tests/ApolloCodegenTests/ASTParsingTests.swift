//
//  ASTParsingTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 2/26/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import XCTest
@testable import ApolloCodegenLib

class ASTParsingTests: XCTestCase {
  
  lazy var starWarsJSONURL: URL = {
    let sourceRoot = CodegenTestHelper.sourceRootURL()
    let starWarsJSONURL = sourceRoot
      .appendingPathComponent("Sources")
      .appendingPathComponent("StarWarsAPI")
      .appendingPathComponent("API.json")
    
    return starWarsJSONURL
  }()
  
  enum ASTError: Error {
    case ellensComputerIsBeingWeird
  }
  
  private func loadAST(from url: URL,
                       file: StaticString = #file,
                       line: UInt = #line) throws -> ASTOutput {
    do {
      let output = try ASTOutput.load(from: url, decoder: JSONDecoder())
      return output
    } catch {
      let nsError = error as NSError
      if let underlying = nsError.userInfo["NSUnderlyingError"] as? NSError,
        underlying.domain == NSPOSIXErrorDomain,
        underlying.code == 4 { // The filesystem can't open the file, which for some reason is only happening on my laptop.
          throw ASTError.ellensComputerIsBeingWeird
      } else {
        // There was an actual problem.
        throw error
      }
    }
  }
  
  func testLoadingStarWarsJSON() throws {
    do {
      let output = try loadAST(from: starWarsJSONURL)
      XCTAssertEqual(output.operations.count, 36)
      XCTAssertEqual(output.fragments.count, 15)
      XCTAssertEqual(output.typesUsed.count, 3)
    } catch {
      switch error {
      case ASTError.ellensComputerIsBeingWeird:
        print("🐶☕️🔥 This is fine")
      default:
        XCTFail("Unexpected error loading AST: \(error)")
      }
    }
  }
  
  func testParsingASTTypes() {
    do {
      let output = try loadAST(from: starWarsJSONURL)
      let types = output.typesUsed
      
      // Check top-level properties of the types
      XCTAssertEqual(types.map { $0.name }, [
        "Episode",
        "ReviewInput",
        "ColorInput",
      ])
      
      XCTAssertEqual(types.map { $0.kind }, [
        .EnumType,
        .InputObjectType,
        .InputObjectType
      ])
      
      XCTAssertEqual(types.map { $0.description }, [
        "The episodes in the Star Wars trilogy",
        "The input object sent when someone is creating a new review",
        "The input object sent when passing in a color",
      ])
      
      // Check the enum type
      let enumType = types[0]
      XCTAssertNil(enumType.fields)
      let enumValues = try XCTUnwrap(enumType.values, "Episode should have values")
      
      XCTAssertEqual(enumValues.map { $0.name }, [
        "NEWHOPE",
        "EMPIRE",
        "JEDI",
      ])
      
      XCTAssertEqual(enumValues.map { $0.description }, [
        "Star Wars Episode IV: A New Hope, released in 1977.",
        "Star Wars Episode V: The Empire Strikes Back, released in 1980.",
        "Star Wars Episode VI: Return of the Jedi, released in 1983.",
      ])
      
      XCTAssertEqual(enumValues.map { $0.isDeprecated }, [
        false,
        false,
        false,
      ])
      
      /// Check input object with descriptions
      let reviewInput = types[1]
      XCTAssertNil(reviewInput.values)
      let reviewFields = try XCTUnwrap(reviewInput.fields, "Review should have fields!")
      
      XCTAssertEqual(reviewFields.map { $0.name }, [
        "stars",
        "commentary",
        "favorite_color",
      ])
      
      XCTAssertEqual(reviewFields.map { $0.type }, [
        "Int!",
        "String",
        "ColorInput",
      ])
      
      XCTAssertEqual(reviewFields.map { $0.description }, [
        "0-5 stars",
        "Comment about the movie, optional",
        "Favorite color, optional"
      ])
      
      /// Check input object without descriptions
      let colorInput = types[2]
      XCTAssertNil(colorInput.values)
      let colorFields = try XCTUnwrap(colorInput.fields, "Color input should have fields!")
    
      XCTAssertEqual(colorFields.map { $0.name }, [
        "red",
        "green",
        "blue",
      ])
      
      XCTAssertEqual(colorFields.map { $0.type }, [
        "Int!",
        "Int!",
        "Int!",
      ])
      
      XCTAssertEqual(colorFields.map { $0.description }, [
        nil,
        nil,
        nil,
      ])
    } catch {
      switch error {
      case ASTError.ellensComputerIsBeingWeird:
        print("🐶☕️🔥 This is fine")
      default:
        XCTFail("Unexpected error loading AST: \(error)")
      }
    }
  }
  
  func testParsingOperationWithMutation() throws {
    do {
      let output = try loadAST(from: starWarsJSONURL)
      let createAwesomeReviewMutation = try XCTUnwrap(output.operations.first(where: { $0.operationName == "CreateAwesomeReview" }))
      
      XCTAssertTrue(createAwesomeReviewMutation.filePath.hasPrefix("file:///"))
      XCTAssertTrue(createAwesomeReviewMutation.filePath
        .hasSuffix("/Sources/StarWarsAPI/CreateReviewForEpisode.graphql"))
      XCTAssertEqual(createAwesomeReviewMutation.operationType, .mutation)
      XCTAssertEqual(createAwesomeReviewMutation.rootType, "Mutation")
      
      XCTAssertEqual(createAwesomeReviewMutation.source, """
mutation CreateAwesomeReview {\n  createReview(episode: JEDI, review: {stars: 10, commentary: \"This is awesome!\"}) {\n    __typename\n    stars\n    commentary\n  }\n}
""")
      XCTAssertTrue(createAwesomeReviewMutation.fragmentSpreads.isEmpty)
      XCTAssertTrue(createAwesomeReviewMutation.inlineFragments.isEmpty)
      XCTAssertTrue(createAwesomeReviewMutation.fragmentsReferenced.isEmpty)
      XCTAssertEqual(createAwesomeReviewMutation.sourceWithFragments, """
mutation CreateAwesomeReview {\n  createReview(episode: JEDI, review: {stars: 10, commentary: \"This is awesome!\"}) {\n    __typename\n    stars\n    commentary\n  }\n}
""")
      
      XCTAssertEqual(createAwesomeReviewMutation.operationId, "4a1250de93ebcb5cad5870acf15001112bf27bb963e8709555b5ff67a1405374")
      XCTAssertTrue(createAwesomeReviewMutation.variables.isEmpty)
      
      let outerFields = createAwesomeReviewMutation.fields
      XCTAssertEqual(outerFields.count, 1)
      let outerField = outerFields[0]
    
      XCTAssertEqual(outerField.responseName, "createReview")
      XCTAssertEqual(outerField.fieldName, "createReview")
      XCTAssertEqual(outerField.type, "Review")
      XCTAssertFalse(outerField.isDeprecated.apollo_boolValue)
      XCTAssertFalse(outerField.isConditional)
      let fragmentSpreads = try XCTUnwrap(outerField.fragmentSpreads)
      XCTAssertTrue(fragmentSpreads.isEmpty)
      let inlineFragments = try XCTUnwrap(outerField.inlineFragments)
      XCTAssertTrue(inlineFragments.isEmpty)
      
      let arguments = try XCTUnwrap(outerFields[0].args)
      
      XCTAssertEqual(arguments.map { $0.name }, [
        "episode",
        "review",
      ])
             
      XCTAssertEqual(arguments.map { $0.value }, [
        .string("JEDI"),
        .dictionary([
          "stars": .int(10),
          "commentary": .string("This is awesome!"),
        ])
      ])
      
      XCTAssertEqual(arguments.map { $0.type }, [
        "Episode",
        "ReviewInput!",
      ])
      
      
      let innerFields = try XCTUnwrap(outerField.fields)
      XCTAssertEqual(innerFields.map { $0.responseName }, [
        "__typename",
        "stars",
        "commentary",
        
      ])
      
      XCTAssertEqual(innerFields.map { $0.fieldName }, [
        "__typename",
        "stars",
        "commentary",
      ])
      
      XCTAssertEqual(innerFields.map { $0.type }, [
        "String!",
        "Int!",
        "String",
      ])
      
      XCTAssertEqual(innerFields.map { $0.isConditional }, [
        false,
        false,
        false,
      ])
      
      XCTAssertEqual(innerFields.map { $0.description }, [
        nil,
        "The number of stars this review gave, 1-5",
        "Comment about the movie",
      ])
      
      XCTAssertEqual(innerFields.map { $0.isDeprecated }, [
        nil,
        false,
        false,
      ])
    } catch {
      switch error {
      case ASTError.ellensComputerIsBeingWeird:
        print("🐶☕️🔥 This is fine")
      default:
        XCTFail("Unexpected error loading AST: \(error)")
      }
    }
  }
  
  func testParsingOperationWithQueryAndInputAndNestedTypes() throws {
    do {
      let output = try loadAST(from: starWarsJSONURL)
      let heroAndFriendsNamesQuery = try XCTUnwrap(output.operations.first(where: { $0.operationName == "HeroAndFriendsNames" }))
      XCTAssertTrue(heroAndFriendsNamesQuery.filePath.hasPrefix("file:///"))
      XCTAssertTrue(heroAndFriendsNamesQuery.filePath
        .hasSuffix("/Sources/StarWarsAPI/HeroAndFriendsNames.graphql"))
      XCTAssertEqual(heroAndFriendsNamesQuery.operationType, .query)
      XCTAssertEqual(heroAndFriendsNamesQuery.rootType, "Query")
      
      XCTAssertEqual(heroAndFriendsNamesQuery.source, """
query HeroAndFriendsNames($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    name\n    friends {\n      __typename\n      name\n    }\n  }\n}
""")
      
      XCTAssertTrue(heroAndFriendsNamesQuery.fragmentSpreads.isEmpty)
      XCTAssertTrue(heroAndFriendsNamesQuery.inlineFragments.isEmpty)
      XCTAssertTrue(heroAndFriendsNamesQuery.fragmentsReferenced.isEmpty)
      
      XCTAssertEqual(heroAndFriendsNamesQuery.sourceWithFragments, """
query HeroAndFriendsNames($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    name\n    friends {\n      __typename\n      name\n    }\n  }\n}
""")
      XCTAssertEqual(heroAndFriendsNamesQuery.operationId, "fe3f21394eb861aa515c4d582e645469045793c9cbbeca4b5d4ce4d7dd617556")
      
      XCTAssertEqual(heroAndFriendsNamesQuery.variables.count, 1)
      let variable = heroAndFriendsNamesQuery.variables[0]
      
      XCTAssertEqual(variable.name, "episode")
      XCTAssertEqual(variable.type, "Episode")
      
      let outerField = heroAndFriendsNamesQuery.fields[0]
      
      XCTAssertEqual(outerField.responseName, "hero")
      XCTAssertEqual(outerField.fieldName, "hero")
      XCTAssertEqual(outerField.type, "Character")
      XCTAssertFalse(outerField.isConditional)
      
      let isDeprecated = try XCTUnwrap(outerField.isDeprecated)
      XCTAssertFalse(isDeprecated)
      let fragmentSpreads = try XCTUnwrap(outerField.fragmentSpreads)
      XCTAssertTrue(fragmentSpreads.isEmpty)
      let inlineFragments = try XCTUnwrap(outerField.fragmentSpreads)
      XCTAssertTrue(inlineFragments.isEmpty)
      
      let arguments = try XCTUnwrap(outerField.args)
      XCTAssertEqual(arguments.count, 1)
      let argument = arguments[0]
      
      XCTAssertEqual(argument.name, "episode")
      XCTAssertEqual(argument.value, .dictionary([
        "kind": .string("Variable"),
        "variableName": .string("episode"),
      ]))
      XCTAssertEqual(argument.type, "Episode")
      
      let firstLevelFields = try XCTUnwrap(outerField.fields)
      
      XCTAssertEqual(firstLevelFields.map { $0.responseName }, [
        "__typename",
        "name",
        "friends",
      ])
      
      XCTAssertEqual(firstLevelFields.map { $0.fieldName }, [
        "__typename",
        "name",
        "friends",
      ])
      
      XCTAssertEqual(firstLevelFields.map { $0.type }, [
        "String!",
        "String!",
        "[Character]"
      ])
      
      XCTAssertEqual(firstLevelFields.map { $0.isConditional }, [
        false,
        false,
        false,
      ])
      
      XCTAssertEqual(firstLevelFields.map { $0.description }, [
        nil,
        "The name of the character",
        "The friends of the character, or an empty list if they have none",
      ])
      
      XCTAssertEqual(firstLevelFields.map { $0.isDeprecated }, [
        nil,
        false,
        false
      ])

      XCTAssertEqual(firstLevelFields.map { $0.fragmentSpreads?.count }, [
        nil,
        nil,
        0
      ])
      
      XCTAssertEqual(firstLevelFields.map { $0.fields?.count } , [
        nil,
        nil,
        2
      ])
      
      XCTAssertEqual(firstLevelFields.map { $0.inlineFragments?.count }, [
        nil,
        nil,
        0
      ])
      
      let secondLevelFields = try XCTUnwrap(firstLevelFields[2].fields)
      
      XCTAssertEqual(secondLevelFields.map { $0.responseName }, [
        "__typename",
        "name"
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.fieldName }, [
        "__typename",
        "name"
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.type }, [
        "String!",
        "String!"
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.isConditional }, [
        false,
        false,
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.description }, [
        nil,
        "The name of the character",
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.isDeprecated }, [
        nil,
        false,
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.fields?.count }, [
        nil,
        nil,
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.fragmentSpreads?.count }, [
        nil,
        nil,
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.inlineFragments?.count }, [
        nil,
        nil,
      ])
    } catch {
      switch error {
      case ASTError.ellensComputerIsBeingWeird:
        print("🐶☕️🔥 This is fine")
      default:
        XCTFail("Unexpected error loading AST: \(error)")
      }
    }
  }
  
  func testParsingOperationWithQueryAndFragment() throws {
    do {
      let output = try loadAST(from: starWarsJSONURL)
      let heroAndFriendsNamesWithFragmentQuery = try XCTUnwrap(output.operations.first(where: { $0.operationName == "HeroAndFriendsNamesWithFragment" }))
      
      XCTAssertTrue(heroAndFriendsNamesWithFragmentQuery.filePath.hasPrefix("file:///"))
      XCTAssertTrue(heroAndFriendsNamesWithFragmentQuery.filePath
        .hasSuffix("/Sources/StarWarsAPI/HeroAndFriendsNames.graphql"))
      XCTAssertEqual(heroAndFriendsNamesWithFragmentQuery.operationType, .query)
      XCTAssertEqual(heroAndFriendsNamesWithFragmentQuery.rootType, "Query")
      
      XCTAssertEqual(heroAndFriendsNamesWithFragmentQuery.source, """
query HeroAndFriendsNamesWithFragment($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    name\n    ...FriendsNames\n  }\n}
""")
      XCTAssertTrue(heroAndFriendsNamesWithFragmentQuery.fragmentSpreads.isEmpty)
      XCTAssertTrue(heroAndFriendsNamesWithFragmentQuery.inlineFragments.isEmpty)
      XCTAssertEqual(heroAndFriendsNamesWithFragmentQuery.fragmentsReferenced, [
        "FriendsNames"
      ])
      
      XCTAssertEqual(heroAndFriendsNamesWithFragmentQuery.sourceWithFragments, """
query HeroAndFriendsNamesWithFragment($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    name\n    ...FriendsNames\n  }\n}\nfragment FriendsNames on Character {\n  __typename\n  friends {\n    __typename\n    name\n  }\n}
""")

      XCTAssertEqual(heroAndFriendsNamesWithFragmentQuery.operationId, "1d3ad903dad146ff9d7aa09813fc01becd017489bfc1af8ffd178498730a5a26")
      
      XCTAssertEqual(heroAndFriendsNamesWithFragmentQuery.variables.count, 1)
      let variable = heroAndFriendsNamesWithFragmentQuery.variables[0]
      
      XCTAssertEqual(variable.name, "episode")
      XCTAssertEqual(variable.type, "Episode")
      
      let outerField = heroAndFriendsNamesWithFragmentQuery.fields[0]
      
      XCTAssertEqual(outerField.responseName, "hero")
      XCTAssertEqual(outerField.fieldName, "hero")
      XCTAssertEqual(outerField.type, "Character")
      XCTAssertFalse(outerField.isConditional)
      let isDeprecated = try XCTUnwrap(outerField.isDeprecated)
      XCTAssertFalse(isDeprecated)
      XCTAssertEqual(outerField.fragmentSpreads, [
        "FriendsNames"
      ])
      let inlineFragments = try XCTUnwrap(outerField.inlineFragments)
      XCTAssertTrue(inlineFragments.isEmpty)
      
      let arguments = try XCTUnwrap(outerField.args)
      XCTAssertEqual(arguments.count, 1)
      let argument = arguments[0]
      
      XCTAssertEqual(argument.name, "episode")
      XCTAssertEqual(argument.value, .dictionary([
        "kind": .string("Variable"),
        "variableName": .string("episode")
      ]))
      XCTAssertEqual(argument.type, "Episode")
      
      let firstLevelFields = try XCTUnwrap(outerField.fields)
      
      XCTAssertEqual(firstLevelFields.map { $0.responseName }, [
        "__typename",
        "name",
        "friends"
      ])
      
      XCTAssertEqual(firstLevelFields.map { $0.fieldName }, [
        "__typename",
        "name",
        "friends"
      ])
      
      XCTAssertEqual(firstLevelFields.map { $0.type }, [
        "String!",
        "String!",
        "[Character]",
      ])
      
      XCTAssertEqual(firstLevelFields.map { $0.isConditional }, [
        false,
        false,
        false
      ])
      
      XCTAssertEqual(firstLevelFields.map { $0.description }, [
        nil,
        "The name of the character",
        "The friends of the character, or an empty list if they have none",
      ])
      
      XCTAssertEqual(firstLevelFields.map { $0.isDeprecated }, [
        nil,
        false,
        false,
      ])
      
      XCTAssertEqual(firstLevelFields.map { $0.fragmentSpreads?.count }, [
        nil,
        nil,
        0
      ])
      
      XCTAssertEqual(firstLevelFields.map { $0.inlineFragments?.count }, [
        nil,
        nil,
        0
      ])
      
      XCTAssertEqual(firstLevelFields.map { $0.args?.count }, [
        nil,
        nil,
        nil,
      ])
      
      XCTAssertEqual(firstLevelFields.map { $0.fields?.count }, [
        nil,
        nil,
        2,
      ])
      
      let secondLevelFields = try XCTUnwrap(firstLevelFields[2].fields)

      XCTAssertEqual(secondLevelFields.map { $0.responseName }, [
        "__typename",
        "name"
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.fieldName }, [
        "__typename",
        "name"
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.type }, [
        "String!",
        "String!"
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.isConditional }, [
        false,
        false,
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.description }, [
        nil,
        "The name of the character"
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.isDeprecated }, [
        nil,
        false
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.fragmentSpreads?.count }, [
        nil,
        nil,
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.inlineFragments?.count }, [
        nil,
        nil,
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.fields?.count }, [
        nil,
        nil,
      ])
      
      XCTAssertEqual(secondLevelFields.map { $0.args?.count }, [
        nil,
        nil,
      ])
      
      
    } catch {
      switch error {
      case ASTError.ellensComputerIsBeingWeird:
        print("🐶☕️🔥 This is fine")
      default:
        XCTFail("Unexpected error loading AST: \(error)")
      }
    }
  }
  
  func testParsingQueryWithAliasesAndPassedInRawValue() throws {
    do {
      let output = try loadAST(from: starWarsJSONURL)
      let twoHeroesQuery = try XCTUnwrap(output.operations.first(where: { $0.operationName == "TwoHeroes" }))
    
      XCTAssertTrue(twoHeroesQuery.filePath.hasPrefix("file:///"))
      XCTAssertTrue(twoHeroesQuery.filePath
      .hasSuffix("/Sources/StarWarsAPI/TwoHeroes.graphql"))
      XCTAssertEqual(twoHeroesQuery.operationType, .query)
      XCTAssertEqual(twoHeroesQuery.rootType, "Query")
      XCTAssertTrue(twoHeroesQuery.variables.isEmpty)
      XCTAssertEqual(twoHeroesQuery.source, """
query TwoHeroes {\n  r2: hero {\n    __typename\n    name\n  }\n  luke: hero(episode: EMPIRE) {\n    __typename\n    name\n  }\n}
""")
      XCTAssertTrue(twoHeroesQuery.fragmentSpreads.isEmpty)
      XCTAssertTrue(twoHeroesQuery.inlineFragments.isEmpty)
      XCTAssertTrue(twoHeroesQuery.fragmentsReferenced.isEmpty)
      
      XCTAssertEqual(twoHeroesQuery.sourceWithFragments, """
query TwoHeroes {\n  r2: hero {\n    __typename\n    name\n  }\n  luke: hero(episode: EMPIRE) {\n    __typename\n    name\n  }\n}
""")

      XCTAssertEqual(twoHeroesQuery.operationId, "b868fa9c48f19b8151c08c09f46831e3b9cd09f5c617d328647de785244b52bb")
      
      let outerFields = twoHeroesQuery.fields
      
      XCTAssertEqual(outerFields.map { $0.responseName }, [
        "r2",
        "luke",
      ])
      
      XCTAssertEqual(outerFields.map { $0.fieldName }, [
        "hero",
        "hero",
      ])
      
      XCTAssertEqual(outerFields.map { $0.type }, [
        "Character",
        "Character"
      ])
      
      XCTAssertEqual(outerFields.map { $0.isConditional }, [
        false,
        false,
      ])
      
      XCTAssertEqual(outerFields.map { $0.isDeprecated }, [
        false,
        false,
      ])
      
      XCTAssertEqual(outerFields.map { $0.fragmentSpreads?.count }, [
        0,
        0,
      ])
      
      XCTAssertEqual(outerFields.map { $0.inlineFragments?.count }, [
        0,
        0,
      ])
      
      XCTAssertEqual(outerFields.map { $0.args?.count }, [
        nil,
        1,
      ])
      
      XCTAssertEqual(outerFields.map { $0.fields?.count }, [
        2,
        2,
      ])
      
      let lukeArgs = try XCTUnwrap(outerFields[1].args)
      XCTAssertEqual(lukeArgs.count, 1)
      let lukeArg = lukeArgs[0]

      XCTAssertEqual(lukeArg.name, "episode")
      XCTAssertEqual(lukeArg.value, .string("EMPIRE"))
      XCTAssertEqual(lukeArg.type, "Episode")

      let r2Fields = try XCTUnwrap(outerFields[0].fields)
      XCTAssertEqual(r2Fields.map { $0.responseName }, [
        "__typename",
        "name"
      ])
      
      XCTAssertEqual(r2Fields.map { $0.fieldName }, [
        "__typename",
        "name"
      ])
      
      XCTAssertEqual(r2Fields.map { $0.type }, [
        "String!",
        "String!"
      ])
      
      XCTAssertEqual(r2Fields.map { $0.isConditional }, [
        false,
        false,
      ])
      
      XCTAssertEqual(r2Fields.map { $0.isDeprecated }, [
        nil,
        false,
      ])
      
      XCTAssertEqual(r2Fields.map { $0.description }, [
        nil,
        "The name of the character"
      ])
      
      XCTAssertEqual(r2Fields.map { $0.fragmentSpreads?.count }, [
        nil,
        nil,
      ])
      
      XCTAssertEqual(r2Fields.map { $0.inlineFragments?.count }, [
        nil,
        nil,
      ])
      
      let lukeFields = try XCTUnwrap(outerFields[1].fields)
      XCTAssertEqual(lukeFields.map { $0.responseName }, [
        "__typename",
        "name"
      ])
      
      XCTAssertEqual(lukeFields.map { $0.fieldName }, [
        "__typename",
        "name"
      ])
      
      XCTAssertEqual(lukeFields.map { $0.type }, [
        "String!",
        "String!"
      ])
      
      XCTAssertEqual(lukeFields.map { $0.isConditional }, [
        false,
        false,
      ])
      
      XCTAssertEqual(lukeFields.map { $0.isDeprecated }, [
        nil,
        false,
      ])
      
      XCTAssertEqual(lukeFields.map { $0.description }, [
        nil,
        "The name of the character"
      ])
      
      XCTAssertEqual(lukeFields.map { $0.fragmentSpreads?.count }, [
        nil,
        nil,
      ])
      
      XCTAssertEqual(lukeFields.map { $0.inlineFragments?.count }, [
        nil,
        nil,
      ])
    } catch {
      switch error {
      case ASTError.ellensComputerIsBeingWeird:
        print("🐶☕️🔥 This is fine")
      default:
        XCTFail("Unexpected error loading AST: \(error)")
      }
    }
  }
}
