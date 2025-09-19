public enum FieldPolicy {
  
  /// A protocol that can be added to the ``SchemaConfiguration`` in order to provide custom field policy configuration.
  ///
  /// This protocol should be applied to your existing ``SchemaConfiguration`` and provides a way to provide custom
  /// field policy cache keys in lieu of using the @fieldPolicy directive.
  public protocol Provider {
    /// The entry point for resolving a cache key to read an object from the `NormalizedCache` for a field
    /// that returns a single object.
    ///
    /// - Parameters:
    ///   - field: The ``FieldPolicy.Field`` of the operation being executed.
    ///   - inputData: The ``FieldPolicy.InputData`` representing the arguments and variables for the operation being executed.
    ///   - path: The ``ResponsePath`` representing the path within operation to get to the given field.
    /// - Returns: A ``CacheKeyInfo`` describing the computed cache key.
    static func cacheKey(
      for field: Field,
      inputData: InputData,
      path: ResponsePath
    ) -> CacheKeyInfo?
    
    /// The entry point for resolving cache keys to read objects from the `NormalizedCache` for a field
    /// that returns a list of objects.
    ///
    /// - Parameters:
    ///   - field: The ``FieldPolicy.Field`` of the operation being executed.
    ///   - inputData: The ``FieldPolicy.InputData`` representing the arguments and variables for the operation being executed.
    ///   - path: The ``ResponsePath`` representing the path within operation to get to the given field.
    /// - Returns: An array of ``CacheKeyInfo`` describing the computed cache keys.
    static func cacheKeyList(
      for listField: Field,
      inputData: InputData,
      path: ResponsePath
    ) -> [CacheKeyInfo]?
  }
  
  public struct Field {
    public let name: String
    public let alias: String?
    public let type: Selection.Field.OutputType
    
    public var responseKey: String {
      return alias ?? name
    }
    
    public init(
      name: String,
      alias: String?,
      type: Selection.Field.OutputType
    ) {
      self.name = name
      self.alias = alias
      self.type = type
    }
    
    public init(_ selectionField: Selection.Field) {
      self.name = selectionField.name
      self.alias = selectionField.alias
      self.type = selectionField.type
    }
  }
  
}
