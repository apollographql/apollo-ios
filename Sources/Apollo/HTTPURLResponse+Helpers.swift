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

    for directive in contentType.components(separatedBy: ";") {
      if directive.prefix(markerLength) == marker {
        if let markerEndIndex = directive.firstIndex(of: "=") {
          let startIndex = directive.index(markerEndIndex, offsetBy: 2)
          let endIndex = directive.index(before: directive.endIndex)

          return String(directive[startIndex..<endIndex])
        }
      }
    }

    return nil
  }
}
