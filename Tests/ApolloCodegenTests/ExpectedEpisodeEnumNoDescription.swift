public enum EpisodeWithoutDescription: RawRepresentable, Codable, Equatable, Hashable, CaseIterable {
  public typealias RawValue = String

  case NEWHOPE
  case EMPIRE
  case JEDI
  /// An EpisodeWithoutDescription type not defined at the time this enum was generated
  case __unknown(String)

  public var rawValue: String {
    switch self {
    case .NEWHOPE: return "NEWHOPE"
    case .EMPIRE: return "EMPIRE"
    case .JEDI: return "JEDI"
    case .__unknown(let value): return value
    }
  }

  public init(rawValue: String) {
    switch rawValue {
    case "NEWHOPE": self = .NEWHOPE
    case "EMPIRE": self = .EMPIRE
    case "JEDI": self = .JEDI
    default: self = .__unknown(rawValue)
    }
  }

  public static var allCases: [EpisodeWithoutDescription] {
    [
      .NEWHOPE,
      .EMPIRE,
      .JEDI,
    ]
  }
}
