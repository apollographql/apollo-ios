/// An enum with two cases with the same letters but different cases
public enum EnumWithDifferentCases: RawRepresentable, Codable, Equatable, Hashable, CaseIterable {
  public typealias RawValue = String

  /// A camelCase case name
  case caseName
  /// An UPPERCASE case name
  case CASENAME
  /// An EnumWithDifferentCases type not defined at the time this enum was generated
  case __unknown(String)

  public var rawValue: String {
    switch self {
    case .caseName: return "caseName"
    case .CASENAME: return "CASENAME"
    case .__unknown(let value): return value
    }
  }

  public init(rawValue: String) {
    switch rawValue {
    case "caseName": self = .caseName
    case "CASENAME": self = .CASENAME
    default: self = .__unknown(rawValue)
    }
  }

  public static var allCases: [EnumWithDifferentCases] {
    [
      .caseName,
      .CASENAME,
    ]
  }
}
