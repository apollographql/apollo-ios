import Foundation
import OrderedCollections

private extension String {
  static let Globstar: String = "**"

  var includesGlobstar: Bool {
    return self.contains(Self.Globstar)
  }

  var isExclude: Bool {
    return self.first == "!"
  }

  var containsExclude: Bool {
    return self.contains("!")
  }
}

/// A path pattern matcher.
public struct Glob {
  let patterns: [String]
  let rootURL: URL?

  // GLOB_ERR - Return on error
  // GLOB_MARK - Append / to matching directories
  // GLOB_NOSORT - Don't sort
  // GLOB_TILDE - Expand tilde names from the passwd file
  private let flags = GLOB_ERR | GLOB_MARK | GLOB_NOSORT | GLOB_TILDE | GLOB_BRACE

  /// An error object that indicates why pattern matching failed.
  public enum MatchError: Error, LocalizedError, Equatable {
    case noSpace // GLOB_NOSPACE
    case aborted // GLOB_ABORTED
    case cannotEnumerate(path: String)
    case invalidExclude(path: String)
    case unknown(code: Int)

    public var errorDescription: String? {
      switch self {
      case .noSpace: return "Malloc call failed" // From Darwin.POSIX.glob
      case .aborted: return "Unignored error" // From Darwin.POSIX.glob
      case .cannotEnumerate(let path): return "Cannot enumerate \(path)"
      case .invalidExclude(let path): return "Exclude paths must start with '!' - \(path)"
      case .unknown(let code): return "Unknown error: \(code)"
      }
    }
  }

  /// The designated initializer
  ///
  /// - Parameters:
  ///  - pattern: An array of path matching pattern strings.
  ///  - rootURL: The rootURL to search for the patterns relative to. If `nil` searches
  ///    the process's current working directory.
  ///
  /// Each path matching pattern can include the following characters:
  /// - `*` matches everything but the directory separator (shallow), eg: `*.graphql`
  /// - `?` matches any single character, eg: `file-?.graphql`
  /// - `**` matches all subdirectories (deep), eg: `**/*.graphql`
  /// - `!` excludes any match only if the pattern starts with a `!` character, eg: `!file.graphql`
  ///
  /// - Discussion:
  ///
  init(_ patterns: [String], relativeTo rootURL: URL? = nil) {
    self.patterns = patterns
    self.rootURL = rootURL
  }

  /// Executes the pattern match on the underlying file system.
  ///
  /// - Returns: A set of matched file paths.
  func match(excludingDirectories excluded: [String]? = nil) throws -> OrderedSet<String> {
    let expandedPatterns = try expand(self.patterns, excludingDirectories: excluded)

    var includeMatches: [String] = []
    var excludeMatches: [String] = []

    for pattern in expandedPatterns {
      if pattern.isExclude {
        let patternMatches = try matches(for: String(pattern.dropFirst()))
        excludeMatches.append(contentsOf: patternMatches)

      } else {
        let patternMatches = try matches(for: pattern)
        includeMatches.append(contentsOf: patternMatches)
      }
    }

    // Resolve symlinks in any included paths
    includeMatches = includeMatches.compactMap({ path in
      return URL(fileURLWithPath: path).resolvingSymlinksInPath().path
    })
    return OrderedSet<String>(includeMatches).subtracting(excludeMatches)
  }

  /// Separates a comma-delimited string into paths, expanding any globstars and removes duplicates.
  private func expand(
    _ patterns: [String],
    excludingDirectories excluded: [String]?
  ) throws -> OrderedSet<String> {
    var paths: OrderedSet<String> = []
    for pattern in patterns {
      if pattern.containsExclude && !pattern.isExclude {
        // glob and fnmatch do support ! being used elsewhere in the path match pattern but for the
        // purposes of Glob we reserve it exclusively for the exclude pattern and it is required to
        // be the first character otherwise we throw.
        throw MatchError.invalidExclude(path: pattern)
      }

      paths.formUnion(try expand(pattern, excludingDirectories: excluded))
    }

    return paths
  }

  /// Expands `pattern` including any globstar character (`**`) to find all directory paths to
  /// search for the match pattern and removes duplicates.
  private func expand(
    _ pattern: String,
    excludingDirectories excluded: [String]?
  ) throws -> OrderedSet<String> {
    guard pattern.includesGlobstar else {
      return [URL(fileURLWithPath: pattern, relativeTo: rootURL).path]
    }

    CodegenLogger.log("Expanding globstar \(pattern)", logLevel: .debug)

    let isExclude = pattern.isExclude
    var parts = pattern.components(separatedBy: String.Globstar)
    var firstPart = parts.removeFirst()
    let lastPart = parts.joined(separator: String.Globstar)

    if isExclude {
      // Remove ! here otherwise the Linux glob function would not return any results. Results for
      // the exclude path match patterns are needed because match() manually handles exclusion.
      firstPart = String(firstPart.dropFirst())
    }

    let fileManager = FileManager.default

    let searchURL: URL = {
      if firstPart.isEmpty || firstPart == "./" {
        return rootURL ?? URL(fileURLWithPath: fileManager.currentDirectoryPath)
      } else {
        return URL(fileURLWithPath: firstPart, relativeTo: rootURL)
      }
    }()

    var directories: [URL] = [searchURL] // include searching the globstar root directory

    do {
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
        throw MatchError.cannotEnumerate(path: searchURL.path)
      }

      if let enumeratorError = enumeratorError { throw enumeratorError }

      var excludedSet: Set<String> = []
      if let excluded = excluded {
        excludedSet = Set<String>(excluded)
      }

      for case (let url as URL) in enumerator {
        guard
          let resourceValues = try? url.resourceValues(forKeys: Set(resourceKeys)),
          let isDirectory = resourceValues.isDirectory,
          isDirectory == true,
          excludedSet.intersection(url.pathComponents).isEmpty
        else { continue }

        directories.append(url)
      }

    } catch(let error) {
      throw(error)
    }

    return OrderedSet<String>(directories.compactMap({ directory in
      var path = directory.appendingPathComponent(lastPart).standardizedFileURL.path
      if isExclude {
        path.insert("!", at: path.startIndex)
      }

      CodegenLogger.log("Expanded to \(path)", logLevel: .debug)

      return path
    }))
  }

  /// Performs the underlying file system path matching.
  private func matches(for pattern: String) throws -> [String] {
    var globT = glob_t()

    defer {
      globfree(&globT)
    }

    CodegenLogger.log("Evaluating \(pattern)", logLevel: .debug)

    let response = glob(pattern, flags, nil, &globT)

    switch response {
    case 0: break // SUCCESS
    case GLOB_NOMATCH: return []
    case GLOB_NOSPACE: throw MatchError.noSpace
    case GLOB_ABORTED: throw MatchError.aborted
    default: throw MatchError.unknown(code: Int(response))
    }

    return (0..<Int(globT.gl_matchc)).compactMap({ index in
      if let path = String(validatingUTF8: globT.gl_pathv[index]!) {
        CodegenLogger.log("Matched \(path)", logLevel: .debug)
        return path
      }

      return nil
    })
  }
}
