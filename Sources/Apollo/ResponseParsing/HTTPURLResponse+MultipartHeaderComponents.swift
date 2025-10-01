import Foundation

// MARK: Multipart extensions
extension HTTPURLResponse {
  /// Returns true if the `Content-Type` HTTP header contains the `multipart/mixed` MIME type.
  var isMultipart: Bool {
    return (allHeaderFields["Content-Type"] as? String)?.contains("multipart/mixed") ?? false
  }

  struct MultipartHeaderComponents {
    let media: String?
    let boundary: String?
    let `protocol`: String?

    init(media: String?, boundary: String?, protocol: String?) {
      self.media = media
      self.boundary = boundary
      self.protocol = `protocol`
    }
  }

  /// Components of the `Content-Type` header specifically related to the `multipart` media type.
  var multipartHeaderComponents: MultipartHeaderComponents {
    guard let contentType = allHeaderFields["Content-Type"] as? String else {
      return MultipartHeaderComponents(media: nil, boundary: nil, protocol: nil)
    }

    var media: String? = nil
    var boundary: String? = nil
    var `protocol`: String? = nil

    for component in contentType.components(separatedBy: ";") {
      let directive = component.trimmingCharacters(in: .whitespaces)

      if directive.starts(with: "multipart/") {
        media = directive.components(separatedBy: "/").last
        continue
      }

      if directive.starts(with: "boundary=") {
        if let markerEndIndex = directive.firstIndex(of: "=") {
          var startIndex = directive.index(markerEndIndex, offsetBy: 1)
          if directive[startIndex] == "\"" {
            startIndex = directive.index(after: startIndex)
          }
          var endIndex = directive.index(before: directive.endIndex)
          if directive[endIndex] == "\"" {
            endIndex = directive.index(before: endIndex)
          }

          boundary = String(directive[startIndex...endIndex])
        }
        continue
      }

      if directive.contains("Spec=") {
        `protocol` = directive
        continue
      }
    }

    return MultipartHeaderComponents(media: media, boundary: boundary, protocol: `protocol`)
  }
}

