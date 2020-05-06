//
//  InputObjectGenerationTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 4/1/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import XCTest

@testable import ApolloCodegenLib

class InputObjectGenerationTests: XCTestCase {
  
  private lazy var dummyOptions: ApolloCodegenOptions = {
    let unusedURL = CodegenTestHelper.apolloFolderURL()
    return ApolloCodegenOptions(outputFormat: .singleFile(atFileURL: unusedURL),
                                urlToSchemaFile: unusedURL)
  }()
  
  private func colorInput(named name: String) -> ASTTypeUsed {
    let red = ASTTypeUsed.Field(name: "red",
                                typeNode: .nonNullNamed("Int"),
                                description: nil)
    let green = ASTTypeUsed.Field(name: "green",
                                  typeNode: .nonNullNamed("Int"),
                                  description: nil)
    let blue = ASTTypeUsed.Field(name: "blue",
                                 typeNode: .nonNullNamed("Int"),
                                 description: nil)
    
    let colorInput = ASTTypeUsed(kind: .InputObjectType,
                                 name: name,
                                 description: "The input object sent when passing in a color",
                                 values: nil,
                                 fields: [
                                  red,
                                  green,
                                  blue,
                                 ])
    return colorInput
  }
  
  private func reviewInput(named name: String) -> ASTTypeUsed {
    let stars = ASTTypeUsed.Field(name: "stars",
                                  typeNode: .nonNullNamed("Int"),
                                  description: "0-5 stars")
    let commentary = ASTTypeUsed.Field(name: "commentary",
                                       typeNode: .named("String"),
                                       description: "Comment about the movie, optional")
    let favoriteColor = ASTTypeUsed.Field(name: "favoriteColor",
                                          typeNode: .named("ColorInput"),
                                          description: "Favorite color, optional")
    
    let reviewInput = ASTTypeUsed(kind: .InputObjectType,
                                  name: name,
                                  description: "The input object sent when someone is creating a new review",
                                  values: nil,
                                  fields: [
                                    stars,
                                    commentary,
                                    favoriteColor,
                                  ])
    
    return reviewInput
  }
  
  func testGeneratingInputObjectWithNoOptionalProperties() {
    do {
      let output = try InputObjectGenerator().run(typeUsed: self.colorInput(named: "ColorInput"), options: self.dummyOptions)

      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedColorInput.swift")
      
      LineByLineComparison.between(received: output,
                                   expectedFileURL: expectedFileURL,
                                   trimImports: true)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testGeneratingInputWithNoOptionalPropertiesAndNoModifier() {
    let dummyURL = CodegenTestHelper.apolloFolderURL()
    let options = ApolloCodegenOptions(modifier: .none,
                                       outputFormat: .singleFile(atFileURL: dummyURL),
                                       urlToSchemaFile: dummyURL)
    do {
      let output = try InputObjectGenerator().run(typeUsed: self.colorInput(named: "ColorInputNoModifier"), options: options)

      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedColorInputNoModifier.swift")
      
      LineByLineComparison.between(received: output,
                                   expectedFileURL: expectedFileURL,
                                   trimImports: true)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testGeneratingInputObjectWithOptionalProperties() {
    do {
      let output = try InputObjectGenerator().run(typeUsed: self.reviewInput(named: "ReviewInput"), options: self.dummyOptions)

      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedReviewInput.swift")
      
      LineByLineComparison.between(received: output,
                                   expectedFileURL: expectedFileURL,
                                   trimImports: true)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testGeneratingInputObjectWithOptionalPropertiesAndNoModifier() {
    let dummyURL = CodegenTestHelper.apolloFolderURL()
    let options = ApolloCodegenOptions(modifier: .none,
                                       outputFormat: .singleFile(atFileURL: dummyURL),
                                       urlToSchemaFile: dummyURL)
    do {
      let output = try InputObjectGenerator().run(typeUsed: self.reviewInput(named: "ReviewInputNoModifier"), options: options)
      
      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedReviewInputNoModifier.swift")
      
      LineByLineComparison.between(received: output,
                                   expectedFileURL: expectedFileURL,
                                   trimImports: true)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
}
