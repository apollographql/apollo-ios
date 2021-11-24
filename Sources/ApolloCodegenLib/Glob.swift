import Foundation

private extension String {
  static let Globstar: String = "**"

  var includesGlobstar: Bool {
    return self.contains(Self.Globstar)
  }
}

/// A path pattern matcher.
struct Glob {
  /// The pattern to match paths for.
  let pattern: String

  private let flags = GLOB_ERR | GLOB_MARK | GLOB_BRACE | GLOB_TILDE

  /// An error object that indicates why pattern matching failed.
  public enum Error: Swift.Error, LocalizedError {
    case noSpace // GLOB_NOSPACE
    case aborted // GLOB_ABORTED
    case enumeration(path: String)
    case unknown(code: Int)

    public var errorDescription: String? {
      switch self {
      case .noSpace: return "Malloc call failed" // From Darwin.POSIX.glob
      case .aborted: return "Unignored error" // From Darwin.POSIX.glob
      case .enumeration(let path): return "Cannot enumerate \(path)"
      case .unknown(let code): return "Unknown error: \(code)"
      }
    }
  }

  /// The designated initializer
  ///
  /// - Parameters:
  ///  - pattern: The pattern to match paths for.
  init(_ pattern: String) {
    self.pattern = pattern
  }

  /// Executes the pattern match on the underlying file system.
  ///
  /// - Returns: A set of matched file paths.
  func match() throws -> Set<String> {
    var paths: Set<String> = []

    let patterns: Set<String> = pattern.includesGlobstar ? try expandGlobstar() : [pattern]
    for pattern in patterns {
      paths = paths.union(try matches(for: pattern))
    }

    return paths
  }

  private func matches(for pattern: String) throws -> Set<String> {
    var globT = glob_t()

    defer {
      globfree(&globT)
    }

    let response = glob(pattern, flags, nil, &globT)

    switch response {
    case 0: break // SUCCESS
    case GLOB_NOMATCH: return []
    case GLOB_NOSPACE: throw Error.noSpace
    case GLOB_ABORTED: throw Error.aborted
    default: throw Error.unknown(code: Int(response))
    }

    return Set<String>((0..<Int(globT.gl_matchc)).compactMap({ index in
      if let path = String(validatingUTF8: globT.gl_pathv[index]!) {
        return path
      }

      return nil
    }))
  }

  #warning("TODO - should we support negation in globstar with braces?") // something like "{a/**/*,!a/b/c/*}

  /// Expands the globstar (`**`) to find all directory paths to search for the match pattern.
  ///
  /// - Returns: A set of directory file paths expanded with the match pattern.
  func expandGlobstar() throws -> Set<String> {
    guard pattern.contains("**") else { return [pattern] }

    var parts = pattern.components(separatedBy: String.Globstar)
    let firstPart = parts.removeFirst()
    let lastPart = parts.joined(separator: String.Globstar)

    let fileManager = FileManager.default
    let searchPath = firstPart.isEmpty ? fileManager.currentDirectoryPath : firstPart
    var directories: Set<String> = [searchPath] // include files at the globstar root directory

    do {
      let searchURL = URL(fileURLWithPath: searchPath)
      let resourceKeys: [URLResourceKey] = [.isDirectoryKey]
      var enumeratorError: Swift.Error?

      let errorHandler: ((URL, Swift.Error) -> Bool) = { url, error in
        enumeratorError = error
        return false // aborts enumeration
      }

      guard let enumerator = fileManager.enumerator(
        at: searchURL,
        includingPropertiesForKeys: resourceKeys,
        errorHandler: errorHandler)
      else {
        throw Error.enumeration(path: searchPath)
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
}
