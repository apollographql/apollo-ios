import Foundation

class NetworkFetchInterceptor: ApolloInterceptor {
    let client: URLSessionClient
    var isCancelled: Bool = false {
        didSet {
            if self.isCancelled {
                self.currentTask?.cancel()
            }
        }
    }
    var currentTask: URLSessionTask?
    
    init(client: URLSessionClient) {
        self.client = client
    }
    
    func interceptAsync<ParsedValue: Parseable, Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<ParsedValue>,
        completion: @escaping (Result<ParsedValue, Error>) -> Void) {
        guard !self.isCancelled else {
            return
        }
        
        let urlRequest: URLRequest
        do {
            urlRequest = try request.toURLRequest()
        } catch {
            completion(.failure(error))
            return
        }
        
        self.currentTask = self.client.sendRequest(urlRequest) { result in
            defer {
                self.currentTask = nil
            }
            
            guard !self.isCancelled else {
                return
            }
            
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let (data, httpResponse)):
                response.httpResponse = httpResponse
                response.rawData = data
                response.sourceType = .network
                chain.proceedAsync(request: request,
                                   response: response,
                                   completion: completion)
            }
        }
    }
}
