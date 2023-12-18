#if !COCOAPODS
import ApolloAPI
#endif

protocol SubscriptableByPathComponent {
  subscript(path: [PathComponent]) -> AnyHashable? { get }
  func value(at path: PathComponent) -> AnyHashable?
}

extension SubscriptableByPathComponent {
  subscript(path: [PathComponent]) -> AnyHashable? {
    get {
      switch path.headAndTail() {
      case nil: return nil

      case let (head, remaining)? where remaining.isEmpty:
        return value(at: head)

      case let (head, remaining)?:
        guard let value = value(at: head) else { return nil }

        switch value {
        case let dict as DataDict:
          return dict[remaining]

        case let array as [AnyHashable]:
          return array[remaining]

        default:
          return nil
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
      #warning("Should this be a preconditionFailure?")
      // This is invalid for DataDict since it cannot return an array element directly from _data.
      // It would need to be a field lookup first and then the indexed element on the value.
      return nil
    }
  }
}

extension Array: SubscriptableByPathComponent where Element == AnyHashable {
  func value(at path: PathComponent) -> AnyHashable? {
    switch path {
    case .field:
      #warning("Should this be a preconditionFailure?")
      // This is invalid for an Array since it is not indexed by String.
      return nil

    case let .index(index):
      return self[index]
    }
  }
}

fileprivate extension Array where Element == PathComponent {
  func headAndTail() -> (head: PathComponent, tail: [PathComponent])? {
    guard !isEmpty else { return nil }

    var tail = self
    let head = tail.removeFirst()

    return (head, tail)
  }
}
