@propertyWrapper
public struct Field<T: Cacheable> {

  let key: StaticString

  private var _enclosingInstance: Unmanaged<Object>!
  private var enclosingInstance: Object { _enclosingInstance.takeUnretainedValue() }

  public init(_ field: StaticString) {
    self.key = field
  }

  public mutating func _link(to enclosingInstance: Unmanaged<Object>) {
    self._enclosingInstance = enclosingInstance
  }

  public var wrappedValue: T? {
    get {
      let instance = enclosingInstance
      guard let data = instance.data[key.description] else {
        return nil
      }

      do {
        let value = try T.value(with: data, in: instance._transaction)
        try replace(data: data, with: value, on: instance)
        return value

      } catch {
        instance._transaction.log(error)
        return nil
      }
    } set {
      let instance = enclosingInstance
      do {
//
//      switch newValue {
//      case .none: // TODO
//      case is ScalarType:
        try instance.set(value: newValue, forKey: key)
//      case let object as Object:
//
//
//
//      default:
//        break // TODO
//      }
      } catch let error as CacheError.Reason {
        let error = CacheError(
          reason: error,
          type: .write,
          field: key.description,
          object: instance
        )
        instance._transaction.log(error)

      } catch {
        instance._transaction.log(error)
      }
    }
  }

  private func replace(
    data: Any,
    with parsedValue: T,
    on instance: Object
  ) throws {
    /// Only need to do this for Object, Enums, and custom scalars.
    /// DO NOT DO THIS when value is a CacheInterface ON a CacheInterface instance
    /// For ScalarTypes, its redundant
    /// TODO: Write tests for this.
    switch (parsedValue) {
    case is Object where !(data is Object),
      is Interface,
      is CustomScalarType:
      try instance.set(value: parsedValue, forKey: key)
      // TODO: This should not trigger objects to become dirty.

    case is Interface, is ScalarType: break
    default: break
    }
  }

}
