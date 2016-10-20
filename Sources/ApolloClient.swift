import Foundation

public protocol Cancellable {
    func cancel()
}

public class ApolloClient {
  let networkTransport: NetworkTransport

  public init(networkTransport: NetworkTransport) {
    self.networkTransport = networkTransport
  }

  public convenience init(url: URL) {
    self.init(networkTransport: HTTPNetworkTransport(url: url))
  }

  public func fetch<Query: GraphQLQuery>(query: Query, queue: DispatchQueue = DispatchQueue.main, completionHandler: @escaping GraphQLOperationResponseHandler<Query>) -> Cancellable {
    return networkTransport.send(operation: query) { (result, error) in
      queue.async {
        completionHandler(result, error)
      }
    }
  }

  public func perform<Mutation: GraphQLMutation>(mutation: Mutation, queue: DispatchQueue = DispatchQueue.main, completionHandler: @escaping GraphQLOperationResponseHandler<Mutation>) -> Cancellable {
    return networkTransport.send(operation: mutation) { (result, error) in
      queue.async {
        completionHandler(result, error)
      }
    }
  }
}
