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

public enum ResponseFormatError: ErrorProtocol {
  case missingData
}

public protocol NetworkTransport {
  func send<Query: GraphQLQuery>(query: Query, completionHandler: (result: GraphQLResult<Query.Data>?, error: ErrorProtocol?) -> Void)
}

public class HTTPNetworkTransport: NetworkTransport {
  let url: URL
  let session = URLSession.shared
  
  public init(url: URL) {
    self.url = url
  }
  
  public func send<Query: GraphQLQuery>(query: Query, completionHandler: (result: GraphQLResult<Query.Data>?, error: ErrorProtocol?) -> Void) {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let body: GraphQLMap = ["query": query.queryDocument, "variables": query.variables]
    request.httpBody = try! JSONSerialization.data(withJSONObject: body.jsonValue, options: [])
    
    let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: NSError?) in
      if error != nil {
        completionHandler(result: nil, error: error)
        return
      }
      
      guard let data = data else {
        completionHandler(result: nil, error: ResponseFormatError.missingData)
        return
      }
      
      do {
        guard let rootObject = try JSONSerialization.jsonObject(with: data, options: []) as? JSONObject else {
          completionHandler(result: nil, error: ResponseFormatError.missingData)
          return
        }
        
        let responseMap = GraphQLMap(jsonObject: rootObject)
        let result: GraphQLResult<Query.Data> = try self.parseResult(responseMap: responseMap)
        completionHandler(result: result, error: nil)
      } catch {
        completionHandler(result: nil, error: error)
      }
    }
    task.resume()
  }
  
  private func parseResult<Data: GraphQLMapConvertible>(responseMap: GraphQLMap) throws -> GraphQLResult<Data> {
    let data: Data? = try responseMap.value(forKey: "data")
    let errors: [GraphQLError]? = try responseMap.list(forKey: "errors")
    return GraphQLResult(data: data, errors: errors)
  }
}
