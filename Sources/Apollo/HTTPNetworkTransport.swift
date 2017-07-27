import Foundation

extension URLSessionTask: Cancellable {}

/// A transport-level, HTTP-specific error.
public struct GraphQLHTTPResponseError: Error, LocalizedError {
  public enum ErrorKind {
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
  
  /// The body of the response.
  public let body: Data?
  /// Information about the response as provided by the server.
  public let response: HTTPURLResponse
  public let kind: ErrorKind
  
  public var bodyDescription: String {
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
  
  public var errorDescription: String? {
    return "\(kind.description) (\(response.statusCode) \(response.statusCodeDescription)): \(bodyDescription)"
  }
}

/// A network transport that uses HTTP POST requests to send GraphQL operations to a server, and that uses `URLSession` as the networking implementation.
public class HTTPNetworkTransport: NetworkTransport {
  let url: URL
  let session: URLSession
  let sessionDelegate: SessionDelegate
  let serializationFormat = JSONSerializationFormat.self
  
  /// Creates a network transport with the specified server URL and session configuration.
  ///
  /// - Parameters:
  ///   - url: The URL of a GraphQL server to connect to.
  ///   - configuration: A session configuration used to configure the session. Defaults to `URLSessionConfiguration.default`.
  ///   - sendOperationIdentifiers: Whether to send operation identifiers rather than full operation text, for use with servers that support query persistence. Defaults to false.
  public init(url: URL, configuration: URLSessionConfiguration = URLSessionConfiguration.default, sendOperationIdentifiers: Bool = false) {
    self.url = url
    self.sessionDelegate = SessionDelegate()
    self.session = URLSession(configuration: configuration, delegate: self.sessionDelegate, delegateQueue: nil)
    self.sendOperationIdentifiers = sendOperationIdentifiers
  }
  
  /// Send a GraphQL operation to a server and return a response.
  ///
  /// - Parameters:
  ///   - operation: The operation to send.
  ///   - completionHandler: A closure to call when a request completes.
  ///   - response: The response received from the server, or `nil` if an error occurred.
  ///   - error: An error that indicates why a request failed, or `nil` if the request was succesful.
  /// - Returns: An object that can be used to cancel an in progress request.
  public func send<Operation: GraphQLOperation>(operation: Operation, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable {
    return self.upload(operation: operation, files: nil, progressHandler: nil, completionHandler: completionHandler)
  }
  
  /// Send a GraphQL operation to a server and return a response.
  ///
  /// - Parameters:
  ///   - operation: The operation to send.
  ///   - files: A list of files to send as a multipart request.
  ///   - progressHandler: A closure to call periodically as the request is sent.
  ///   - completionHandler: A closure to call when a request completes.
  ///   - response: The response received from the server, or `nil` if an error occurred.
  ///   - error: An error that indicates why a request failed, or `nil` if the request was succesful.
  /// - Returns: An object that can be used to cancel an in progress request.
  public func upload<Operation>(operation: Operation, files: [GraphQLFile]? = nil, progressHandler: ((Progress) -> Void)? = nil, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    if let files = files, !files.isEmpty {
      let formData = requestMultipartFormData(for: operation, files: files)
      request.setValue("multipart/form-data; boundary=\(formData.boundary)", forHTTPHeaderField: "Content-Type")
      request.httpBody = formData.encode()
    } else {
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      let body = requestBody(for: operation)
      request.httpBody = try! serializationFormat.serialize(value: body)
    }
    
    func notifyCompletionHandler(data: Data?, response: URLResponse?, error: Error?) {
      if error != nil {
        completionHandler(nil, error)
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse else {
        fatalError("Response should be an HTTPURLResponse")
      }
      
      if (!httpResponse.isSuccessful) {
        completionHandler(nil, GraphQLHTTPResponseError(body: data, response: httpResponse, kind: .errorResponse))
        return
      }
      
      guard let data = data else {
        completionHandler(nil, GraphQLHTTPResponseError(body: nil, response: httpResponse, kind: .invalidResponse))
        return
      }
      
      do {
        guard let body =  try self.serializationFormat.deserialize(data: data) as? JSONObject else {
          throw GraphQLHTTPResponseError(body: data, response: httpResponse, kind: .invalidResponse)
        }
        let response = GraphQLResponse(operation: operation, body: body)
        completionHandler(response, nil)
      } catch {
        completionHandler(nil, error)
      }
    }
    
    let task = session.dataTask(with: request)
    
    self.sessionDelegate.add(task: task, completionHandler: notifyCompletionHandler, progressHandler: progressHandler)
    
    task.resume()
    
    return task
  }

  private let sendOperationIdentifiers: Bool

  private func requestBody<Operation: GraphQLOperation>(for operation: Operation) -> GraphQLMap {
    if sendOperationIdentifiers {
      guard let operationIdentifier = type(of: operation).operationIdentifier else {
        preconditionFailure("To send operation identifiers, Apollo types must be generated with operationIdentifiers")
      }
      return ["id": operationIdentifier, "variables": operation.variables]
    }
    return ["query": type(of: operation).requestString, "variables": operation.variables]
  }
  
  private func requestMultipartFormData<Operation: GraphQLOperation>(for operation: Operation, files: [GraphQLFile]) -> MultipartFormData {
    let formData = MultipartFormData()
    
    let fields = requestBody(for: operation)
    for (name, data) in fields {
      if let data = data as? GraphQLMap {
        let data = try! serializationFormat.serialize(value: data)
        formData.appendPart(data: data, name: name)
      } else if let data = data as? String {
        formData.appendPart(string: data, name: name)
      } else {
        formData.appendPart(string: data.debugDescription, name: name)
      }
    }
    
    for f in files {
      formData.appendPart(inputStream: f.inputStream, contentLength: f.contentLength, name: f.fieldName, contentType: f.mimeType, filename: f.originalName)
    }
    
    return formData
  }
}
