//
//  LineByLineComparison.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 3/9/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import Foundation
import XCTest
import ApolloCodegenTestSupport

struct LineByLineComparison {
    
  /// Compares line-by-line between the contents of a file and a received string
  /// NOTE: Will trim whitespace from the file since Xcode auto-adds a newline
  ///
  /// - Parameters:
  ///   - received: The string received from the test
  ///   - expectedFileURL: The file URL to the file with the expected contents of the received string
  ///   - trimImports: If imports at the top of the file should be trimmed before the comparison. Defaults to false.
  ///   - file: The file where this function is being called. Defaults to the direct caller
  ///   - line: The line where this function is being called. Defaults to the direct caller
  static func between(received: String,
                      expectedFileURL: URL,
                      trimImports: Bool = false,
                      file: StaticString = #filePath,
                      line: UInt = #line) {
    guard FileManager.default.apollo.fileExists(at: expectedFileURL) else {
      XCTFail("File not found at \(expectedFileURL)",
              file: file,
              line: line)
      return
    }
    
    let expected: String
    do {
      var fileContents = try String(contentsOf: expectedFileURL)
      if trimImports {
        fileContents = fileContents
          .components(separatedBy: "\n")
          .filter { !$0.hasPrefix("import ") }
          .joined(separator: "\n")
      }
      
      expected = fileContents.trimmingCharacters(in: .whitespacesAndNewlines)
    } catch {
      CodegenTestHelper.handleFileLoadError(error,
                                            file: file,
                                            line: line)
      return
    }
   
    self.between(received: received,
                 expected: expected,
                 file: file,
                 line: line)
  }
    
  /// Compares two strings line-by-line.
  ///
  /// - Parameters:
  ///   - received: The string received from the test
  ///   - expectedFileURL: The string you expected to receive from the test
  ///   - file: The file where this function is being called. Defaults to the direct caller
  ///   - line: The line where this function is being called. Defaults to the direct caller
  static func between(received: String,
                      expected: String,
                      file: StaticString = #filePath,
                      line: UInt = #line) {
    
    let receivedLines = received.components(separatedBy: "\n")
    let expectedLines = expected.components(separatedBy: "\n")

    guard receivedLines.count == expectedLines.count else {
      XCTFail("Expected \(expectedLines.count) lines, received \(receivedLines.count) lines.\nExpected: \n\(expected)\nReceived: \n\(received)",
              file: file,
              line: line)
      return
    }
    
    for (index, receivedLine) in receivedLines.enumerated() {
      XCTAssertEqual(receivedLine,
                     expectedLines[index],
                     "Line \(index + 1) did not match", // correct for 0-indexing
                     file: file,
                     line: line)
    }
  }
}
