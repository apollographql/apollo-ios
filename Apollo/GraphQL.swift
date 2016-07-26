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

public struct GraphQLResult<Data> {
  public let data: Data?
  public let errors: [GraphQLError]?
  
  init(data: Data?, errors: [GraphQLError]?) {
    self.data = data
    self.errors = errors
  }
}

public struct GraphQLError: ErrorProtocol {
  let message: String
}

extension GraphQLError: GraphQLMapConvertible {
  public init(map: GraphQLMap) throws {
    message = try map.value(forKey: "message")
  }
}

public protocol GraphQLQuery {
  var queryString: String { get }
  var variables: GraphQLMap? { get }
  
  associatedtype Data: GraphQLMapConvertible
}

public extension GraphQLQuery {
  var variables: GraphQLMap? {
    return nil
  }
  
  func parse(data: JSONObject) throws -> Data {
    return try Data(map: GraphQLMap(jsonObject: data))
  }
}

public protocol GraphQLFragment {
  var fragmentString: String { get }
  
  associatedtype Data
}
