import Foundation

public class JSONRequest<Operation: GraphQLOperation>: HTTPRequest<Operation> {
    
    public let cachePolicy: CachePolicy
    public let autoPersistQueries: Bool
    public let useGETForQueries: Bool
    public let useGETForPersistedQueryRetry: Bool
    
    public init(operation: Operation,
                graphQLEndpoint: URL,
                additionalHeaders: [String: String] = [:],
                cachePolicy: CachePolicy = .default,
                autoPersistQueries: Bool = false,
                useGETForQueries: Bool = false,
                useGETForPersistedQueryRetry: Bool = false) {
        self.cachePolicy = cachePolicy
        self.autoPersistQueries = autoPersistQueries
        self.useGETForQueries = useGETForQueries
        self.useGETForPersistedQueryRetry = useGETForPersistedQueryRetry
        
        super.init(graphQLEndpoint: graphQLEndpoint,
                   operation: operation,
                   contentType: "application/json",
                   additionalHeaders: additionalHeaders)
    }

    public override func toURLRequest() throws -> URLRequest {
        var request = try super.toURLRequest()
        
        return request
    }
}
