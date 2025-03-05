import Foundation
#if !COCOAPODS
import ApolloMigrationAPI
#endif

public enum JSONConverter {
  
  /// Converts a ``SelectionSet`` into a basic JSON dictionary for use.
  ///
  /// - Returns: A `[String: Any]` JSON dictionary representing the ``SelectionSet``.
  public static func convert(_ selectionSet: some SelectionSet) -> [String: Any] {
    selectionSet.__data._data.mapValues(convert(value:))
  }

  static func convert(_ dataDict: DataDict) -> [String: Any] {
    dataDict._data.mapValues(convert(value:))
  }

  /// Converts a ``GraphQLResult`` into a basic JSON dictionary for use.
  ///
  /// - Returns: A `[String: Any]` JSON dictionary representing the ``GraphQLResult``.
  public static func convert<T>(_ result: GraphQLResult<T>) -> [String: Any] {
    result.asJSONDictionary()
  }

  /// Converts a ``GraphQLError`` into a basic JSON dictionary for use.
  ///
  /// - Returns: A `[String: Any]` JSON dictionary representing the ``GraphQLError``.
  public static func convert(_ error: GraphQLError) -> [String: Any] {
    var dict: [String: Any] = [:]
    if let message = error["message"] { dict["message"] = message }
    if let locations = error["locations"] { dict["locations"] = locations }
    if let path = error["path"] { dict["path"] = path }
    if let extensions = error["extensions"] { dict["extensions"] = extensions }
    return dict
  }

  private static func convert(value: Any) -> Any {
      var val: Any = value
      if let value = value as? DataDict {
          val = value._data
      } else if let value = value as? any CustomScalarType {
          val = value._jsonValue
      }
      if let dict = val as? [String: Any] {
          return dict.mapValues(convert)
      } else if let arr = val as? [Any] {
          return arr.map(convert)
      }
      return val
  }
}
