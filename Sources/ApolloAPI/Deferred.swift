public protocol Deferrable: SelectionSet { }

/// Wraps a deferred selection set (either an inline fragment or fragment spread) to expose the
/// fulfilled value as well as the fulfilled state through the projected value.
@propertyWrapper
public struct Deferred<Fragment: Deferrable> {
  public enum State: Equatable {
    /// The deferred selection set has not been received yet.
    case pending
    /// The deferred value can never be fulfilled, such as in the case of a type case mismatch.
    case notExecuted
    /// The deferred value has been received.
    case fulfilled(Fragment)
  }

  @_spi(Unsafe)
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
