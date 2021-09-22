public protocol ResponseObject {
  var data: ResponseDict { get }

  init(data: ResponseDict)
}

extension ResponseObject {

  public init(json: JSONObject) {
    self.init(data: ResponseDict(json))
  }

  #warning("TODO: Audit all _ prefixed things to see if they should be available using ApolloExtension.")
  public func _toJSONObject() -> JSONObject {
    data.data
  }

  /// Converts a `SelectionSet` to a `Fragment` given a generic fragment type.
  ///
  /// - Warning: This function is not supported for use outside of generated call sites.
  /// Generated call sites are guaranteed by the GraphQL compiler to be safe.
  /// Unsupported usage may result in unintended consequences including crashes.
  func _toFragment<T: Fragment>() -> T {
    return T.init(data: data)
  }
}
