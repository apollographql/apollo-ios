import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

public struct GraphQLGETTransformer {

  let body: JSONEncodableDictionary
  let url: URL

  /// A helper for transforming a `JSONEncodableDictionary` that can be sent with a `POST` request into a URL with query parameters for a `GET` request.
  ///
  /// - Parameters:
  ///   - body: The `JSONEncodableDictionary` to transform from the body of a `POST` request
  ///   - url: The base url to append the query to.
  public init(body: JSONEncodableDictionary, url: URL) {
    self.body = body
    self.url = url
  }

  /// Creates the get URL.
  ///
  /// - Returns: [optional] The created get URL or nil if the provided information couldn't be used to access the appropriate parameters.
  public func createGetURL() -> URL? {
    guard var components = URLComponents(string: self.url.absoluteString) else {
      return nil
    }

    var queryItems: [URLQueryItem] = components.queryItems ?? []

    do {
      _ = try self.body.sorted(by: {$0.key < $1.key}).compactMap({ arg in
        if let value = arg.value as? JSONEncodableDictionary {
          let data = try JSONSerialization.sortedData(withJSONObject: value.jsonValue)
          if let string = String(data: data, encoding: .utf8) {
            queryItems.append(URLQueryItem(name: arg.key, value: string))
          }
        } else if let string = arg.value as? String {
          queryItems.append(URLQueryItem(name: arg.key, value: string))
        } else if (arg.key != "variables") {
          assertionFailure()
        }
      })
    } catch {
      return nil
    }

    if !queryItems.isEmpty {
      components.queryItems = queryItems
    }

    components.percentEncodedQuery =
      components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")

    return components.url
  }
}

// MARK: - Hashable Conformance

extension GraphQLGETTransformer: Hashable {
  public static func == (lhs: GraphQLGETTransformer, rhs: GraphQLGETTransformer) -> Bool {
    lhs.body.jsonValue == rhs.body.jsonValue &&
    lhs.url == rhs.url
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(body.jsonValue)
    hasher.combine(url)
  }
}
