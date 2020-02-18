import Apollo
import Dispatch

public final class MockNetworkTransport: NetworkTransport {
  let body: JSONObject

  public var clientName = "MockNetworkTransport"
  public var clientVersion = "mock_version"
  
  public init(body: JSONObject) {
    self.body = body
  }

  public func send<Operation>(operation: Operation, completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable {
    DispatchQueue.global(qos: .default).async {
      completionHandler(.success(GraphQLResponse(operation: operation, body: self.body)))
    }
    return MockTask()
  }
}

private final class MockTask: Cancellable {
  func cancel() {
  }
}
