import Foundation

public enum NoCasesCharacterType: RawRepresentable, Codable, Equatable, Hashable, CaseIterable {
  public typealias RawValue = String

  /// Type conforming to `NoCasesCharacterType` not defined at the time this enum was generated
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

  public static var allCases: [NoCasesCharacterType] {
    [
    ]
  }
}
