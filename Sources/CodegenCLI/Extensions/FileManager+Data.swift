import Foundation

extension FileManager {
  /// Returns the contents of the file at the specified path or throws an error.
  func unwrappedContents(atPath path: String) throws -> Data {
    guard let data = contents(atPath: path) else {
      throw Error(errorDescription: "Cannot read file at \(path)")
    }

    return data
  }
}
