import Apollo

public struct MockInterceptorProvider: InterceptorProvider {
  let interceptors: [ApolloInterceptor]

  public init(_ interceptors: [ApolloInterceptor]) {
    self.interceptors = interceptors
  }

  public func interceptors<Operation>(for operation: Operation) -> [ApolloInterceptor] {
    self.interceptors
  }
}
