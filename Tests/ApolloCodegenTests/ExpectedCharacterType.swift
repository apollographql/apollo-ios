import Foundation

public enum CharacterType: RawRepresentable, Codable, Equatable, Hashable, CaseIterable {
  public typealias RawValue = String

  case Human
  case Droid
  case Alien
  /// Type conforming to `CharacterType` not defined at the time this enum was generated
  case __unknown(String)

  public var rawValue: String {
    switch self {
    case .Human: return "Human"
    case .Droid: return "Droid"
    case .Alien: return "Alien"
    case .__unknown(let value): return value
    }
  }

  public init(rawValue: String) {
    switch rawValue {
    case "Human": self = .Human
    case "Droid": self = .Droid
    case "Alien": self = .Alien
    default: self = .__unknown(rawValue)
    }
  }

  public static var allCases: [CharacterType] {
    [
      .Human,
      .Droid,
      .Alien,
    ]
  }
}
