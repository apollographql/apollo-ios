public class MultipartFormData {
  
  public static let CRLF = "\r\n"
  
  public let boundary: String
  
  private var bodyParts: [BodyPart]
  
  public init() {
    self.boundary = "apollo-ios.boundary.\(UUID().uuidString)"
    self.bodyParts = []
  }
  
  struct BodyPart {
    let name: String
    let data: Data
    let contentType: String?
    let filename: String?
    
    init(name: String, data: Data, contentType: String?, filename: String?) {
      self.name = name
      self.data = data
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
  
  public func appendPartWithString(string: String, name: String) {
    self.appendPart(data: self.encode(string: string), name: name, contentType: nil)
  }
  
  public func appendPart(data: Data, name: String, contentType: String? = nil, filename: String? = nil) {
    self.bodyParts.append(BodyPart(name: name, data: data, contentType: contentType, filename: filename))
  }
  
  public func toData() -> Data {
    let data = NSMutableData()
    
    for p in self.bodyParts {
      data.append(self.encode(string: "--\(self.boundary)\(MultipartFormData.CRLF)"))
      data.append(self.encode(string: p.headers()))
      data.append(p.data)
      data.append(self.encode(string: "\(MultipartFormData.CRLF)\(MultipartFormData.CRLF)"))
    }
    
    data.append(self.encode(string: "--".appending(self.boundary.appending("--"))))
    
    return data as Data
  }
  
  private func encode(string: String) -> Data {
    return string.data(using: String.Encoding.utf8, allowLossyConversion: false)!
  }
}
