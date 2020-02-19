import Foundation

extension StaticString {
  
  var apollo_lastPathComponent: String {
    return (self.apollo_toString as NSString).lastPathComponent
  }
  
  var apollo_toString: String {
    return self.withUTF8Buffer {
        String(decoding: $0, as: UTF8.self)
    }
  }
}
