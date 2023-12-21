#if !COCOAPODS
import ApolloAPI
#endif

/// Enables subscript syntax to be used where the subscript is an array of `PathComponent` values
/// typically returned in a GraphQL response.
protocol SubscriptableByPathComponent {
  subscript(path: [PathComponent]) -> AnyHashable? { get set }
  func value(at path: PathComponent) -> AnyHashable?
  mutating func set(value: AnyHashable?, at path: PathComponent)
}

extension SubscriptableByPathComponent {
  subscript(path: [PathComponent]) -> AnyHashable? {
    get {
      switch path.headAndTail() {
      case nil:
        return nil

      case let (head, remaining)? where remaining.isEmpty:
        return value(at: head)

      case let (head, remaining)?:
        switch value(at: head) {
        case let dict as DataDict:
          return dict[remaining]

        case let array as [AnyHashable?]:
          return array[remaining]

        default:
          return nil
        }
      }
    }
    set {
      switch path.headAndTail() {
      case nil:
        return

      case let (head, remaining)? where remaining.isEmpty:
        set(value: newValue, at: head)

      case let (head, remaining)?:
        switch value(at: head) {
        case var dict as DataDict:
          dict[remaining] = newValue
          set(value: dict, at: head)

        case var array as [AnyHashable?]:
          array[remaining] = newValue
          set(value: array, at: head)

        default:
          return
        }
      }
    }
  }
}

extension DataDict: SubscriptableByPathComponent {
  func value(at path: PathComponent) -> AnyHashable? {
    switch path {
    case let .field(field):
      return self._data[field]

    case .index:
      // TODO: Should this throw, be a preconditionFailure, or just swallow the error?
      return nil
    }
  }

  mutating func set(value: AnyHashable?, at path: PathComponent) {
    switch path {
    case let .field(field):
      self._data[field] = value

    case .index:
      // TODO: Should this throw, be a preconditionFailure, or just swallow the error?
      return
    }
  }
}

extension Array: SubscriptableByPathComponent where Element == AnyHashable? {
  func value(at path: PathComponent) -> AnyHashable? {
    switch path {
    case .field:
      // TODO: Should this throw, be a preconditionFailure, or just swallow the error?
      return nil

    case let .index(index):
      return self[index]
    }
  }

  mutating func set(value: AnyHashable?, at path: PathComponent) {
    switch path {
    case .field:
      // TODO: Should this throw, be a preconditionFailure, or just swallow the error?
      return

    case let .index(index):
      self[index] = value
    }
  }
}

/// Splits the first `PathComponent` element returning the first element and an array of all
/// remaining elements.
extension Array where Element == PathComponent {
  fileprivate func headAndTail() -> (head: PathComponent, tail: [PathComponent])? {
    guard !isEmpty else { return nil }

    var tail = self
    let head = tail.removeFirst()

    return (head, tail)
  }
}
