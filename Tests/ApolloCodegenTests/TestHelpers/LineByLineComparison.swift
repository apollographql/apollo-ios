import Foundation
import Nimble
import ApolloInternalTestHelpers
import ApolloCodegenInternalTestHelpers

/// A Nimble matcher that compares two strings line-by-line.
///
/// - Parameters:
///   - expectedValue: The expected string to match against
///   - atLine: [optional] The line in the actual value where matching should begin.
///   This parameter is 1 indexed, representing actual line number, not 0 indexed.
///   If provided, the actual value will be compared to the lines at the given range.
///   Defaults to `nil`.
public func equalLineByLine(
  _ expectedValue: String,
  atLine startLine: Int = 1,
  ignoringExtraLines: Bool = false
) -> Predicate<String> {
  return Predicate.define() { actual in
    let actualString = try actual.evaluate()

    guard let actualLines = actualString?.lines(startingAt: startLine) else {
      return PrettyPrintedFailureResult(
        actual: actualString,
        message: .fail("Insufficient Lines. Check `atLine` value.")
      )
    }

    let expectedLines = expectedValue.components(separatedBy: "\n")

    var expectedLinesBuffer: [String] = expectedLines.reversed()

    for index in actualLines.indices {
      let actualLine = actualLines[index]
      guard let expectedLine = expectedLinesBuffer.popLast() else {
        if ignoringExtraLines {
          return PredicateResult(
            status: .matches,
            message: .expectedTo("be equal")
          )
        } else {
          return PrettyPrintedFailureResult(
            actual: actualString,
            message: .fail("Expected \(expectedLines.count + startLine - 1) lines, actual ended at line \(actualLines.count + startLine - 1)")
          )
        }
      }

      if actualLine != expectedLine {
        return PrettyPrintedFailureResult(
          actual: actualString,
          message: .fail("Line \(index + 1) did not match. Expected \"\(expectedLine)\", got \"\(actualLine)\".")
        )
      }
    }

    guard expectedLinesBuffer.isEmpty else {
      return PredicateResult(
        status: .fail,
        message: .fail("Expected \(expectedLines.count), actual ended at line \(actualLines.count).")
      )
    }

    return PredicateResult(
      status: .matches,
      message: .expectedTo("be equal")
    )
  }
}

fileprivate func PrettyPrintedFailureResult(
  actual: String?,
  message: ExpectationMessage
) -> PredicateResult {
  if let actual = actual {
    print ("Actual Document:")
    print(actual)
  }
  return PredicateResult(
    status: .fail,
    message: message
  )
}

extension String {
  fileprivate func lines(startingAt startLine: Int) -> ArraySlice<String>? {
    let allLines = self.components(separatedBy: "\n")
    guard allLines.count >= startLine else { return nil }
    return allLines[(startLine - 1)..<allLines.endIndex]
  }
}

/// Compares line-by-line between the contents of a file and a received string
/// NOTE: Will trim whitespace from the file since Xcode auto-adds a newline
///
/// - Parameters:
///   - received: The string received from the test
///   - expectedFileURL: The file URL to the file with the expected contents of the received string
///   - trimImports: If imports at the top of the file should be trimmed before the comparison.
///                  Defaults to `false`.
public func equalLineByLine(
  toFileAt expectedFileURL: URL,
  trimmingImports trimImports: Bool = false
) -> Predicate<String> {
  return Predicate.define() { actual in
    guard FileManager.default.apollo.doesFileExist(atPath: expectedFileURL.path) else {
      return PredicateResult(
        status: .fail,
        message: .fail("File not found at \(expectedFileURL)")
      )
    }

    var fileContents = try String(contentsOf: expectedFileURL)
    if trimImports {
      fileContents = fileContents
        .components(separatedBy: "\n")
        .filter { !$0.hasPrefix("import ") }
        .joined(separator: "\n")
    }

    let expected = fileContents.trimmingCharacters(in: .whitespacesAndNewlines)

    return try equalLineByLine(expected).satisfies(actual)
  }
}
