import Foundation

extension HTTPURLResponse {
  var isSuccessful: Bool {
    return (200..<300).contains(statusCode)
  }

  var statusCodeDescription: String {
    return HTTPURLResponse.localizedString(forStatusCode: statusCode)
  }

  var textEncoding: String.Encoding? {
    guard let encodingName = textEncodingName else { return nil }

    return String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encodingName as CFString)))
  }
}

public protocol Matchable {
  associatedtype Base
  static func ~=(pattern: Self, value: Base) -> Bool
}

func isNil(_ value: Any) -> Bool {
  // We can't compare a non-optional Any with nil, so we have to use reflection as a workaround
  
  let mirror = Mirror(reflecting: value)
  
  if mirror.displayStyle != .optional {
    return false
  }
  
  if mirror.children.isEmpty {
    return true
  } else {
    // Recurse to deal with nested optionals
    return isNil(mirror.children.first!.value)
  }
}
