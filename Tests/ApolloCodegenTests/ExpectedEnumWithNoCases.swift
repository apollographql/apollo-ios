public enum EnumWithoutCases: RawRepresentable, Codable, Equatable, Hashable, CaseIterable {
  public typealias RawValue = String

  /// An EnumWithoutCases type not defined at the time this enum was generated
  case __unknown(String)

  public var rawValue: String {
    switch self {
    case .__unknown(let value): return value
    }
  }

  public init(rawValue: String) {
    switch rawValue {
    default: self = .__unknown(rawValue)
    }
  }

  public static var allCases: [EnumWithoutCases] {
    [
    ]
  }
}
