//
//  UnionEnumGenerationTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 6/3/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import Foundation
import XCTest
import ApolloCodegenTestSupport
@testable import ApolloCodegenLib

class UnionEnumGenerationTests: XCTestCase {
  
  func testGeneratingUnionEnum() {
    let union = ASTUnionType(name: "SearchResult",
                             types: [
                              "Human",
                              "Droid",
                              "Starship",
                             ])
    do {
      let output = try UnionEnumGenerator().run(unionType: union, options: CodegenTestHelper.dummyOptions())
      
      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedSearchResultType.swift")
      
      LineByLineComparison.between(received: output,
                                   expectedFileURL: expectedFileURL,
                                   trimImports: true)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testGeneratingUnionEnumWithSanitizedCaseNames() {
    let union = ASTUnionType(name: "SanitizedSearchResult",
                                     types: [
                                      "case",
                                      "self",
                                      "Type",
                                      "Protocol",
                                     ])
    do {
      let output = try UnionEnumGenerator().run(unionType: union, options: CodegenTestHelper.dummyOptions())
      
      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedSanitizedSearchResultType.swift")
      
      LineByLineComparison.between(received: output,
                                   expectedFileURL: expectedFileURL,
                                   trimImports: true)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testGeneratingUnionEnumWithNoCases() {
    let union = ASTUnionType(name: "NoCasesSearchResult",
                             types: [
                             ])
    do {
      let output = try UnionEnumGenerator().run(unionType: union, options: CodegenTestHelper.dummyOptions())
      
      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedNoCasesSearchResultType.swift")
      
      LineByLineComparison.between(received: output,
                                   expectedFileURL: expectedFileURL,
                                   trimImports: true)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testGeneratingEnumWithNoModifier() {
    let union = ASTUnionType(name: "NoModifierSearchResult",
                             types: [
                              "Human",
                              "Droid",
                              "Starship",
                             ])
    
    do {
      let output = try UnionEnumGenerator().run(unionType: union, options: CodegenTestHelper.dummyOptionsNoModifier())
      
      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedNoModifierSearchResultType.swift")
      
      LineByLineComparison.between(received: output,
                                   expectedFileURL: expectedFileURL,
                                   trimImports: true)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
}
