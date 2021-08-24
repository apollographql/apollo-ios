@testable import Apollo

protocol TestConfig {
  func network(store: ApolloStore) -> NetworkTransport
}

class DefaultConfig: TestConfig {

  func transport(with store: ApolloStore) -> NetworkTransport {
    let provider = DefaultInterceptorProvider(store: store)
    return RequestChainNetworkTransport(interceptorProvider: provider,
                                        endpointURL: TestServerURL.starWarsServer.url)
  }

  func network(store: ApolloStore) -> NetworkTransport {
    return transport(with: store)
  }
}

class APQsConfig: TestConfig {

  func transport(with store: ApolloStore) -> NetworkTransport {
    let provider = DefaultInterceptorProvider(store: store)
    return RequestChainNetworkTransport(interceptorProvider: provider,
                                        endpointURL: TestServerURL.starWarsServer.url,
                                        autoPersistQueries: true)
  }

  func network(store: ApolloStore) -> NetworkTransport {
    return transport(with: store)
  }
}

class APQsWithGetMethodConfig: TestConfig {

  func transport(with store: ApolloStore) -> NetworkTransport {
    let provider = DefaultInterceptorProvider(store: store)
    return RequestChainNetworkTransport(interceptorProvider: provider,
                                        endpointURL: TestServerURL.starWarsServer.url,
                                        autoPersistQueries: true,
                                        useGETForPersistedQueryRetry: true)
  }

  func network(store: ApolloStore) -> NetworkTransport {
    return transport(with: store)
  }
}
