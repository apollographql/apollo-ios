/// A property wrapper that indicates if a `Bool` value was ever set to `true`.
/// Defaults to `false`, if ever set to `true`, it will always be `true`.
@propertyWrapper
public struct IsEverTrue {
  private var _wrappedValue: Bool = false

  public var wrappedValue: Bool {
    get { _wrappedValue }
    set { if newValue { _wrappedValue = true } }
  }

  public init() {}
}
