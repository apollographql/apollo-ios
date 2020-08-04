import Foundation

public enum SanitizedCharacterType: RawRepresentable, Codable, Equatable, Hashable, CaseIterable {
  public typealias RawValue = String

  case `case`
  case `self`
  case `Type`
  case `Protocol`
  /// Type conforming to `SanitizedCharacterType` not defined at the time this enum was generated
  case __unknown(String)

  public var rawValue: String {
    switch self {
    case .case: return "case"
    case .`self`: return "self"
    case .`Type`: return "Type"
    case .`Protocol`: return "Protocol"
    case .__unknown(let value): return value
    }
  }

  public init(rawValue: String) {
    switch rawValue {
    case "case": self = .case
    case "self": self = .`self`
    case "Type": self = .`Type`
    case "Protocol": self = .`Protocol`
    default: self = .__unknown(rawValue)
    }
  }

  public static var allCases: [SanitizedCharacterType] {
    [
      .case,
      .`self`,
      .`Type`,
      .`Protocol`,
    ]
  }
}
