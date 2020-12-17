import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if !COCOAPODS
import ApolloCore
#endif

extension HTTPURLResponse: ApolloCompatible {}

extension ApolloExtension where Base == HTTPURLResponse {
  var isSuccessful: Bool {
    return (200..<300).contains(base.statusCode)
  }

  var statusCodeDescription: String {
    return HTTPURLResponse.localizedString(forStatusCode: base.statusCode)
  }
}
