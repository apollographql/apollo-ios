import ApolloAPI

@propertyWrapper
public struct Field<T>: Sendable {

  let key: StaticString

  public init(_ field: StaticString) {
    self.key = field
  }

  public var wrappedValue: Self {
    get { self }
    set { preconditionFailure() }
  }

}
