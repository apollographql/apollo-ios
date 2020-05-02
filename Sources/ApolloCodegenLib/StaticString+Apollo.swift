import Foundation

extension StaticString: ApolloCompatible {}

extension ApolloExtension where Base == StaticString {
  public var lastPathComponent: String {
    return (toString as NSString).lastPathComponent
  }
  
  public var toString: String {
    return base.withUTF8Buffer {
        String(decoding: $0, as: UTF8.self)
    }
  }
}
