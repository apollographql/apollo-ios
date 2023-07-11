import Foundation
import Apollo
import ApolloAPI

// An interceptor which blindly retries every time it receives a request. 
class BlindRetryingTestInterceptor: ApolloInterceptor {
  var hitCount = 0
  private(set) var hasBeenCancelled = false

  public var id: String = UUID().uuidString

  func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
    self.hitCount += 1
    chain.retry(request: request,
                completion: completion)
  }
  
  // Purposely not adhering to `Cancellable` here to make sure non `Cancellable` interceptors don't have this called.
  func cancel() {
    self.hasBeenCancelled = true
  }
}
