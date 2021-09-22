@propertyWrapper
public struct Field<T: Cacheable> {

  let field: StaticString

  public init(_ field: StaticString) {
    self.field = field
  }

  public static subscript<E: ObjectType>(
    _enclosingInstance instance: E,
    wrapped wrappedKeyPath: ReferenceWritableKeyPath<E, T?>,
    storage storageKeyPath: ReferenceWritableKeyPath<E, Self>
  ) -> T? {
    get {
      let wrapper = instance[keyPath: storageKeyPath]
      let field = wrapper.field.description
      guard let data = instance.data[field] else {
        return nil
      }

      do {
        let value = try T.value(with: data, in: instance._transaction)
        try wrapper.replace(data: data, with: value, on: instance)
        return value

      } catch {
        instance._transaction.log(error)
        return nil
      }
    }
    set {
      let wrapper = instance[keyPath: storageKeyPath]
      let field = wrapper.field.description
      do {
//
//      switch newValue {
//      case .none: // TODO
//      case is ScalarType:
        try instance.set(value: newValue, forField: wrapper)
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
          field: field,
          object: object(for: instance)
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
    on instance: ObjectType
  ) throws {
    /// Only need to do this for Object, Enums, and custom scalars.
    /// DO NOT DO THIS when value is a CacheInterface ON a CacheInterface instance
    /// For ScalarTypes, its redundant
    /// TODO: Write tests for this.
    switch (parsedValue) {
    case is Object where !(data is Object),
         is Interface where instance is Object,
         is CustomScalarType:
      try instance.set(value: parsedValue, forField: self)
    // TODO: This should not trigger objects to become dirty.

//    case let interface as Interface where instance is Interface:
//      try instance.set(value: object, forField: self)
//      break // TODO

    case is Interface, is ScalarType: break
    default: break
    }
  }

  private static func object(for instance: ObjectType) -> Object {
    switch instance {
    case let object as Object: return object
    case let interface as Interface: return interface.object

    default: fatalError("AnyCacheObject can only be an Object or a Interface.")
    }
  }

//  public var projectedValue: CacheField { self }

  @available(*, unavailable,
  message: "This property wrapper can only be applied to ObjectType."
  )
  public var wrappedValue: T? { get { fatalError() } set { fatalError() } }
}
