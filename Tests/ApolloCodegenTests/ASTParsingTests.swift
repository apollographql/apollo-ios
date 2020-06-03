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

  
  private func loadAST(from url: URL,
                       file: StaticString = #file,
                       line: UInt = #line) throws -> ASTOutput {
    try ASTOutput.load(from: url, decoder: JSONDecoder())
  }
  
  func testLoadingStarWarsJSON() throws {
    do {
      let output = try loadAST(from: starWarsJSONURL)
      XCTAssertEqual(output.operations.count, 36)
      XCTAssertEqual(output.fragments.count, 15)
      XCTAssertEqual(output.typesUsed.count, 3)
      XCTAssertEqual(output.unionTypes.count, 1)
      XCTAssertEqual(output.interfaceTypes.count, 1)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testParsingASTUnionTypes() throws {
    let output: ASTOutput
    do {
      output = try loadAST(from: starWarsJSONURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
      return
    }
    
    let types = output.unionTypes
    XCTAssertEqual(types.count, 1)
    
    let type = try XCTUnwrap(types.first)
    
    XCTAssertEqual(type.name, "SearchResult")
    XCTAssertEqual(type.types, [
      "Human",
      "Droid",
      "Starship"
    ])
  }
  
  func testParsingASTInterfaceTypes() throws {
    let output: ASTOutput
    do {
      output = try loadAST(from: starWarsJSONURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
      return
    }
    
    let types = output.interfaceTypes
    XCTAssertEqual(types.count, 1)
    
    let type = try XCTUnwrap(types.first)
    
    XCTAssertEqual(type.name, "Character")
    XCTAssertEqual(type.types, [
      "Human",
      "Droid",
      "Alien"
    ])
  }
  
  func testParsingASTInputTypes() throws {
    let output: ASTOutput
    do {
      output = try loadAST(from: starWarsJSONURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
      return
    }
    
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
    
    XCTAssertEqual(reviewFields.map { $0.typeNode }, [
      .nonNullNamed("Int"),
      .named("String"),
      .named("ColorInput"),
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
    
    XCTAssertEqual(colorFields.map { $0.typeNode }, [
      .nonNullNamed("Int"),
      .nonNullNamed("Int"),
      .nonNullNamed("Int"),
    ])
    
    XCTAssertEqual(colorFields.map { $0.description }, [
      nil,
      nil,
      nil,
    ])
  }
  
  func testParsingOperationWithMutation() throws {
    let output: ASTOutput
    do {
      output = try loadAST(from: starWarsJSONURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
      return
    }
    
    let createAwesomeReviewMutation = try XCTUnwrap(output.operations.first(where: { $0.operationName == "CreateAwesomeReview" }))
    
    XCTAssertTrue(createAwesomeReviewMutation.filePath.hasPrefix("file:///"))
    XCTAssertTrue(createAwesomeReviewMutation.filePath.hasSuffix("/Sources/StarWarsAPI/CreateReviewForEpisode.graphql"))
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
    
    XCTAssertEqual(createAwesomeReviewMutation.fields.count, 1)
    let outerField = try XCTUnwrap(createAwesomeReviewMutation.fields.first)
    
    XCTAssertEqual(outerField.responseName, "createReview")
    XCTAssertEqual(outerField.fieldName, "createReview")
    XCTAssertEqual(outerField.typeNode, .named("Review"))
    XCTAssertFalse(outerField.isDeprecated.apollo.boolValue)
    XCTAssertFalse(outerField.isConditional)
    let fragmentSpreads = try XCTUnwrap(outerField.fragmentSpreads)
    XCTAssertTrue(fragmentSpreads.isEmpty)
    let inlineFragments = try XCTUnwrap(outerField.inlineFragments)
    XCTAssertTrue(inlineFragments.isEmpty)
    
    let arguments = try XCTUnwrap(outerField.args)
    
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
    
    XCTAssertEqual(arguments.map { $0.typeNode }, [
      .named("Episode"),
      .nonNullNamed("ReviewInput"),
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
    
    XCTAssertEqual(innerFields.map { $0.typeNode }, [
      .nonNullNamed("String"),
      .nonNullNamed("Int"),
      .named("String"),
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
  }
  
  func testParsingOperationWithQueryAndInputAndNestedTypes() throws {
    let output: ASTOutput
    do {
      output = try loadAST(from: starWarsJSONURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
      return
    }
    
    let heroAndFriendsNamesQuery = try XCTUnwrap(output.operations.first(where: { $0.operationName == "HeroAndFriendsNames" }))
    XCTAssertTrue(heroAndFriendsNamesQuery.filePath.hasPrefix("file:///"))
    XCTAssertTrue(heroAndFriendsNamesQuery.filePath.hasSuffix("/Sources/StarWarsAPI/HeroAndFriendsNames.graphql"))
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
    XCTAssertEqual(variable.typeNode, .named("Episode"))
    
    let outerField = heroAndFriendsNamesQuery.fields[0]
    
    XCTAssertEqual(outerField.responseName, "hero")
    XCTAssertEqual(outerField.fieldName, "hero")
    XCTAssertEqual(outerField.typeNode, .named("Character"))
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
    XCTAssertEqual(argument.typeNode, .named("Episode"))
    
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
    
    XCTAssertEqual(firstLevelFields.map { $0.typeNode }, [
      .nonNullNamed("String"),
      .nonNullNamed("String"),
      .list(of: .named("Character")),
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
    
    XCTAssertEqual(secondLevelFields.map { $0.typeNode }, [
      .nonNullNamed("String"),
      .nonNullNamed("String"),
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
  }
  
  func testParsingOperationWithQueryAndFragment() throws {
    let output: ASTOutput
    do {
      output = try loadAST(from: starWarsJSONURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
      return
    }
    
    let heroAndFriendsNamesWithFragmentQuery = try XCTUnwrap(output.operations.first(where: { $0.operationName == "HeroAndFriendsNamesWithFragment" }))
    
    XCTAssertTrue(heroAndFriendsNamesWithFragmentQuery.filePath.hasPrefix("file:///"))
    XCTAssertTrue(heroAndFriendsNamesWithFragmentQuery.filePath.hasSuffix("/Sources/StarWarsAPI/HeroAndFriendsNames.graphql"))
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
    XCTAssertEqual(variable.typeNode, .named("Episode"))
    
    let outerField = heroAndFriendsNamesWithFragmentQuery.fields[0]
    
    XCTAssertEqual(outerField.responseName, "hero")
    XCTAssertEqual(outerField.fieldName, "hero")
    XCTAssertEqual(outerField.typeNode, .named("Character"))
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
    XCTAssertEqual(argument.typeNode, .named("Episode"))
    
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
    
    XCTAssertEqual(firstLevelFields.map { $0.typeNode }, [
      .nonNullNamed("String"),
      .nonNullNamed("String"),
      .list(of: .named("Character")),
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
    
    XCTAssertEqual(secondLevelFields.map { $0.typeNode }, [
      .nonNullNamed("String"),
      .nonNullNamed("String"),
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
  }
  
  func testParsingQueryWithInlineFragments() throws {
    let output: ASTOutput
    do {
      output = try loadAST(from: starWarsJSONURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
      return
    }
  
    let heroDetailsQuery = try XCTUnwrap(output.operations.first(where: { $0.operationName == "HeroDetails" }))
  
    XCTAssertTrue(heroDetailsQuery.filePath.hasPrefix("file:///"))
    XCTAssertTrue(heroDetailsQuery.filePath.hasSuffix("/Sources/StarWarsAPI/HeroDetails.graphql"))
    XCTAssertEqual(heroDetailsQuery.operationType, .query)
    XCTAssertEqual(heroDetailsQuery.rootType, "Query")
    
    XCTAssertEqual(heroDetailsQuery.source, """
query HeroDetails($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    name\n    ... on Human {\n      height\n    }\n    ... on Droid {\n      primaryFunction\n    }\n  }\n}
""")
    
    XCTAssertTrue(heroDetailsQuery.fragmentSpreads.isEmpty)
    XCTAssertTrue(heroDetailsQuery.fragmentsReferenced.isEmpty)
    XCTAssertTrue(heroDetailsQuery.inlineFragments.isEmpty)
    
    XCTAssertEqual(heroDetailsQuery.sourceWithFragments, """
query HeroDetails($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    name\n    ... on Human {\n      height\n    }\n    ... on Droid {\n      primaryFunction\n    }\n  }\n}
""")
    
    XCTAssertEqual(heroDetailsQuery.operationId, "2b67111fd3a1c6b2ac7d1ef7764e5cefa41d3f4218e1d60cb67c22feafbd43ec")
    
    XCTAssertEqual(heroDetailsQuery.variables.count, 1)
    let variable = try XCTUnwrap(heroDetailsQuery.variables.first)
    XCTAssertEqual(variable.name, "episode")
    XCTAssertEqual(variable.typeNode, .named("Episode"))
    
    XCTAssertEqual(heroDetailsQuery.fields.count, 1)
    let outerField = try XCTUnwrap(heroDetailsQuery.fields.first)
    
    XCTAssertEqual(outerField.responseName, "hero")
    XCTAssertEqual(outerField.fieldName, "hero")
    XCTAssertEqual(outerField.typeNode, .named("Character"))
    XCTAssertFalse(outerField.isConditional)
    
    let isDeprecated = try XCTUnwrap(outerField.isDeprecated)
    XCTAssertFalse(isDeprecated)
    let fragmentSpreads = try XCTUnwrap(outerField.fragmentSpreads)
    XCTAssertTrue(fragmentSpreads.isEmpty)
    
    let innerFields = try XCTUnwrap(outerField.fields)
    XCTAssertEqual(innerFields.map { $0.responseName }, [
      "__typename",
      "name"
    ])
    
    XCTAssertEqual(innerFields.map { $0.fieldName }, [
      "__typename",
      "name"
    ])
    
    XCTAssertEqual(innerFields.map { $0.typeNode }, [
      .nonNullNamed("String"),
      .nonNullNamed("String"),
    ])
    
    XCTAssertEqual(innerFields.map { $0.isConditional }, [
      false,
      false
    ])
    
    XCTAssertEqual(innerFields.map { $0.description }, [
      nil,
      "The name of the character"
    ])
    
    XCTAssertEqual(innerFields.map { $0.isDeprecated }, [
      nil,
      false
    ])
    
    let inlineFragments = try XCTUnwrap(outerField.inlineFragments)
    XCTAssertEqual(inlineFragments.map { $0.typeCondition }, [
      "Human",
      "Droid"
    ])
    
    XCTAssertEqual(inlineFragments.map { $0.possibleTypes }, [
      [ "Human" ],
      [ "Droid" ]
    ])
    
    XCTAssertEqual(inlineFragments.map { $0.fragmentSpreads.count }, [
      0,
      0
    ])
    
    let humanFields = inlineFragments[0].fields
    XCTAssertEqual(humanFields.map { $0.responseName }, [
      "__typename",
      "name",
      "height"
    ])
    
    XCTAssertEqual(humanFields.map { $0.fieldName }, [
      "__typename",
      "name",
      "height"
    ])
    
    XCTAssertEqual(humanFields.map { $0.typeNode }, [
      .nonNullNamed("String"),
      .nonNullNamed("String"),
      .named("Float"),
    ])
    
    XCTAssertEqual(humanFields.map { $0.isConditional }, [
      false,
      false,
      false
    ])
    
    XCTAssertEqual(humanFields.map { $0.description }, [
      nil,
      "What this human calls themselves",
      "Height in the preferred unit, default is meters"
    ])
    
    XCTAssertEqual(humanFields.map { $0.isDeprecated }, [
      nil,
      false,
      false
    ])
      
    let droidFields = inlineFragments[1].fields
    XCTAssertEqual(droidFields.map { $0.responseName }, [
      "__typename",
      "name",
      "primaryFunction"
    ])
    
    XCTAssertEqual(droidFields.map { $0.fieldName }, [
      "__typename",
      "name",
      "primaryFunction"
    ])
    
    XCTAssertEqual(droidFields.map { $0.typeNode }, [
      .nonNullNamed("String"),
      .nonNullNamed("String"),
      .named("String"),
    ])
    
    XCTAssertEqual(droidFields.map { $0.isConditional }, [
      false,
      false,
      false
    ])
    
    XCTAssertEqual(droidFields.map { $0.description }, [
      nil,
      "What others call this droid",
      "This droid's primary function"
    ])
    
    XCTAssertEqual(droidFields.map { $0.isDeprecated }, [
      nil,
      false,
      false
    ])
  }
  
  func testParsingQueryWithAliasesAndPassedInRawValue() throws {
    let output: ASTOutput
    do {
      output = try loadAST(from: starWarsJSONURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
      return
    }
    
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
    
    XCTAssertEqual(outerFields.map { $0.typeNode }, [
      .named("Character"),
      .named("Character"),
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
    XCTAssertEqual(lukeArg.typeNode, .named("Episode"))
    
    let r2Fields = try XCTUnwrap(outerFields[0].fields)
    XCTAssertEqual(r2Fields.map { $0.responseName }, [
      "__typename",
      "name"
    ])
    
    XCTAssertEqual(r2Fields.map { $0.fieldName }, [
      "__typename",
      "name"
    ])
    
    XCTAssertEqual(r2Fields.map { $0.typeNode }, [
      .nonNullNamed("String"),
      .nonNullNamed("String"),
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
    
    XCTAssertEqual(lukeFields.map { $0.typeNode }, [
      .nonNullNamed("String"),
      .nonNullNamed("String"),
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
  }
  
  func testParsingQueryWithConditionalInclusion() throws {
    let output: ASTOutput
    do {
      output = try loadAST(from: starWarsJSONURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
      return
    }
    
    let heroNameConditionalInclusionQuery = try XCTUnwrap(output.operations.first(where: { $0.operationName == "HeroNameConditionalInclusion" }))
    
    XCTAssertTrue(heroNameConditionalInclusionQuery.filePath.hasPrefix("file:///"))
    XCTAssertTrue(heroNameConditionalInclusionQuery.filePath
      .hasSuffix("/Sources/StarWarsAPI/HeroConditional.graphql"))
    XCTAssertEqual(heroNameConditionalInclusionQuery.operationType, .query)
    XCTAssertEqual(heroNameConditionalInclusionQuery.rootType, "Query")
    
    XCTAssertEqual(heroNameConditionalInclusionQuery.source, """
query HeroNameConditionalInclusion($includeName: Boolean!) {\n  hero {\n    __typename\n    name @include(if: $includeName)\n  }\n}
""")
    XCTAssertTrue(heroNameConditionalInclusionQuery.fragmentSpreads.isEmpty)
    XCTAssertTrue(heroNameConditionalInclusionQuery.inlineFragments.isEmpty)
    XCTAssertTrue(heroNameConditionalInclusionQuery.fragmentsReferenced.isEmpty)
    
    XCTAssertEqual(heroNameConditionalInclusionQuery.sourceWithFragments, """
query HeroNameConditionalInclusion($includeName: Boolean!) {\n  hero {\n    __typename\n    name @include(if: $includeName)\n  }\n}
""")
    
    XCTAssertEqual(heroNameConditionalInclusionQuery.operationId, "338081aea3acc83d04af0741ecf0da1ec2ee8e6468a88383476b681015905ef8")
    
    
    XCTAssertEqual(heroNameConditionalInclusionQuery.variables.count, 1)
    let variable = heroNameConditionalInclusionQuery.variables[0]
    
    XCTAssertEqual(variable.name, "includeName")
    XCTAssertEqual(variable.typeNode, .nonNullNamed("Boolean"))
    
    XCTAssertEqual(heroNameConditionalInclusionQuery.fields.count, 1)
    let outerField = heroNameConditionalInclusionQuery.fields[0]
    
    XCTAssertEqual(outerField.responseName, "hero")
    XCTAssertEqual(outerField.fieldName, "hero")
    XCTAssertEqual(outerField.typeNode, .named("Character"))
    XCTAssertFalse(outerField.isConditional)
    
    let isDeprecated = try XCTUnwrap(outerField.isDeprecated)
    XCTAssertFalse(isDeprecated)
    let fragmentSpreads = try XCTUnwrap(outerField.fragmentSpreads)
    XCTAssertTrue(fragmentSpreads.isEmpty)
    let inlineFragments = try XCTUnwrap(outerField.inlineFragments)
    XCTAssertTrue(inlineFragments.isEmpty)
    
    let innerFields = try XCTUnwrap(outerField.fields)
    XCTAssertEqual(innerFields.count, 2)
    
    XCTAssertEqual(innerFields.map { $0.responseName }, [
      "__typename",
      "name"
    ])
    
    XCTAssertEqual(innerFields.map { $0.fieldName }, [
      "__typename",
      "name"
    ])
    
    XCTAssertEqual(innerFields.map { $0.typeNode }, [
      .nonNullNamed("String"),
      .nonNullNamed("String"),
    ])
    
    XCTAssertEqual(innerFields.map { $0.isConditional }, [
      false,
      true
    ])
    
    XCTAssertEqual(innerFields.map { $0.isDeprecated }, [
      nil,
      false
    ])
    
    XCTAssertEqual(innerFields.map { $0.conditions?.count }, [
      nil,
      1
    ])
    
    let conditions = try XCTUnwrap(innerFields[1].conditions)
    let condition = try XCTUnwrap(conditions.first)
    XCTAssertEqual(condition.kind, .BooleanCondition)
    XCTAssertEqual(condition.variableName, "includeName")
    XCTAssertFalse(condition.inverted)
  }
  
  func testParsingQueryWithConditionalExclusion() throws {
    let output: ASTOutput
    do {
      output = try loadAST(from: starWarsJSONURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
      return
    }
    
    let heroNameConditionalExclusionQuery = try XCTUnwrap(output.operations.first(where: { $0.operationName == "HeroNameConditionalExclusion" }))
    
    XCTAssertTrue(heroNameConditionalExclusionQuery.filePath.hasPrefix("file:///"))
    XCTAssertTrue(heroNameConditionalExclusionQuery.filePath
      .hasSuffix("/Sources/StarWarsAPI/HeroConditional.graphql"))
    XCTAssertEqual(heroNameConditionalExclusionQuery.operationType, .query)
    XCTAssertEqual(heroNameConditionalExclusionQuery.rootType, "Query")
    
    XCTAssertEqual(heroNameConditionalExclusionQuery.source, """
query HeroNameConditionalExclusion($skipName: Boolean!) {\n  hero {\n    __typename\n    name @skip(if: $skipName)\n  }\n}
""")
    XCTAssertTrue(heroNameConditionalExclusionQuery.fragmentSpreads.isEmpty)
    XCTAssertTrue(heroNameConditionalExclusionQuery.inlineFragments.isEmpty)
    XCTAssertTrue(heroNameConditionalExclusionQuery.fragmentsReferenced.isEmpty)
    
    XCTAssertEqual(heroNameConditionalExclusionQuery.sourceWithFragments, """
query HeroNameConditionalExclusion($skipName: Boolean!) {\n  hero {\n    __typename\n    name @skip(if: $skipName)\n  }\n}
""")
    
    XCTAssertEqual(heroNameConditionalExclusionQuery.operationId, "3dd42259adf2d0598e89e0279bee2c128a7913f02b1da6aa43f3b5def6a8a1f8")
    
    XCTAssertEqual(heroNameConditionalExclusionQuery.variables.count, 1)
    let variable = heroNameConditionalExclusionQuery.variables[0]
    
    XCTAssertEqual(variable.name, "skipName")
    XCTAssertEqual(variable.typeNode, .nonNullNamed("Boolean"))
    
    XCTAssertEqual(heroNameConditionalExclusionQuery.fields.count, 1)
    let outerField = heroNameConditionalExclusionQuery.fields[0]
    
    XCTAssertEqual(outerField.responseName, "hero")
    XCTAssertEqual(outerField.fieldName, "hero")
    XCTAssertEqual(outerField.typeNode, .named("Character"))
    XCTAssertFalse(outerField.isConditional)
    
    let isDeprecated = try XCTUnwrap(outerField.isDeprecated)
    XCTAssertFalse(isDeprecated)
    let fragmentSpreads = try XCTUnwrap(outerField.fragmentSpreads)
    XCTAssertTrue(fragmentSpreads.isEmpty)
    let inlineFragments = try XCTUnwrap(outerField.inlineFragments)
    XCTAssertTrue(inlineFragments.isEmpty)
    
    let innerFields = try XCTUnwrap(outerField.fields)
    XCTAssertEqual(innerFields.count, 2)
    
    XCTAssertEqual(innerFields.map { $0.responseName }, [
      "__typename",
      "name"
    ])
    
    XCTAssertEqual(innerFields.map { $0.fieldName }, [
      "__typename",
      "name"
    ])
    
    XCTAssertEqual(innerFields.map { $0.typeNode }, [
      .nonNullNamed("String"),
      .nonNullNamed("String"),
    ])
    
    XCTAssertEqual(innerFields.map { $0.isConditional }, [
      false,
      true
    ])
    
    XCTAssertEqual(innerFields.map { $0.isDeprecated }, [
      nil,
      false
    ])
    
    XCTAssertEqual(innerFields.map { $0.conditions?.count }, [
      nil,
      1
    ])
    
    let conditions = try XCTUnwrap(innerFields[1].conditions)
    let condition = try XCTUnwrap(conditions.first)
    XCTAssertEqual(condition.kind, .BooleanCondition)
    XCTAssertEqual(condition.variableName, "skipName")
    XCTAssertTrue(condition.inverted)
  }
  
  func testParsingQueryWithConditionalFragmentInclusion() throws {
    let output: ASTOutput
    do {
      output = try loadAST(from: starWarsJSONURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
      return
    }
    
    let heroDetailsFragmentConditionalInclusionQuery = try XCTUnwrap(output.operations.first(where: { $0.operationName == "HeroDetailsFragmentConditionalInclusion" }))
    
    XCTAssertTrue(heroDetailsFragmentConditionalInclusionQuery.filePath.hasPrefix("file:///"))
    XCTAssertTrue(heroDetailsFragmentConditionalInclusionQuery.filePath
      .hasSuffix("/Sources/StarWarsAPI/HeroConditional.graphql"))
    XCTAssertEqual(heroDetailsFragmentConditionalInclusionQuery.operationType, .query)
    XCTAssertEqual(heroDetailsFragmentConditionalInclusionQuery.rootType, "Query")
    
    XCTAssertEqual(heroDetailsFragmentConditionalInclusionQuery.source, """
query HeroDetailsFragmentConditionalInclusion($includeDetails: Boolean!) {\n  hero {\n    __typename\n    ...HeroDetails @include(if: $includeDetails)\n  }\n}
""")
    XCTAssertTrue(heroDetailsFragmentConditionalInclusionQuery.fragmentSpreads.isEmpty)
    XCTAssertTrue(heroDetailsFragmentConditionalInclusionQuery.inlineFragments.isEmpty)
    XCTAssertEqual(heroDetailsFragmentConditionalInclusionQuery.fragmentsReferenced, [
      "HeroDetails"
    ])
    
    XCTAssertEqual(heroDetailsFragmentConditionalInclusionQuery.sourceWithFragments, """
query HeroDetailsFragmentConditionalInclusion($includeDetails: Boolean!) {\n  hero {\n    __typename\n    ...HeroDetails @include(if: $includeDetails)\n  }\n}\nfragment HeroDetails on Character {\n  __typename\n  name\n  ... on Human {\n    height\n  }\n  ... on Droid {\n    primaryFunction\n  }\n}
""")
    
    XCTAssertEqual(heroDetailsFragmentConditionalInclusionQuery.operationId, "b31aec7d977249e185922e4cc90318fd2c7197631470904bf937b0626de54b4f")
    
    XCTAssertEqual(heroDetailsFragmentConditionalInclusionQuery.variables.count, 1)
    let variable = try XCTUnwrap(heroDetailsFragmentConditionalInclusionQuery.variables.first)
    
    XCTAssertEqual(variable.name, "includeDetails")
    XCTAssertEqual(variable.typeNode, .nonNullNamed("Boolean"))
    
    XCTAssertEqual(heroDetailsFragmentConditionalInclusionQuery.fields.count, 1)
    let outerField = try XCTUnwrap(heroDetailsFragmentConditionalInclusionQuery.fields.first)
    
    XCTAssertEqual(outerField.responseName, "hero")
    XCTAssertEqual(outerField.fieldName, "hero")
    XCTAssertEqual(outerField.typeNode, .named("Character"))
    XCTAssertFalse(outerField.isConditional)
    
    let isDeprecated = try XCTUnwrap(outerField.isDeprecated)
    XCTAssertFalse(isDeprecated)
    
    XCTAssertEqual(outerField.fragmentSpreads, [
      "HeroDetails"
    ])
    
    let innerFields = try XCTUnwrap(outerField.fields)
    XCTAssertEqual(innerFields.map { $0.responseName }, [
      "__typename",
      "name"
    ])
    
    XCTAssertEqual(innerFields.map { $0.fieldName }, [
      "__typename",
      "name"
    ])
    
    XCTAssertEqual(innerFields.map { $0.typeNode }, [
      .nonNullNamed("String"),
      .nonNullNamed("String"),
    ])
    
    XCTAssertEqual(innerFields.map { $0.isConditional }, [
      false,
      true
    ])
    
    XCTAssertEqual(innerFields.map { $0.description }, [
      nil,
      "The name of the character"
    ])
    
    XCTAssertEqual(innerFields.map { $0.isDeprecated }, [
      nil,
      false
    ])
    
    XCTAssertEqual(innerFields.map { $0.conditions?.count }, [
      1,
      1
    ])
    
    let expectedCondition = ASTCondition(kind: .BooleanCondition,
                                         variableName: "includeDetails",
                                         inverted: false)
    
    XCTAssertEqual(innerFields.map { $0.conditions?.first }, [
      expectedCondition,
      expectedCondition
    ])
    
    let inlineFragments = try XCTUnwrap(outerField.inlineFragments)
    XCTAssertEqual(inlineFragments.count, 2)
    
    XCTAssertEqual(inlineFragments.map { $0.typeCondition }, [
      "Human",
      "Droid"
    ])
    
    XCTAssertEqual(inlineFragments.map { $0.possibleTypes }, [
      [ "Human" ],
      [ "Droid" ]
    ])
    
    XCTAssertEqual(inlineFragments.map { $0.fields.count }, [
      3,
      3,
    ])
    
    XCTAssertEqual(inlineFragments.map { $0.fragmentSpreads }, [
      [ "HeroDetails" ],
      [ "HeroDetails" ]
    ])
    
    let humanFields = inlineFragments[0].fields
    XCTAssertEqual(humanFields.map { $0.responseName }, [
      "__typename",
      "name",
      "height"
    ])
    
    XCTAssertEqual(humanFields.map { $0.fieldName }, [
      "__typename",
      "name",
      "height"
    ])
    
    XCTAssertEqual(humanFields.map { $0.typeNode }, [
      .nonNullNamed("String"),
      .nonNullNamed("String"),
      .named("Float"),
    ])
    
    XCTAssertEqual(humanFields.map { $0.isConditional }, [
      false,
      true,
      true
    ])
    
    XCTAssertEqual(humanFields.map { $0.isDeprecated }, [
      nil,
      false,
      false
    ])
    
    XCTAssertEqual(humanFields.map { $0.description }, [
      nil,
      "What this human calls themselves",
      "Height in the preferred unit, default is meters"
    ])
    
    XCTAssertEqual(humanFields.map { $0.conditions }, [
      [ expectedCondition, expectedCondition, expectedCondition ],
      [ expectedCondition, expectedCondition, expectedCondition ],
      [ expectedCondition ]
    ])
    
    let droidFields = inlineFragments[1].fields
    XCTAssertEqual(droidFields.map { $0.responseName }, [
      "__typename",
      "name",
      "primaryFunction"
    ])
    
    XCTAssertEqual(droidFields.map { $0.fieldName }, [
      "__typename",
      "name",
      "primaryFunction"
    ])
    
    XCTAssertEqual(droidFields.map { $0.typeNode }, [
      .nonNullNamed("String"),
      .nonNullNamed("String"),
      .named("String"),
    ])
    
    XCTAssertEqual(droidFields.map { $0.isConditional }, [
      false,
      true,
      true
    ])
    
    XCTAssertEqual(droidFields.map { $0.isDeprecated }, [
      nil,
      false,
      false
    ])
    
    XCTAssertEqual(droidFields.map { $0.description }, [
      nil,
      "What others call this droid",
      "This droid's primary function"
    ])
    
    XCTAssertEqual(droidFields.map { $0.conditions }, [
      [ expectedCondition, expectedCondition, expectedCondition ],
      [ expectedCondition, expectedCondition, expectedCondition ],
      [ expectedCondition ]
    ])
  }
}
