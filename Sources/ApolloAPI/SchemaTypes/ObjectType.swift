public protocol ObjectType: Cacheable {
  var _transaction: CacheTransaction { get }
  var data: [String: Any] { get }

  func set<T: Cacheable>(value: T?, forField field: Field<T>) throws
}
