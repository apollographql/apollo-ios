import Foundation
import Apollo

public struct PackageOne {
  public private(set) var text = "Hello, World!"

  let client: ApolloClient

  public init() {
    let store = ApolloStore(cache: InMemoryNormalizedCache())
    let interceptorProvider = DefaultInterceptorProvider(store: store)
    let networkTransport = RequestChainNetworkTransport(
      interceptorProvider: interceptorProvider,
      endpointURL: URL(string: "http://localhost:4000/graphql")!
    )

    self.client = ApolloClient(networkTransport: networkTransport, store: store)
  }
}
