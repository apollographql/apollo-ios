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

  @discardableResult public func fetch<Query: GraphQLQuery>(query: Query, queue: DispatchQueue = DispatchQueue.main, completionHandler: @escaping (GraphQLResult<Query.Data>?, Error?) -> Void) -> Cancellable {
    return perform(operation: query, completionHandler: completionHandler)
  }
  
  @discardableResult public func perform<Mutation: GraphQLMutation>(mutation: Mutation, queue: DispatchQueue = DispatchQueue.main, completionHandler: @escaping (GraphQLResult<Mutation.Data>?, Error?) -> Void) -> Cancellable {
    return perform(operation: mutation, completionHandler: completionHandler)
  }

  private func perform<Operation: GraphQLOperation>(operation: Operation, queue: DispatchQueue = DispatchQueue.main, completionHandler: @escaping (GraphQLResult<Operation.Data>?, Error?) -> Void) -> Cancellable {
    return networkTransport.send(operation: operation) { (response, error) in
      guard let response = response else {
        queue.async {
          completionHandler(nil, error)
        }
        return
      }
      
      do {
        let result = try response.parseResult()
        queue.async {
          completionHandler(result, nil)
        }
      } catch {
        queue.async {
          completionHandler(nil, error)
        }
      }
    }
  }
}
