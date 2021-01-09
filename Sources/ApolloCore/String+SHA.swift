import Foundation

extension String: ApolloCompatible {}

extension ApolloExtension where Base == String {

  /// The SHA256 hash of the current string.
  public var sha256Hash: String {
    return Crypt.sha256(base)
  }
}
