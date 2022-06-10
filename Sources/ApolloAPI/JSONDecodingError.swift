import Foundation

public enum JSONDecodingError: Error, LocalizedError, Equatable {
  case missingValue
  case nullValue
  case wrongType
  case couldNotConvert(value: AnyHashable, to: Any.Type)

  public var errorDescription: String? {
    switch self {
    case .missingValue:
      return "Missing value"
    case .nullValue:
      return "Unexpected null value"
    case .wrongType:
      return "Wrong type"
    case .couldNotConvert(let value, let expectedType):
      return "Could not convert \"\(value)\" to \(expectedType)"
    }
  }

  public static func == (lhs: JSONDecodingError, rhs: JSONDecodingError) -> Bool {
    switch (lhs, rhs) {
    case (.missingValue, .missingValue),
      (.nullValue, .nullValue),
      (.wrongType, .wrongType):
      return true

    case let (.couldNotConvert(value: lhsValue, to: lhsType),
              .couldNotConvert(value: rhsValue, to: rhsType)):
      return lhsValue == rhsValue && lhsType == rhsType

    default:
      return false
    }
  }
}
