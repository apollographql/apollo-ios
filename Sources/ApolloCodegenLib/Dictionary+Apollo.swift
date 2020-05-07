import Foundation

public extension Dictionary where Key: RawRepresentable, Key.RawValue == String, Value: Any {
  
  /// Transforms a dictionary keyed by a String enum into a dictionary keyed by the
  /// string values of that enum.
  var apollo_toStringKeyedDict: [String: Any] {
    var updatedDict = [String: Any]()
    for (_, (key, value)) in self.enumerated() {
      updatedDict[key.rawValue] = value
    }
    return updatedDict
  }
}
