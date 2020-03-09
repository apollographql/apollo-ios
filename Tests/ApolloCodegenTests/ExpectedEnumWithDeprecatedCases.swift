/// An enum with deprecated cases
public enum EnumWithDeprecatedCases: RawRepresentable, Codable, Equatable, Hashable, CaseIterable {
  public typealias RawValue = String

  /// This value is not deprecated
  case notDeprecated
  @available(*, deprecated, message: "Deprecated in schema")
  /// This value is deprecated
  case isDeprecated
  /// An EnumWithDeprecatedCases type not defined at the time this enum was generated
  case __unknown(String)

  public var rawValue: String {
    switch self {
    case .notDeprecated: return "notDeprecated"
    case .isDeprecated: return "isDeprecated"
    case .__unknown(let value): return value
    }
  }

  public init(rawValue: String) {
    switch rawValue {
    case "notDeprecated": self = .notDeprecated
    case "isDeprecated": self = .isDeprecated
    default: self = .__unknown(rawValue)
    }
  }

  public static var allCases: [EnumWithDeprecatedCases] {
    [
      .notDeprecated,
      .isDeprecated,
    ]
  }
}
