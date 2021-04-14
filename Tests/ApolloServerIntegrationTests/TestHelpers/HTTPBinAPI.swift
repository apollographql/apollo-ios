import Foundation

enum HTTPBinAPI {
  static let baseURL = URL(string: "https://httpbin.org")!
  enum Endpoint {
    case bytes(count: Int)
    case get
    case getWithIndex(index: Int)
    case headers
    case image
    case post
    
    var toString: String {
      
      switch self {
      case .bytes(let count):
        return "bytes/\(count)"
      case .get,
           .getWithIndex:
        return "get"
      case .headers:
        return "headers"
      case .image:
        return "image/jpeg"
      case .post:
        return "post"
      }
    }
    
    var queryParams: [URLQueryItem]? {
      switch self {
      case .getWithIndex(let index):
        return [URLQueryItem(name: "index", value: "\(index)")]
      default:
        return nil
      }
    }
    
    var toURL: URL {
      var components = URLComponents(url: HTTPBinAPI.baseURL, resolvingAgainstBaseURL: false)!
      components.path = "/\(self.toString)"
      components.queryItems = self.queryParams
      
      return components.url!
    }
  }
}

struct HTTPBinResponse: Codable {
  
  let headers: [String: String]
  let url: String
  let json: [String: String]?
  let args: [String: String]?
  
  init(data: Data) throws {
    self = try JSONDecoder().decode(Self.self, from: data)
  }
}
