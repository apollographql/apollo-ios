import Foundation

private extension String {
  static let Globstar: String = "**"

  var includesGlobstar: Bool {
    return self.contains(Self.Globstar)
  }
}

/// A path pattern matcher.
public struct Glob {
  let pattern: String

  // GLOB_ERR - Return on error
  // GLOB_MARK - Append / to matching directories
  // GLOB_NOSORT - Don't sort
  // GLOB_BRACE - Expand braces ala csh
  // GLOB_TILDE - Expand tilde names from the passwd file
  private let flags = GLOB_ERR | GLOB_MARK | GLOB_NOSORT | GLOB_BRACE | GLOB_TILDE

  /// An error object that indicates why pattern matching failed.
  public enum MatchError: Error, LocalizedError {
    case noSpace // GLOB_NOSPACE
    case aborted // GLOB_ABORTED
    case cannotEnumerate(path: String)
    case unknown(code: Int)

    public var errorDescription: String? {
      switch self {
      case .noSpace: return "Malloc call failed" // From Darwin.POSIX.glob
      case .aborted: return "Unignored error" // From Darwin.POSIX.glob
      case .cannotEnumerate(let path): return "Cannot enumerate \(path)"
      case .unknown(let code): return "Unknown error: \(code)"
      }
    }
  }

  /// The designated initializer
  ///
  /// - Parameters:
  ///  - pattern: A comma-delimited string of path matching patterns.
  ///
  /// Each path matching pattern can include the following characters:
  /// - `*` matches zero or more characters in a single path portion, eg: `*.graphql`
  /// - `?` matches one character in a single path portion, eg: `file-?.graphql`
  /// - `**` includes zero or more directories and subdirectories searching for matches, eg: `**/*.graphql`
  /// - `!` excludes any match, eg: `a/*.graphql,!a/file.graphql`
  init(_ pattern: String) {
    self.pattern = pattern
  }

  /// Executes the pattern match on the underlying file system.
  ///
  /// - Returns: A set of matched file paths.
  func match() throws -> Set<String> {
    let paths: Set<String> = try expand(self.pattern)

    var matches: Set<String> = []
    for path in paths {
      matches.formUnion(try self.matches(for: path))
    }

    return matches
  }

  /// Separates a comma-delimited string into paths, expanding any globstars, removing duplicates and negated path patterns.
  private func expand(_ pattern: String) throws -> Set<String> {
    // The ordered nature of an array is important here because we process negatives (!) in the
    // order which they appear in the pattern.
    let components: [String] = pattern.components(separatedBy: ",").compactMap({
      let trimmed = $0.trimmingCharacters(in: .whitespacesAndNewlines)
      return trimmed.isEmpty ? nil : trimmed
    })

    var paths: Set<String> = []
    for item in components {
      let expanded: Set<String> = item.includesGlobstar ? try expandGlobstar(item) : [item]

      if item.first == "!" {
        paths.subtract(expanded)
      } else {
        paths.formUnion(expanded)
      }
    }

    return paths
  }

  /// Expands the globstar (`**`) to find all directory paths to search for the match pattern.
  private func expandGlobstar(_ pattern: String) throws -> Set<String> {
    guard pattern.contains("**") else { return [pattern] }

    var parts = pattern.components(separatedBy: String.Globstar)
    let firstPart = parts.removeFirst()
    let lastPart = parts.joined(separator: String.Globstar)

    let fileManager = FileManager.default
    let searchPath = firstPart.isEmpty ? fileManager.currentDirectoryPath : firstPart
    var directories: Set<String> = [searchPath] // include searching the globstar root directory

    do {
      let searchURL = URL(fileURLWithPath: searchPath)
      let resourceKeys: [URLResourceKey] = [.isDirectoryKey]
      var enumeratorError: Error?

      let errorHandler: ((URL, Error) -> Bool) = { url, error in
        enumeratorError = error
        return false // aborts enumeration
      }

      guard let enumerator = fileManager.enumerator(
        at: searchURL,
        includingPropertiesForKeys: resourceKeys,
        errorHandler: errorHandler)
      else {
        throw MatchError.cannotEnumerate(path: searchPath)
      }

      if let enumeratorError = enumeratorError { throw enumeratorError }

      for case (let url as URL) in enumerator {
        guard
          let resourceValues = try? url.resourceValues(forKeys: Set(resourceKeys)),
          let isDirectory = resourceValues.isDirectory,
          isDirectory == true
        else { continue }

        directories.insert(url.path)
      }

    } catch(let error) {
      throw(error)
    }

    return Set<String>(directories.compactMap({ directory in
      URL(fileURLWithPath: directory).appendingPathComponent(lastPart).standardizedFileURL.path
    }))
  }

  /// Performs the underlying file system path matching.
  private func matches(for pattern: String) throws -> Set<String> {
    var globT = glob_t()

    defer {
      globfree(&globT)
    }

    let response = glob(pattern, flags, nil, &globT)

    switch response {
    case 0: break // SUCCESS
    case GLOB_NOMATCH: return []
    case GLOB_NOSPACE: throw MatchError.noSpace
    case GLOB_ABORTED: throw MatchError.aborted
    default: throw MatchError.unknown(code: Int(response))
    }

    return Set<String>((0..<Int(globT.gl_matchc)).compactMap({ index in
      if let path = String(validatingUTF8: globT.gl_pathv[index]!) {
        return path
      }

      return nil
    }))
  }
}
