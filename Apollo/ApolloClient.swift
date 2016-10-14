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

public class ApolloClient {
    let networkTransport: NetworkTransport
    let url: URL
  
  public init(url: URL, networkTransport: NetworkTransport = URLSession(configuration: .default)) {
    self.networkTransport = networkTransport
    self.url = url
  }
  
  public func fetch<Query: GraphQLQuery>(query: Query, queue: DispatchQueue = DispatchQueue.main, completionHandler: @escaping GraphQLOperationResponseHandler<Query>) {
    send(operation: query, queue: queue, completionHandler: completionHandler)
  }
  
  public func perform<Mutation: GraphQLMutation>(mutation: Mutation, queue: DispatchQueue = DispatchQueue.main, completionHandler: @escaping GraphQLOperationResponseHandler<Mutation>) {
    send(operation: mutation, queue: queue, completionHandler: completionHandler)
  }
    
    private func send<Operation: GraphQLOperation>(operation: Operation, queue: DispatchQueue = DispatchQueue.main, completionHandler: @escaping GraphQLOperationResponseHandler<Operation>) {
        let request = try! createRequest(from: operation, with: url)
        networkTransport.send(request: request) { data, response, error in
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
                guard let rootObject = try JSONSerialization.jsonObject(with: data) as? JSONObject else {
                    completionHandler(nil, GraphQLResponseError(body: data, response: httpResponse, kind: .invalidResponse))
                    return
                }
                
                let result: GraphQLResult<Operation.Data> = try parseResult(from: rootObject)
                completionHandler(result, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
}

public func parseResult<Data: GraphQLMapConvertible>(from jsonRootObject: JSONObject) throws -> GraphQLResult<Data> {
    let responseMap = GraphQLMap(jsonObject: jsonRootObject)
    let data: Data? = try responseMap.optionalValue(forKey: "data")
    let errors: [GraphQLError]? = try responseMap.optionalList(forKey: "errors")
    
    return GraphQLResult(data: data, errors: errors)
}

public func createRequest<Operation: GraphQLOperation>(from operation: Operation, with baseURL: URL) throws -> URLRequest {
    var request = URLRequest(url: baseURL)
    request.httpMethod = "POST"
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: GraphQLMap = ["query": type(of: operation).queryDocument, "variables": operation.variables]
    request.httpBody = try JSONSerialization.data(withJSONObject: body.jsonValue)
    
    return request
}
