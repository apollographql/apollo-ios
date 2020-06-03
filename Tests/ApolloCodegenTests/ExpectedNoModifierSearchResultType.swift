import Foundation

enum NoModifierSearchResultType: RawRepresentable, Codable, Equatable, Hashable, CaseIterable {
  typealias RawValue = String

  case Human
  case Droid
  case Starship
  /// Type which is a member of `NoModifierSearchResultType` not defined at the time this enum was generated
  case __unknown(String)

  var rawValue: String {
    switch self {
    case .Human: return "Human"
    case .Droid: return "Droid"
    case .Starship: return "Starship"
    case .__unknown(let value): return value
    }
  }

  init(rawValue: String) {
    switch rawValue {
    case "Human": self = .Human
    case "Droid": self = .Droid
    case "Starship": self = .Starship
    default: self = .__unknown(rawValue)
    }
  }

  static var allCases: [NoModifierSearchResultType] {
    [
      .Human,
      .Droid,
      .Starship,
    ]
  }
}
