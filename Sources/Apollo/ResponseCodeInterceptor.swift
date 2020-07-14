import Foundation

class ResponseCodeInterceptor: ApolloInterceptor {
    var isCancelled: Bool = false
    
    enum ResponseCodeError: Error {
        case invalidResponseCode(response: HTTPURLResponse?, rawData: Data?)
    }
    
    func interceptAsync<ParsedValue: Parseable, Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<ParsedValue>,
        completion: @escaping (Result<ParsedValue, Error>) -> Void) {
        
        guard !self.isCancelled else {
            return
        }
        
        guard response.httpResponse?.apollo.isSuccessful == true else {
            completion(.failure(ResponseCodeError.invalidResponseCode(response: response.httpResponse,
                                                                      rawData: response.rawData)))
            return
        }
        
        chain.proceedAsync(request: request,
                           response: response,
                           completion: completion)
    }
}
