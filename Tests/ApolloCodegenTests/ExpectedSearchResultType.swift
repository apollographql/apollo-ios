import Foundation

public enum SearchResultType: RawRepresentable, Codable, Equatable, Hashable, CaseIterable {
  public typealias RawValue = String

  case Human
  case Droid
  case Starship
  /// Type which is a member of `SearchResultType` not defined at the time this enum was generated
  case __unknown(String)

  public var rawValue: String {
    switch self {
    case .Human: return "Human"
    case .Droid: return "Droid"
    case .Starship: return "Starship"
    case .__unknown(let value): return value
    }
  }

  public init(rawValue: String) {
    switch rawValue {
    case "Human": self = .Human
    case "Droid": self = .Droid
    case "Starship": self = .Starship
    default: self = .__unknown(rawValue)
    }
  }

  public static var allCases: [SearchResultType] {
    [
      .Human,
      .Droid,
      .Starship,
    ]
  }
}
