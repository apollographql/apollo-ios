import Foundation

extension String {
  func asData() throws -> Data {
    guard let data = data(using: .utf8) else {
      throw Error(errorDescription: "Badly encoded string, should be UTF-8!")
    }

    return data
  }
}
