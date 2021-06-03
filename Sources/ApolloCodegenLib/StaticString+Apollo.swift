import Foundation
#if !COCOAPODS
import ApolloUtils
#endif

extension StaticString: ApolloCompatible {}

extension ApolloExtension where Base == StaticString {
  var lastPathComponent: String {
    return (toString as NSString).lastPathComponent
  }
  
  var toString: String {
    return base.withUTF8Buffer {
        String(decoding: $0, as: UTF8.self)
    }
  }
}
