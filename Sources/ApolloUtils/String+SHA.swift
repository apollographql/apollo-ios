import Foundation
import CommonCrypto

extension String: ApolloCompatible {}

extension ApolloExtension where Base == String {

  /// The SHA256 hash of the current string.
  public var sha256Hash: String {
    let data = base.data(using: .utf8)!
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
      _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }

    var hashString = ""
    for byte in hash {
      hashString += String(format:"%02x", UInt8(byte))
    }
    return hashString
  }
}
