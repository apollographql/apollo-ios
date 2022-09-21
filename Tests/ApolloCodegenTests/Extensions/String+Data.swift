import Foundation

extension String {
  var asData: Data { self.data(using: .utf8)! }
}

extension Data {
  var asString: String { String(data: self, encoding: .utf8)! }
}
