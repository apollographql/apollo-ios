import Foundation

#if os(Linux)
import Crypto
public struct Crypt: CryptoProtocol {

    public init() {}

    static public func sha256(_ base: String) -> String {
        let data = base.data(using: .utf8)!
        let hash = SHA256.hash(data: data)

        var hashString = ""
        for byte in hash {
            hashString += String(format:"%02x", UInt8(byte))
        }
        return hashString

    }

  static public func shasum(at fileURL: URL) throws -> String {
      let file = try FileHandle(forReadingFrom: fileURL)
      defer {
          file.closeFile()
      }

      let data = file.readDataToEndOfFile()

      let hash = SHA256.hash(data: data)

      return hash.compactMap { String(format: "%02x", $0) }.joined()
  }

}
#else
import CommonCrypto

public struct Crypt: CryptoProtocol {

    public init() {}

    static public func sha256(_ base: String) -> String {
        let data = base.data(using: .utf8)!
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }

        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    static public func shasum(at fileURL: URL) throws -> String {
      let file = try FileHandle(forReadingFrom: fileURL)
      defer {
          file.closeFile()
      }

      let buffer = 1024 * 1024 // 1GB
      
      var context = CC_SHA256_CTX()
      CC_SHA256_Init(&context)

      while autoreleasepool(invoking: {
        let data = file.readData(ofLength: buffer)
        guard !data.isEmpty else {
          // Nothing more to read!
          return false
        }

        _ = data.withUnsafeBytes { bytesFromBuffer -> Int32 in
          guard let rawBytes = bytesFromBuffer.bindMemory(to: UInt8.self).baseAddress else {
            return Int32(kCCMemoryFailure)
          }
          return CC_SHA256_Update(&context, rawBytes, numericCast(data.count))
        }

        return true
      }) {}

      var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
      _ = digestData.withUnsafeMutableBytes { bytesFromDigest -> Int32 in
        guard let rawBytes = bytesFromDigest.bindMemory(to: UInt8.self).baseAddress else {
          return Int32(kCCMemoryFailure)
        }

        return CC_SHA256_Final(rawBytes, &context)
      }

      return digestData
        .map { String(format: "%02hhx", $0) }
        .joined()
    }

}
#endif

protocol CryptoProtocol {
  static func sha256(_ base: String) -> String

  static func shasum(at fileURL: URL) throws -> String
}
