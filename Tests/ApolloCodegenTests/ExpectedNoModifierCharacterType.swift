import Foundation

enum NoModifierCharacterType: RawRepresentable, Codable, Equatable, Hashable, CaseIterable {
  typealias RawValue = String

  case Human
  case Droid
  case Alien
  /// Type conforming to `NoModifierCharacterType` not defined at the time this enum was generated
  case __unknown(String)

  var rawValue: String {
    switch self {
    case .Human: return "Human"
    case .Droid: return "Droid"
    case .Alien: return "Alien"
    case .__unknown(let value): return value
    }
  }

  init(rawValue: String) {
    switch rawValue {
    case "Human": self = .Human
    case "Droid": self = .Droid
    case "Alien": self = .Alien
    default: self = .__unknown(rawValue)
    }
  }

  static var allCases: [NoModifierCharacterType] {
    [
      .Human,
      .Droid,
      .Alien,
    ]
  }
}

