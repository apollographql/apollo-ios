class MultipartFormData {

  static let CRLF = "\r\n"

  let boundary: String

  private var bodyParts: [BodyPart]

  init(boundary: String) {
    self.boundary = boundary
    self.bodyParts = []
  }

  convenience init() {
    self.init(boundary: "apollo-ios.boundary.\(UUID().uuidString)")
  }

  struct BodyPart {
    let name: String
    let inputStream: InputStream
    let contentLength: UInt64
    let contentType: String?
    let filename: String?

    init(name: String, inputStream: InputStream, contentLength: UInt64, contentType: String?, filename: String?) {
      self.name = name
      self.inputStream = inputStream
      self.contentLength = contentLength
      self.contentType = contentType
      self.filename = filename
    }

    func headers() -> String {
      var headers = "Content-Disposition: form-data; name=\"\(self.name)\""
      if let filename = self.filename {
        headers += "; filename=\"\(filename)\""
      }
      headers += "\(MultipartFormData.CRLF)"

      if let contentType = self.contentType {
        headers += "Content-Type: \(contentType)\(MultipartFormData.CRLF)"
      }

      headers += "\(MultipartFormData.CRLF)"

      return headers
    }
  }

  func appendPart(string: String, name: String) {
    self.appendPart(data: self.encode(string: string), name: name, contentType: nil)
  }

  func appendPart(data: Data, name: String, contentType: String? = nil, filename: String? = nil) {
    let inputStream = InputStream(data: data)
    let contentLength = UInt64(data.count)

    self.appendPart(inputStream: inputStream, contentLength: contentLength, name: name, contentType: contentType, filename: filename)
  }

  func appendPart(inputStream: InputStream, contentLength: UInt64, name: String, contentType: String? = nil, filename: String? = nil) {
    self.bodyParts.append(BodyPart(name: name, inputStream: inputStream, contentLength: contentLength, contentType: contentType, filename: filename))
  }

  func encode() -> Data {
    var data = Data()

    for p in self.bodyParts {
      data.append(self.encode(bodyPart: p))
    }

    data.append(self.encode(string: "--".appending(self.boundary.appending("--"))))

    return data
  }
  
  private func encode(bodyPart: BodyPart) -> Data {
    var encoded = Data()

    encoded.append(self.encode(string: "--\(self.boundary)\(MultipartFormData.CRLF)"))
    encoded.append(self.encode(string: bodyPart.headers()))
    encoded.append(self.encode(inputStream: bodyPart.inputStream, length: bodyPart.contentLength))
    encoded.append(self.encode(string: "\(MultipartFormData.CRLF)"))

    return encoded
  }

  private func encode(inputStream: InputStream, length: UInt64) -> Data {
    inputStream.open()
    defer { inputStream.close() }

    var encoded = Data()

    while (inputStream.hasBytesAvailable) {
      var buffer = [UInt8](repeating: 0, count: 1024)
      let bytesRead = inputStream.read(&buffer, maxLength: 1024)

      if inputStream.streamError != nil {
        return encoded
      }

      if bytesRead > 0 {
        encoded.append(buffer, count: bytesRead)
      } else {
        break
      }
    }

    return encoded
  }

  private func encode(string: String) -> Data {
    return string.data(using: .utf8, allowLossyConversion: false)!
  }
}
