import Foundation

public class RequestChain: Cancellable {
  
  public enum ChainError: Error {
    case invalidIndex(chain: RequestChain, index: Int)
    case noInterceptors
  }
  
  private let interceptors: [ApolloInterceptor]
  private var currentIndex: Int
  
  /// Something which allows additional error handling to occur when some kind of error has happened.
  public var additionalErrorHandler: ApolloErrorInterceptor?
  
  /// Creates a chain with the given interceptor array.
  ///
  /// - Parameter interceptors: The interceptors to use.
  public init(interceptors: [ApolloInterceptor]) {
    self.interceptors = interceptors
    self.currentIndex = 0
  }
  
  /// Kicks off the request from the beginning of the interceptor array.
  ///
  /// - Parameters:
  ///   - request: The request to send.
  ///   - completion: The completion closure to call when the request has completed.
  public func kickoff<ParsedValue: Parseable, Operation: GraphQLOperation>(request: HTTPRequest<Operation>, completion: @escaping (Result<ParsedValue, Error>) -> Void) {
    assert(self.currentIndex == 0, "The interceptor index should be zero when calling this method")
    
    let response: HTTPResponse<ParsedValue> = HTTPResponse(response: nil,
                                                           rawData: nil,
                                                           parsedResponse: nil,
                                                           sourceType: .notFetchedYet)
    guard let firstInterceptor = self.interceptors.first else {
      completion(.failure(ChainError.noInterceptors))
      return
    }
    
    firstInterceptor.interceptAsync(chain: self,
                                    request: request,
                                    response: response,
                                    completion: completion)
  }

  /// Proceeds to the next interceptor in the array.
  ///
  /// - Parameters:
  ///   - request: The in-progress request object
  ///   - response: The in-progress response object
  ///   - completion: The completion closure to call when data has been processed and should be returned to the UI.
  public func proceedAsync<ParsedValue: Parseable, Operation: GraphQLOperation>(request: HTTPRequest<Operation>,
                           response: HTTPResponse<ParsedValue>,
                           completion: @escaping (Result<ParsedValue, Error>) -> Void) {
    let nextIndex = self.currentIndex + 1
    guard self.interceptors.indices.contains(nextIndex) else {
      completion(.failure(ChainError.invalidIndex(chain: self, index: nextIndex)))
      return
    }
    
    self.currentIndex = nextIndex
    let interceptor = self.interceptors[self.currentIndex]
    
    interceptor.interceptAsync(chain: self,
                               request: request,
                               response: response,
                               completion: completion)
  }
  
  /// Cancels the entire chain of interceptors.
  public func cancel() {
    for interceptor in self.interceptors {
      interceptor.isCancelled = true
    }
    
    self.additionalErrorHandler = nil
  }
  
  /// Restarts the request starting from the first inteceptor.
  ///
  /// - Parameters:
  ///   - request: The request to retry
  ///   - completion: The completion closure to call when the request has completed.
  public func retry<ParsedValue: Parseable, Operation: GraphQLOperation>(request: HTTPRequest<Operation>,
                    completion: @escaping (Result<ParsedValue, Error>) -> Void) {
    request.retryCount += 1
    self.currentIndex = 0
    self.kickoff(request: request, completion: completion)
  }
  
  func handleErrorAsync<ParsedValue: Parseable, Operation: GraphQLOperation>(
    _ error: Error,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<ParsedValue>,
    completion: @escaping (Result<ParsedValue, Error>) -> Void) {
    guard let additionalHandler = self.additionalErrorHandler else {
      completion(.failure(error))
      return
    }
    
    
    additionalHandler.handleErrorAsync(error: error,
                                       chain: self,
                                       request: request,
                                       response: response,
                                       completion: completion)
  }
}
