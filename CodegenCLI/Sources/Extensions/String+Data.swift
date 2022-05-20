import Foundation
import ArgumentParser

extension String {
#warning("needs tests")
  func asData() throws -> Data {
    guard let data = self.data(using: .utf8) else {
      throw ValidationError("Badly encoded string, should be UTF-8!")
    }

    return data
  }
}
