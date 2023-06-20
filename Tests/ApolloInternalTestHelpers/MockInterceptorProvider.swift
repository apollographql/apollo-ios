import Apollo

public struct MockInterceptorProvider: InterceptorProvider {
  let interceptors: [any ApolloInterceptor]

  public init(_ interceptors: [any ApolloInterceptor]) {
    self.interceptors = interceptors
  }

  public func interceptors<Operation>(for operation: Operation) -> [any ApolloInterceptor] {
    self.interceptors
  }
}
