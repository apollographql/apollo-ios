import Foundation

public enum ArgumentError: Error, LocalizedError {
  case invalidTargetName(name: String)
  case invalidPackageType(name: String)

  public var errorDescription: String? {
    switch self {
    case let .invalidTargetName(name):
      return "The target \"\(name)\" is invalid. Please try again."

    case let .invalidPackageType(name):
      return "The package type \"\(name)\" is invalid. Please try again."
    }
  }
}
