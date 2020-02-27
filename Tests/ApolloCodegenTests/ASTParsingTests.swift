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
        return
      default:
        XCTFail("Unexpected error loading AST: \(error)")
      }
    }
  }
}
