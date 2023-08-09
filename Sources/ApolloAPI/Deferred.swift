@propertyWrapper
public struct Deferred<Fragment: SelectionSet> {
  public enum State {
    case pending
    case fulfilled(Fragment)
  }

  public init(_dataDict: DataDict) {
    __data = _dataDict
  }

  public var state: State {
    guard __data._fulfilledFragments.contains(ObjectIdentifier(Fragment.self)) else {
      return .pending
    }
    return .fulfilled(Fragment.init(_dataDict: __data))
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
