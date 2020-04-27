import Foundation

enum HTTPBinAPI {
    static let baseURL = URL(string: "https://httpbin.org/")!
    enum Endpoint {
        case bytes(count: Int)
        case get
        case headers
        case image
        case post
        
        var toString: String {
            
            switch self {
            case .bytes(let count):
                return "bytes/\(count)"
            case .get:
                return "get"
            case .headers:
                return "headers"
            case .image:
                return "image/jpeg"
            case .post:
                return "post"
            }
        }
        
        var toURL: URL {
            HTTPBinAPI.baseURL.appendingPathComponent(self.toString)
        }
    }
}

struct HTTPBinResponse: Codable {
    
    let headers: [String: String]
    let url: String
    let json: [String: String]?
    
    init(data: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}
