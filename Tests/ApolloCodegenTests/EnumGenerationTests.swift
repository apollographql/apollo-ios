//
//  EnumGenerationTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 3/6/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import XCTest
@testable import ApolloCodegenLib

class EnumGenerationTests: XCTestCase {
  
  private lazy var dummyOptions: ApolloCodegenOptions = {
    let unusedURL = CodegenTestHelper.apolloFolderURL()
    return ApolloCodegenOptions(outputFormat: .singleFile(atFileURL: unusedURL),
                                urlToSchemaFile: unusedURL)
  }()
  
  
  func testTryingToGenerateWrongKindThrowsAppropriateError() throws {
    let wrongKind = ASTTypeUsed(kind: .InputObjectType,
                                name: "InputObject",
                                description: "A generic input object",
                                values: nil,
                                fields: [
                                  ASTTypeUsed.Field(name: "test",
                                                    typeNode: .nonNullNamed("String!"),
                                                    description: nil)
                                ])
    
    do {
      _ = try EnumGenerator().run(typeUsed: wrongKind, options: self.dummyOptions)
    } catch {
      switch error {
      case EnumGenerator.EnumGenerationError.kindIsNotAnEnum:
        // This is what we want
        break
      default:
        XCTFail("Unexpected error generating enum: \(error)")
      }
    }
  }
  
  func testGeneratingEnumWithNilCasesThrowsAppropriateError() {
    let nilCases = ASTTypeUsed(kind: .EnumType,
                              name: "NoCases",
                              description: "An enum with nil cases",
                              values: nil,
                              fields: nil)
    do {
      _ = try EnumGenerator().run(typeUsed: nilCases, options: self.dummyOptions)
    } catch {
      switch error {
      case EnumGenerator.EnumGenerationError.enumHasNilCases:
        // This is what we want
        break
      default:
        XCTFail("Unexpected error generating enum: \(error)")
      }
    }
  }
  
  
  func testGeneratingEnumWithNoDeprecatedCases() throws {
    let newHope = ASTEnumValue(name: "NEWHOPE",
                               description: "Star Wars Episode IV: A New Hope, released in 1977.",
                               isDeprecated: false)
    let empire = ASTEnumValue(name: "EMPIRE",
                              description: "Star Wars Episode V: The Empire Strikes Back, released in 1980.",
                              isDeprecated: false)
    let jedi = ASTEnumValue(name: "JEDI",
                            description: "Star Wars Episode VI: Return of the Jedi, released in 1983.",
                            isDeprecated: false)
    
    let episodeEnum = ASTTypeUsed(kind: .EnumType,
                                  name: "Episode",
                                  description: "The episodes in the Star Wars trilogy",
                                  values: [
                                    newHope,
                                    empire,
                                    jedi
                                  ],
                                  fields: nil)
    
    do {
      let output = try EnumGenerator().run(typeUsed: episodeEnum, options: self.dummyOptions)
      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedEpisodeEnum.swift")
      
      LineByLineComparison.between(received: output, expectedFileURL: expectedFileURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testGeneratingEnumWithNoDescriptions() throws {
    let newHope = ASTEnumValue(name: "NEWHOPE",
                               description: "",
                               isDeprecated: false)
    let empire = ASTEnumValue(name: "EMPIRE",
                              description: "",
                              isDeprecated: false)
    let jedi = ASTEnumValue(name: "JEDI",
                            description: "",
                            isDeprecated: false)
    
    let withoutDescriptions = ASTTypeUsed(kind: .EnumType,
                                          name: "EpisodeWithoutDescription",
                                          description: "",
                                          values: [
                                            newHope,
                                            empire,
                                            jedi
                                          ],
                                          fields: nil)
    do {
      let output = try EnumGenerator().run(typeUsed: withoutDescriptions, options: self.dummyOptions)
      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedEpisodeEnumNoDescription.swift")
      
      LineByLineComparison.between(received: output, expectedFileURL: expectedFileURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testGeneratingEnumWithDeprecatedCases() throws {
    let notDeprecated = ASTEnumValue(name: "notDeprecated",
                                     description: "This value is not deprecated",
                                     isDeprecated: false)
    let deprecated = ASTEnumValue(name: "isDeprecated",
                                  description: "This value is deprecated",
                                  isDeprecated: true)
    
    let withDeprecated = ASTTypeUsed(kind: .EnumType,
                                     name: "EnumWithDeprecatedCases",
                                     description: "An enum with deprecated cases",
                                     values: [
                                      notDeprecated,
                                      deprecated
                                     ],
                                     fields: nil)
    do {
      let output = try EnumGenerator().run(typeUsed: withDeprecated, options: self.dummyOptions)
      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedEnumWithDeprecatedCases.swift")
      
      LineByLineComparison.between(received: output, expectedFileURL: expectedFileURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testGeneratingEnumOmittingDeprecatedCases() throws {
    let notDeprecated = ASTEnumValue(name: "notDeprecated",
                                     description: "This value is not deprecated",
                                     isDeprecated: false)
    let deprecated = ASTEnumValue(name: "isDeprecated",
                                  description: "This value is deprecated",
                                  isDeprecated: true)
    
    let withDeprecated = ASTTypeUsed(kind: .EnumType,
                                     name: "EnumOmittingDeprecatedCases",
                                     description: "An enum generated by omitting deprecated cases",
                                     values: [
                                      notDeprecated,
                                      deprecated
                                     ],
                                     fields: nil)
    do {
      let dummyURL = CodegenTestHelper.apolloFolderURL()
      let options = ApolloCodegenOptions(omitDeprecatedEnumCases: true,
                                         outputFormat: .singleFile(atFileURL: dummyURL),
                                         urlToSchemaFile: dummyURL)
      
      let output = try EnumGenerator().run(typeUsed: withDeprecated, options: options)
      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedEnumOmittingDeprecatedCases.swift")
      
      LineByLineComparison.between(received: output, expectedFileURL: expectedFileURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testGeneratingEnumWithNoCases() throws {
    let withoutCases = ASTTypeUsed(kind: .EnumType,
                                   name: "EnumWithoutCases",
                                   description: "",
                                   values: [
                                   ],
                                   fields: nil)
    
    do {
      let output = try EnumGenerator().run(typeUsed: withoutCases, options: self.dummyOptions)
      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedEnumWithNoCases.swift")

      LineByLineComparison.between(received: output, expectedFileURL: expectedFileURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testGeneratingEnumWithDifferentCases() {
    let camelCase = ASTEnumValue(name: "caseName",
                                 description: "A camelCase case name",
                                 isDeprecated: false)
    let uppercase = ASTEnumValue(name: "CASENAME",
                                 description: "An UPPERCASE case name",
                                 isDeprecated: false)
    
    let differentCases = ASTTypeUsed(kind: .EnumType,
                                     name: "EnumWithDifferentCases",
                                     description: "An enum with two cases with the same letters but different cases",
                                     values: [
                                      camelCase,
                                      uppercase,
                                     ],
                                     fields: nil)
    
    do {
      let output = try EnumGenerator().run(typeUsed: differentCases, options: self.dummyOptions)
      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedEnumWithDifferentCases.swift")

      LineByLineComparison.between(received: output, expectedFileURL: expectedFileURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testGeneratingEnumWithSanitizedCaseNames() throws {
    let caseCase = ASTEnumValue(name: "case",
                                description: "",
                                isDeprecated: false)
    let selfCase = ASTEnumValue(name: "self",
                                description: "",
                                isDeprecated: false)
    let typeCase = ASTEnumValue(name: "Type",
                                description: "",
                                isDeprecated: false)
    let protocolCase = ASTEnumValue(name: "Protocol",
                                    description: "",
                                    isDeprecated: false)
    
    let sanitizedCases = ASTTypeUsed(kind: .EnumType,
                                     name: "EnumWithSanitizedCases",
                                     description: "An enum with sanitized case names",
                                     values: [
                                      caseCase,
                                      selfCase,
                                      typeCase,
                                      protocolCase,
                                     ],
                                     fields: nil)
    
    
    do {
      let output = try EnumGenerator().run(typeUsed: sanitizedCases, options: self.dummyOptions)
      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedEnumWithSanitizedCases.swift")

      LineByLineComparison.between(received: output, expectedFileURL: expectedFileURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testGeneratingEnumWithoutModifier() {
    let newHope = ASTEnumValue(name: "NEWHOPE",
                               description: "Star Wars Episode IV: A New Hope, released in 1977.",
                               isDeprecated: false)
    let empire = ASTEnumValue(name: "EMPIRE",
                              description: "Star Wars Episode V: The Empire Strikes Back, released in 1980.",
                              isDeprecated: false)
    let jedi = ASTEnumValue(name: "JEDI",
                            description: "Star Wars Episode VI: Return of the Jedi, released in 1983.",
                            isDeprecated: false)
    
    let episodeEnum = ASTTypeUsed(kind: .EnumType,
                                  name: "EpisodeWithoutModifier",
                                  description: "The episodes in the Star Wars trilogy",
                                  values: [
                                    newHope,
                                    empire,
                                    jedi
                                  ],
                                  fields: nil)
    
    let unusedURL = CodegenTestHelper.apolloFolderURL()
    let options = ApolloCodegenOptions(modifier: .none,
                                       outputFormat: .singleFile(atFileURL: unusedURL),
                                       urlToSchemaFile: unusedURL)
    
    
    do {
      let output = try EnumGenerator().run(typeUsed: episodeEnum, options: options)
      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedEpisodeEnumWithoutModifier.swift")
      
      LineByLineComparison.between(received: output, expectedFileURL: expectedFileURL)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
}
