/// A protocol that can be added to the ``SchemaConfiguration`` in order to provide custom field policy configuration.
///
/// This protocol should be applied to your existing ``SchemaConfiguration`` and provides a way to provide custom
/// field policy cache keys in lieu of using the @fieldPolicy directive.
public protocol FieldPolicyProvider {
  /// The entry point for resolving a cache key to read an object from the `NormalizedCache` for a field
  /// that returns a single object.
  /// 
  /// - Parameters:
  ///   - field: The ``Selection.Field`` of the operation being executed.
  ///   - variables: Optional ``GraphQLOperation.Variables`` input values provided to the operation.
  ///   - path: The ``ResponsePath`` representing the path within operation to get to the given field.
  /// - Returns: A ``CacheKeyInfo`` describing the computed cache key.
  static func cacheKey(for field: Selection.Field, variables: GraphQLOperation.Variables?, path: ResponsePath) -> CacheKeyInfo?
  
  /// The entry point for resolving cache keys to read objects from the `NormalizedCache` for a field
  /// that returns a list of objects.
  ///
  /// - Parameters:
  ///   - field: The ``Selection.Field`` of the operation being executed.
  ///   - variables: Optional ``GraphQLOperation.Variables`` input values provided to the operation.
  ///   - path: The ``ResponsePath`` representing the path within operation to get to the given field.
  /// - Returns: An array of ``CacheKeyInfo`` describing the computed cache keys.
  static func cacheKeyList(for listField: Selection.Field, variables: GraphQLOperation.Variables?, path: ResponsePath) -> [CacheKeyInfo]?
}
