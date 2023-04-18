protocol GraphQLExecutionSource {
  /// The type that represents each object in data from the source.
  associatedtype ObjectData

  associatedtype FieldCollector: FieldSelectionCollector<ObjectData>

  /// Resolves the value for a field value for a field.
  ///
  /// - Returns: The value for the field represented by the `info` on the `object`.
  ///  For a field with a scalar value, this should be a raw JSON value.
  ///  For fields whose type is an object, this should be of the source's `ObjectData` type or
  ///  a `CacheReference` that can be resolved by the source.
  static func resolveField(
    with info: FieldExecutionInfo,
    on object: ObjectData
  ) -> AnyHashable?
}
