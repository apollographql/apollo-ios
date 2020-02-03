import Foundation

/// A helper for building out multi-part form data for upload
public class MultipartFormData {

  enum FormDataError: Error, LocalizedError {
    case encodingStringToDataFailed(_ string: String)

    var errorDescription: String? {
      switch self {
      case .encodingStringToDataFailed(let string):
        return "Could not encode \"\(string)\" as .utf8 data."
      }
    }
  }

  /// A Carriage Return Line Feed character, which will be seen as a newline on both unix and Windows servers.
  static let CRLF = "\r\n"

  let boundary: String

  private var bodyParts: [BodyPart]

  /// Designated initializer
  ///
  /// - Parameter boundary: The boundary to use between parts of the form.
  public init(boundary: String) {
    self.boundary = boundary
    self.bodyParts = []
  }

  /// Convenience initializer which uses a pre-defined boundary
  public convenience init() {
    self.init(boundary: "apollo-ios.boundary.\(UUID().uuidString)")
  }

  /// Appends the passed-in string as a part of the body.
  ///
  /// - Parameters:
  ///   - string: The string to append
  ///   - name: The name of the part to pass along to the server
  public func appendPart(string: String, name: String) throws {
    self.appendPart(data: try self.encode(string: string),
                    name: name,
                    contentType: nil)
  }

  /// Appends the passed-in data as a part of the body.
  ///
  /// - Parameters:
  ///   - data: The data to append
  ///   - name: The name of the part to pass along to the server
  ///   - contentType: [optional] The content type of this part. Defaults to nil.
  ///   - filename: [optional] The name of the file for this part. Defaults to nil.
  public func appendPart(data: Data,
                         name: String,
                         contentType: String? = nil,
                         filename: String? = nil) {
    let inputStream = InputStream(data: data)
    let contentLength = UInt64(data.count)

    self.appendPart(inputStream: inputStream,
                    contentLength: contentLength,
                    name: name,
                    contentType: contentType,
                    filename: filename)
  }

  /// Appends the passed-in input stream as a part of the body.
  ///
  /// - Parameters:
  ///   - inputStream: The input stream to append.
  ///   - contentLength: Length of the input stream data.
  ///   - name: The name of the part to pass along to the server
  ///   - contentType: [optional] The content type of this part. Defaults to nil.
  ///   - filename: [optional] The name of the file for this part. Defaults to nil.
  public func appendPart(inputStream: InputStream,
                         contentLength: UInt64,
                         name: String,
                         contentType: String? = nil,
                         filename: String? = nil) {
    self.bodyParts.append(BodyPart(name: name,
                                   inputStream: inputStream,
                                   contentLength: contentLength,
                                   contentType: contentType,
                                   filename: filename))
  }

  /// Encodes everything into the final form data to send to a server.
  ///
  /// - Returns: The final form data to send to a server.
  func encode() throws -> Data {
    var data = Data()

    for p in self.bodyParts {
      data.append(try self.encode(bodyPart: p))
    }

    data.append(try self.encode(string: "--".appending(self.boundary.appending("--"))))

    return data
  }

  private func encode(bodyPart: BodyPart) throws -> Data {
    var encoded = Data()

    encoded.append(try self.encode(string: "--\(self.boundary)\(MultipartFormData.CRLF)"))
    encoded.append(try self.encode(string: bodyPart.headers()))
    encoded.append(self.encode(inputStream: bodyPart.inputStream, length: bodyPart.contentLength))
    encoded.append(try self.encode(string: "\(MultipartFormData.CRLF)"))

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

  private func encode(string: String) throws -> Data {
    guard let encodedData = string.data(using: .utf8, allowLossyConversion: false) else {
      throw FormDataError.encodingStringToDataFailed(string)
    }

    return encodedData
  }
}

/// MARK: - BodyPart

/// A structure representing a single part of multi-part form data.
fileprivate struct BodyPart {
  let name: String
  let inputStream: InputStream
  let contentLength: UInt64
  let contentType: String?
  let filename: String?

  init(name: String,
       inputStream: InputStream,
       contentLength: UInt64,
       contentType: String?,
       filename: String?) {
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
