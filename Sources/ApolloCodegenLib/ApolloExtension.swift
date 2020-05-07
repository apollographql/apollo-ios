import Foundation

public struct ApolloExtension<Base> {
  public let base: Base
}

public protocol ApolloCompatible {
  associatedtype Base
  var apollo: ApolloExtension<Base> { get }
  static var apollo: ApolloExtension<Base>.Type { get }
}

extension ApolloCompatible {
  public var apollo: ApolloExtension<Self> {
    ApolloExtension(base: self)
  }
  
  public static var apollo: ApolloExtension<Self>.Type {
    ApolloExtension<Self>.self
  }
}
