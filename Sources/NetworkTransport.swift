import Foundation

public protocol NetworkTransport {
  func send<Operation: GraphQLOperation>(operation: Operation, completionHandler: @escaping GraphQLOperationResponseHandler<Operation>)
}

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
  let serializationFormat = JSONSerializationFormat()

  public init(url: URL, configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
    self.url = url
    self.session = URLSession(configuration: configuration)
  }

  public func send<Operation: GraphQLOperation>(operation: Operation, completionHandler: @escaping GraphQLOperationResponseHandler<Operation>) {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: GraphQLMap = ["query": type(of: operation).queryDocument, "variables": operation.variables]
    request.httpBody = try! serializationFormat.serialize(map: body)

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
        let responseMap = try self.serializationFormat.deserialize(data: data)
        let result: GraphQLResult<Operation.Data> = try self.parseResult(responseMap: responseMap)
        completionHandler(result, nil)
      } catch {
        completionHandler(nil, error)
      }
    }
    task.resume()
  }

  private func parseResult<Data: GraphQLMapDecodable>(responseMap: GraphQLMap) throws -> GraphQLResult<Data> {
    let data: Data? = try responseMap.optionalValue(forKey: "data")
    let errors: [GraphQLError]? = try responseMap.optionalList(forKey: "errors")
    return GraphQLResult(data: data, errors: errors)
  }
}
