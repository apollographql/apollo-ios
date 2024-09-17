import Foundation

extension JSONSerialization {

  /// Uses `sortedKeys` to create a stable representation of JSON objects.
  ///
  /// - Parameter object: The object to serialize
  /// - Returns: The serialized data
  /// - Throws: Errors related to the serialization of data.
  static func sortedData(withJSONObject object: Any) throws -> Data {
    return try self.data(withJSONObject: object, options: [.sortedKeys])
  }
}
