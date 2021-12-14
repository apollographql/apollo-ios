import Foundation
import Nimble
import ApolloCodegenTestSupport

/// A Nimble matcher that compares two strings line-by-line.
public func equalLineByLine(_ expectedValue: String) -> Predicate<String> {
  return Predicate.define() { actual in
    guard let actualLines = try actual.evaluate()?.components(separatedBy: "\n") else {
      return PredicateResult(
        status: .fail,
        message: .expectedActualValueTo("equal <\(expectedValue)>")
      )
    }

    var actualLinesBuffer: [String] = actualLines.reversed()
    let expectedLines = expectedValue.components(separatedBy: "\n")

    for (index, expectedLine) in expectedLines.enumerated() {
      guard let actualLine = actualLinesBuffer.popLast() else {
        return PredicateResult(
          status: .fail,
          message: .fail("Expected \(expectedLines.count), actual ended at line \(index).")
        )
      }

      if actualLine != expectedLine {
        return PredicateResult(
          status: .fail,
          message: .fail("Line \(index + 1) did not match. Expected \"\(expectedLine)\", got \"\(actualLine)\".")
        )
      }
    }

    return PredicateResult(
      status: .matches,
      message: .expectedTo("be equal")
    )
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
