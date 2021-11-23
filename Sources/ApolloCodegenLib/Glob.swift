import Foundation

private extension String {
  var includesGlobstar: Bool {
    return self.contains("**")
  }
}

struct Glob {
  let pattern: String
  private let flags = GLOB_ERR | GLOB_MARK | GLOB_BRACE | GLOB_TILDE

  public enum Error: Swift.Error, LocalizedError {
    case noSpace // GLOB_NOSPACE
    case aborted // GLOB_ABORTED
    case unknown(code: Int)

    public var errorDescription: String? {
      switch self {
      case .noSpace: return "Malloc call failed"
      case .aborted: return "Unignored error"
      case .unknown(let code): return "Unknown error: \(code)"
      }
    }
  }

  init(_ pattern: String) {
    self.pattern = pattern
  }

    var paths: [String] = []
  func match() throws -> [String] {

    let patterns = pattern.includesGlobstar ? expandGlobstar(pattern) : [pattern]
    for pattern in patterns {
      paths.append(contentsOf: try matches(for: pattern))
    }

    return paths
  }

  func expandGlobstar(_ pattern: String) -> [String] {
    guard pattern.contains("**") else { return [pattern] }

    return []
  }

  private func matches(for pattern: String) throws -> [String] {
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

    return (0..<Int(globT.gl_matchc)).compactMap { index in
      if let path = String(validatingUTF8: globT.gl_pathv[index]!) {
        return path
      }

      return nil
    }
  }
}
