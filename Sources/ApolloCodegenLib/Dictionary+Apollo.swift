import Foundation
import ApolloCore

public extension ApolloExtension where Base: DictionaryType, Base.KeyType: RawRepresentable, Base.KeyType.RawValue == String, Base.ValueType: Any {

  /// Transforms a dictionary keyed by a String enum into a dictionary keyed by the
  /// string values of that enum.
  var toStringKeyedDict: [String: Any] {
    var updatedDict = [String: Any]()
    for (_, (key, value)) in base.underlying.enumerated() {
      updatedDict[key.rawValue] = value
    }
    return updatedDict
  }
}
