#if !COCOAPODS
import ApolloAPI
#endif

@propertyWrapper
public struct Field<T> {

  let key: StaticString

  public init(_ field: StaticString) {
    self.key = field
  }

  public var wrappedValue: Self {
    get { self }
    set { preconditionFailure() }
  }

}
