//
//  InterfaceObjectGenerationTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 6/3/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import Foundation
import XCTest
import ApolloCodegenTestSupport
@testable import ApolloCodegenLib

class InterfaceEnumGenerationTests: XCTestCase {
  
  func testGeneratingInterfaceEnum() {
    let interface = ASTInterfaceType(name: "Character",
                                     types: [
                                      "Human",
                                      "Droid",
                                      "Alien"
                                     ])
    do {
      let output = try InterfaceEnumGenerator().run(interfaceType: interface, options: CodegenTestHelper.dummyOptions())

      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedCharacterType.swift")
      
      LineByLineComparison.between(received: output,
                                   expectedFileURL: expectedFileURL,
                                   trimImports: true)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testGeneratingInterfaceEnumWithSanitizedCaseNames() throws {
    let interface = ASTInterfaceType(name: "SanitizedCharacter",
                                     types: [
                                      "case",
                                      "self",
                                      "Type",
                                      "Protocol",
                                     ])
    do {
      let output = try InterfaceEnumGenerator().run(interfaceType: interface, options: CodegenTestHelper.dummyOptions())
      
      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedSanitizedCharacterType.swift")
      
      LineByLineComparison.between(received: output,
                                   expectedFileURL: expectedFileURL,
                                   trimImports: true)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testGeneratingInterfaceEnumWithNoCases() {
    let interface = ASTInterfaceType(name: "NoCasesCharacter",
                                     types: [
                                     ])
    do {
      let output = try InterfaceEnumGenerator().run(interfaceType: interface, options: CodegenTestHelper.dummyOptions())
      
      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedNoCasesCharacterType.swift")
      
      LineByLineComparison.between(received: output,
                                   expectedFileURL: expectedFileURL,
                                   trimImports: true)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
  
  func testGeneratingInterfaceEnumWithNoModifier() {
    let interface = ASTInterfaceType(name: "NoModifierCharacter",
                                     types: [
                                      "Human",
                                      "Droid",
                                      "Alien"
                                     ])
    
    do {
      let output = try InterfaceEnumGenerator().run(interfaceType: interface, options: CodegenTestHelper.dummyOptionsNoModifier())
      
      let expectedFileURL = CodegenTestHelper.sourceRootURL()
        .appendingPathComponent("Tests")
        .appendingPathComponent("ApolloCodegenTests")
        .appendingPathComponent("ExpectedNoModifierCharacterType.swift")
      
      LineByLineComparison.between(received: output,
                                   expectedFileURL: expectedFileURL,
                                   trimImports: true)
    } catch {
      CodegenTestHelper.handleFileLoadError(error)
    }
  }
}
