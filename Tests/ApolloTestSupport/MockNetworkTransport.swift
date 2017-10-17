import Apollo
import Dispatch

public final class MockNetworkTransport: NetworkTransport {
  let body: JSONObject

  public init(body: JSONObject) {
    self.body = body
  }

  public func send<Operation>(operation: Operation, completionHandler: @escaping (_ response: GraphQLResponse<Operation>?, _ error: Error?) -> Void) -> Cancellable {
    DispatchQueue.global(qos: .default).async {
      completionHandler(GraphQLResponse(operation: operation, body: self.body), nil)
    }
    return MockTask()
  }
}

private final class MockTask: Cancellable {
  func cancel() {
  }
}
