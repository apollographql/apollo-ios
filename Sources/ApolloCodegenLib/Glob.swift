import Foundation

struct Glob {
  public let pattern: String

  enum Error: Swift.Error, LocalizedError {
    case noSpace // GLOB_NOSPACE
    case aborted // GLOB_ABORTED
    case unknown(code: Int)

    var errorDescription: String? {
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

  public func paths() throws -> [String] {
    var globT = glob_t()

    defer {
      globfree(&globT)
    }

    let flags = GLOB_ERR | GLOB_MARK | GLOB_BRACE | GLOB_TILDE
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
