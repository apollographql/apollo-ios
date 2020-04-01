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
                                type: "Int",
                                description: nil)
    let green = ASTTypeUsed.Field(name: "green",
                                  type: "Int",
                                  description: nil)
    let blue = ASTTypeUsed.Field(name: "blue",
                                 type: "Int",
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
  
  func testGeneratingInputWithOptionalPropertiesAndNoModifier() {
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
    
  }
}
