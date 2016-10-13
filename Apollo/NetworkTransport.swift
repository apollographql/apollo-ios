// Copyright (c) 2016 Meteor Development Group, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
  
  public init(url: URL, configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
    self.url = url
    self.session = URLSession(configuration: configuration)
  }
  
  public func send<Operation: GraphQLOperation>(operation: Operation, completionHandler: @escaping GraphQLOperationResponseHandler<Operation>) {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: GraphQLMap = ["query": type(of: operation).queryDocument, "variables": operation.variables]
    request.httpBody = try! JSONSerialization.data(withJSONObject: body.jsonValue, options: [])
    
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
        guard let rootObject = try JSONSerialization.jsonObject(with: data, options: []) as? JSONObject else {
          completionHandler(nil, GraphQLResponseError(body: data, response: httpResponse, kind: .invalidResponse))
          return
        }
        
        let responseMap = GraphQLMap(jsonObject: rootObject)
        let result: GraphQLResult<Operation.Data> = try self.parseResult(responseMap: responseMap)
        completionHandler(result, nil)
      } catch {
        completionHandler(nil, error)
      }
    }
    task.resume()
  }
  
  private func parseResult<Data: GraphQLMapConvertible>(responseMap: GraphQLMap) throws -> GraphQLResult<Data> {
    let data: Data? = try responseMap.optionalValue(forKey: "data")
    let errors: [GraphQLError]? = try responseMap.optionalList(forKey: "errors")
    return GraphQLResult(data: data, errors: errors)
  }
}
