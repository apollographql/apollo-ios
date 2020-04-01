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
  
  func testGeneratingInputObjectWithNoOptionalProperties() {
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
                                 name: "ColorInput",
                                 description: "The input object sent when passing in a color",
                                 values: nil,
                                 fields: [
                                  red,
                                  green,
                                  blue,
                                 ])
    
    do {
      let output = try InputObjectGenerator().run(typeUsed: colorInput, options: self.dummyOptions)

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
  
  func testGeneratingInputObjectWithOptionalProperties() {
    
  }
}
