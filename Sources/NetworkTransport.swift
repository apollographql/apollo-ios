import Foundation

public protocol NetworkTransport {
  func send<Operation: GraphQLOperation>(operation: Operation, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable
}

extension URLSessionTask: Cancellable {}

struct GraphQLResponseError: Error, LocalizedError {
  enum ErrorKind {
    case errorResponse
    case invalidResponse

    var description: String {
      switch self {
      case .errorResponse:
        return "Received error response"
      case .invalidResponse:
        return "Received invalid response"
      }
    }
  }

  let body: Data?
  let response: HTTPURLResponse
  let kind: ErrorKind

  var bodyDescription: String {
    if let body = body {
      if let description = String(data: body, encoding: response.textEncoding ?? .utf8) {
        return description
      } else {
        return "Unreadable response body"
      }
    } else {
      return "Empty response body"
    }
  }

  var errorDescription: String? {
    return "\(kind.description) (\(response.statusCode) \(response.statusCodeDescription)): \(bodyDescription)"
  }
}

public class HTTPNetworkTransport: NetworkTransport {
  let url: URL
  let session: URLSession
  let serializationFormat = JSONSerializationFormat.self

  public init(url: URL, configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
    self.url = url
    self.session = URLSession(configuration: configuration)
  }

  public func send<Operation: GraphQLOperation>(operation: Operation, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: GraphQLMap = ["query": type(of: operation).queryDocument, "variables": operation.variables]
    request.httpBody = try! serializationFormat.serialize(value: body)

    let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
      if error != nil {
        completionHandler(nil, error)
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        fatalError("Response should be an HTTPURLResponse")
      }

      if (!httpResponse.isSuccessful) {
        completionHandler(nil, GraphQLResponseError(body: data, response: httpResponse, kind: .errorResponse))
        return
      }

      guard let data = data else {
        completionHandler(nil, GraphQLResponseError(body: nil, response: httpResponse, kind: .invalidResponse))
        return
      }

      do {
        guard let rootObject = try self.serializationFormat.deserialize(data: data) as? JSONObject else {
          throw GraphQLResponseError(body: nil, response: httpResponse, kind: .invalidResponse)
        }
        let response = GraphQLResponse(operation: operation, rootObject: rootObject)
        completionHandler(response, nil)
      } catch {
        completionHandler(nil, error)
      }
    }
    task.resume()
    return task
  }
}
