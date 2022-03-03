import Foundation

/// URLs used in testing
public enum TestURL {
  case mockServer
  case mockPort8080
  
  public var url: URL {
    let urlString: String
    switch self {
    case .mockServer:
      urlString = "http://localhost/dummy_url"
    case .mockPort8080:
      urlString = "http://localhost:8080/graphql"
    }
    
    return URL(string: urlString)!
  }
}
