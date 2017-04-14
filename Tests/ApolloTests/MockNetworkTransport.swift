@testable import Apollo

final class MockNetworkTransport: NetworkTransport {
  let body: JSONObject
  
  init(body: JSONObject) {
    self.body = body
  }
  
  func send<Operation: GraphQLOperation>(operation: Operation, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable {
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
