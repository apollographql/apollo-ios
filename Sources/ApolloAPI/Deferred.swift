public protocol Deferrable: SelectionSet { }

@propertyWrapper
public struct Deferred<Fragment: Deferrable> {
  public enum State {
    case pending
    case notExecuted
    case fulfilled(Fragment)
  }

  public init(_dataDict: DataDict) {
    __data = _dataDict
  }

  public var state: State {
    let fragment = ObjectIdentifier(Fragment.self)
    if __data._fulfilledFragments.contains(fragment) {
      return .fulfilled(Fragment.init(_dataDict: __data))
    }
    else if __data._deferredFragments.contains(fragment) {
      return .pending
    } else {
      return .notExecuted
    }
  }

  private let __data: DataDict
  public var projectedValue: State { state }
  public var wrappedValue: Fragment? {
    guard case let .fulfilled(value) = state else {
      return nil
    }
    return value
  }
}
