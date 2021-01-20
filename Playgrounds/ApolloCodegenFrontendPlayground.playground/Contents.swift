import Foundation
@testable import ApolloCodegenLib
import StarWarsAPI

let codegenFrontend = ApolloCodegenFrontend()

let starWarsAPIBundle = Bundle(identifier: "com.apollographql.StarWarsAPI.macosx")!

// Loading a schema parse either the introspection result or SDL based on the file extension.

let schema = try codegenFrontend.loadSchema(from: starWarsAPIBundle.url(forResource: "schema", withExtension: "json")!)

// It will throw GraphQLSchemaValidationError if there are any schema validation errors, with a validationErrors array as a property.

// GraphQLSchema directly exposes the underlying `graphql-js` methods (but we can make the naming more swifty). It allows you to introspect the schema: get possible types, explore type relationships, fields, enum values, etc.

if let characterType = schema.getType(named: "Character") as? GraphQLAbstractType {
  let possibleTypes = schema.getPossibleTypes(characterType)
  
  possibleTypes[0].name
  possibleTypes[0].fields["appearsIn"]?.type.typeReference
}

// You first create GraphQLSource objects representing input files, either by passing in a string or a file URL.

let source1 = try codegenFrontend.makeSource("""
  query HeroAndFriendsNames($episode: Episode) {
    hero(episode: $episode) {
      name
      # email
      ...FriendsNames
    }
  }
  """, filePath: "HeroAndFriendsNames.graphql")

let source2 = try codegenFrontend.makeSource("""
  fragment FriendsNames on Character {
    friends {
      name
    }
  }
  """, filePath: "FriendsNames.graphql")

// Parsing a document will throw a GraphQLError for a syntax error. Those errors also wrap the underlying `graphql-js` objects so you can get error details if you need them. Or call `error.logLines` to get errors in a format that lets Xcode show inline errors.

let document1 = try codegenFrontend.parseDocument(source1)
let document2 = try codegenFrontend.parseDocument(source2)

// Validation and compilation take a single document, but you can merge documents and operations and fragments will remember their source.
let document = try codegenFrontend.mergeDocuments([document1, document2])

let validationErrors = codegenFrontend.validateDocument(schema: schema, document: document)

// Try uncommenting `email` or make other changes that lead to validation errors to see them show up here.
let logLines = validationErrors.flatMap(\.logLines).joined(separator: "\n")

if validationErrors.isEmpty {
  let compilationResult = try codegenFrontend.compile(schema: schema, document: document)
  
  compilationResult.operations[0].filePath
  compilationResult.operations[0].name
  compilationResult.operations[0].selectionSet.selections[0]
  
  compilationResult.fragments[0].filePath
  compilationResult.fragments[0].name
  compilationResult.fragments[0].selectionSet.selections[0]
  
  compilationResult.referencedTypes.map(\.name)
}
