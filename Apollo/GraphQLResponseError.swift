// Copyright (c) 2016 Lukas Schmidt
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

import Foundation

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
