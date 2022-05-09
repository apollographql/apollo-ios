import ApolloAPI

@propertyWrapper
public struct Field<T: Cacheable> {

  let key: StaticString

  public init(_ field: StaticString) {
    self.key = field
  }

//  public static subscript<E>(
//    _enclosingInstance instance: E,
//    wrapped wrappedKeyPath: ReferenceWritableKeyPath<E, T?>,
//    storage storageKeyPath: ReferenceWritableKeyPath<E, Self>
//  ) -> T? {
//    get {
//      let property = instance[keyPath: storageKeyPath]
//      let key = property.key
//      guard let data = instance.data[key.description] else {
//        return nil
//      }
//
//      do {
//        let value = try T.value(with: data, in: instance._transaction)
//        try property.replace(data: data, with: value, on: instance._object)
//        return value
//
//      } catch {
//        instance._transaction.log(error)
//        return nil
//      }
//    } set {
//      let property = instance[keyPath: storageKeyPath]
//      let key = property.key
//      do {
////
////      switch newValue {
////      case .none: // TODO
////      case is ScalarType:
//        try instance._object.set(value: newValue, forKey: key)
////      case let object as Object:
////
////
////
////      default:
////        break // TODO
////      }
//      } catch let error as CacheError.Reason {
//        let error = CacheError(
//          reason: error,
//          type: .write,
//          field: key.description,
//          object: instance
//        )
//        instance._transaction.log(error)
//
//      } catch {
//        instance._transaction.log(error)
//      }
//    }
//  }
//
//  private func replace(
//    data: Any,
//    with parsedValue: T,
//    on object: Object
//  ) throws {
//    /// Only need to do this for Object, Enums, and custom scalars.
//    /// DO NOT DO THIS when value is a CacheInterface ON a CacheInterface instance
//    /// For ScalarTypes, its redundant
//    /// TODO: Write tests for this.
//    switch (parsedValue) {
//    case is Object where !(data is Object),
//      is Interface,
//      is CustomScalarType:
//      try object.set(value: parsedValue, forKey: key)
//      // TODO: This should not trigger objects to become dirty.
//
//    case is Interface, is ScalarType: break
//    default: break
//    }
//  }


  @available(*, unavailable,
  message: "This property wrapper can only be applied to ObjectType."
  )
  public var wrappedValue: T? {
    get { preconditionFailure() }
    set { preconditionFailure() }
  }

  public var projectedValue: StaticString {
    key
  }

}
