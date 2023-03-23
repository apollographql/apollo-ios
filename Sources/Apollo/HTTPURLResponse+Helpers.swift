import Foundation

extension HTTPURLResponse {
  var isSuccessful: Bool {
    return (200..<300).contains(statusCode)
  }

  var statusCodeDescription: String {
    return HTTPURLResponse.localizedString(forStatusCode: statusCode)
  }

  var isMultipart: Bool {
    return (allHeaderFields["Content-Type"] as? String)?.contains("multipart/mixed") ?? false
  }

  var multipartBoundary: String? {
    guard let contentType = allHeaderFields["Content-Type"] as? String else { return nil }

    let marker = "boundary="
    let markerLength = marker.count

    for component in contentType.components(separatedBy: ";") {
      let directive = component.trimmingCharacters(in: .whitespaces)
      if directive.prefix(markerLength) == marker {
        if let markerEndIndex = directive.firstIndex(of: "=") {
          var startIndex = directive.index(markerEndIndex, offsetBy: 1)
          if directive[startIndex] == "\"" {
            startIndex = directive.index(after: startIndex)
          }
          var endIndex = directive.index(before: directive.endIndex)
          if directive[endIndex] == "\"" {
            endIndex = directive.index(before: endIndex)
          }

          return String(directive[startIndex...endIndex])
        }
      }
    }

    return nil
  }
}
