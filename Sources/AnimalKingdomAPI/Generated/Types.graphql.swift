// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public enum SkinCovering: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case fur
  case hair
  case feathers
  case scales
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "FUR": self = .fur
      case "HAIR": self = .hair
      case "FEATHERS": self = .feathers
      case "SCALES": self = .scales
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .fur: return "FUR"
      case .hair: return "HAIR"
      case .feathers: return "FEATHERS"
      case .scales: return "SCALES"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: SkinCovering, rhs: SkinCovering) -> Bool {
    switch (lhs, rhs) {
      case (.fur, .fur): return true
      case (.hair, .hair): return true
      case (.feathers, .feathers): return true
      case (.scales, .scales): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [SkinCovering] {
    return [
      .fur,
      .hair,
      .feathers,
      .scales,
    ]
  }
}

public enum RelativeSize: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case large
  case average
  case small
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "LARGE": self = .large
      case "AVERAGE": self = .average
      case "SMALL": self = .small
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .large: return "LARGE"
      case .average: return "AVERAGE"
      case .small: return "SMALL"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: RelativeSize, rhs: RelativeSize) -> Bool {
    switch (lhs, rhs) {
      case (.large, .large): return true
      case (.average, .average): return true
      case (.small, .small): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [RelativeSize] {
    return [
      .large,
      .average,
      .small,
    ]
  }
}
