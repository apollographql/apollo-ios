public enum SelectionSetType<S: GraphQLSchema> {
  case ObjectType(S.ObjectType)
  case Interface(S.Interface)
  case Union(S.Union)
}

public protocol AnySelectionSet: ResponseObject {
  static var selections: [Selection] { get }
}

public protocol SelectionSet: ResponseObject, Equatable {

  associatedtype Schema: GraphQLSchema

  /// The GraphQL type for the `SelectionSet`.
  ///
  /// This may be a concrete type (`ConcreteType`) or an abstract type (`Interface`).
  static var __parentType: SelectionSetType<Schema> { get }
}

extension SelectionSet {

  var __objectType: Schema.ObjectType { Schema.ObjectType(rawValue: __typename) ?? .unknownCase }

  var __typename: String { data["__typename"] }

  /// Verifies if a `SelectionSet` may be converted to a different `SelectionSet` and performs
  /// the conversion.
  ///
  /// - Warning: This function is not supported for use outside of generated call sites.
  /// Generated call sites are guaranteed by the GraphQL compiler to be safe.
  /// Unsupported usage may result in unintended consequences including crashes.
  func _asType<T: SelectionSet>() -> T? where T.Schema == Schema {
    guard case let __objectType = __objectType, __objectType != .unknownCase else { return nil }

    switch T.__parentType {
    case .ObjectType(let type):
      guard __objectType == type else { return nil }

    case .Interface(let interface):
      guard __objectType.implements(interface) else { return nil }

    case .Union(let union):
      guard union.possibleTypes.contains(__objectType) else { return nil }
    }

    return T.init(data: data)
  }
}

func ==<T: SelectionSet>(lhs: T, rhs: T) -> Bool {
  return true // TODO: Unit test & implement this
}

public protocol ResponseObject {
  var data: ResponseDict { get }

  init(data: ResponseDict)
}

extension ResponseObject {

  /// Converts a `SelectionSet` to a `Fragment` given a generic fragment type.
  ///
  /// - Warning: This function is not supported for use outside of generated call sites.
  /// Generated call sites are guaranteed by the GraphQL compiler to be safe.
  /// Unsupported usage may result in unintended consequences including crashes.
  func _toFragment<T: Fragment>() -> T {
    return T.init(data: data)
  }
}
