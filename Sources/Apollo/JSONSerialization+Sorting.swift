import Foundation

extension JSONSerialization {

  /// Uses `sortedKeys` to create a stable representation of JSON objects when the operating system supports it.
  ///
  /// - Parameter object: The object to serialize
  /// - Returns: The serialized data
  /// - Throws: Errors related to the serialization of data.
  static func dataSortedIfPossible(withJSONObject object: Any) throws -> Data {
    // The `sortedKeys` option is not available on all platforms we
    // presently support, but we should use it where we can in
    // order to get stable JSON representations, especially if being
    // used in queries.
    if #available(iOS 11, macOS 10.13, watchOS 4, tvOS 11, *) {
      return try self.data(withJSONObject: object, options: [.sortedKeys])
    } else {
      return try self.data(withJSONObject: object)
    }
  }

  /// Wrapper function so we don't have to scatter `if #available` all over the codebase to see if data can be sorted.
  static func dataCanBeSorted() -> Bool {
    if #available(iOS 11, macOS 10.13, watchOS 4, tvOS 11, *) {
      return true
    } else {
      return false
    }
  }
}
