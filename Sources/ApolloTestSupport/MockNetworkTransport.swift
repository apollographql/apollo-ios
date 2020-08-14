@testable import Apollo
import Dispatch

public final class MockNetworkTransport: NetworkTransport {
  public var body: JSONObject

  public var clientName = "MockNetworkTransport"
  public var clientVersion = "mock_version"
  
  public init(body: JSONObject) {
    self.body = body
  }

  public func send<Operation: GraphQLOperation>(operation: Operation, completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation.Data>, Error>) -> Void) -> Cancellable {
    DispatchQueue.global(qos: .default).async {
      completionHandler(.success(GraphQLResponse(operation: operation, body: self.body)))
    }
    return MockTask()
  }
  
  public func sendForResult<Operation>(operation: Operation, completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable where Operation : GraphQLOperation {
    DispatchQueue.global(qos: .default).async {
      let response = GraphQLResponse(operation: operation, body: self.body)
      do {
        let result = try response.parseResultFast()
        completionHandler(.success(result))
      } catch {
        completionHandler(.failure(error))
      }
    }
    
    return MockTask()
  }
}

extension MockNetworkTransport: UploadingNetworkTransport {
  
  public func upload<Operation>(operation: Operation, files: [GraphQLFile], completionHandler: @escaping (Result<GraphQLResponse<Operation.Data>, Error>) -> Void) -> Cancellable where Operation : GraphQLOperation {
    return self.send(operation: operation, completionHandler: completionHandler)
  }
  
  public func uploadForResult<Operation>(operation: Operation, files: [GraphQLFile], completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable where Operation : GraphQLOperation {
    self.sendForResult(operation: operation, completionHandler: completionHandler)
  }
}

private final class MockTask: Cancellable {
  func cancel() {
    // no-op
  }
}
