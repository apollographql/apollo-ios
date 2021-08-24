//  Created by Joseph Ross on 7/16/14.
//  Copyright © 2017 Joseph Ross.
//  Modified by Anthony Miller & Apollo GraphQL on 8/12/21
//
//  This is a derived work derived from
//  Starscream (https://github.com/daltoniam/Starscream)
//
//  Original Work License: http://www.apache.org/licenses/LICENSE-2.0
//  Derived Work License: https://github.com/apollographql/apollo-ios/blob/main/LICENSE
//
//  Compression implementation is implemented in conformance with RFC 7692 Compression Extensions
//  for WebSocket: https://tools.ietf.org/html/rfc7692

import Foundation
import zlib

class Decompressor {
  enum Error: Swift.Error {
    case resetFailed
    case decompressionFailed
  }

  private var strm = z_stream()
  private var buffer = [UInt8](repeating: 0, count: 0x2000)
  private var inflateInitialized = false
  private let windowBits:Int

  init?(windowBits:Int) {
    self.windowBits = windowBits
    guard initInflate() else { return nil }
  }

  private func initInflate() -> Bool {
    if Z_OK == inflateInit2_(&strm, -CInt(windowBits),
                             ZLIB_VERSION, CInt(MemoryLayout<z_stream>.size))
    {
      inflateInitialized = true
      return true
    }
    return false
  }

  func reset() throws {
    teardownInflate()
    guard initInflate() else { throw Error.resetFailed }
  }

  func decompress(_ data: Data, finish: Bool) throws -> Data {
    return try data.withUnsafeBytes { pointer -> Data in
      guard let bytes = pointer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
        return data
      }
      return try decompress(bytes: bytes, count: data.count, finish: finish)
    }
  }

  func decompress(bytes: UnsafePointer<UInt8>, count: Int, finish: Bool) throws -> Data {
    var decompressed = Data()
    try decompress(bytes: bytes, count: count, out: &decompressed)

    if finish {
      let tail: [UInt8] = [0x00, 0x00, 0xFF, 0xFF]
      try decompress(bytes: tail, count: tail.count, out: &decompressed)
    }

    return decompressed

  }

  private func decompress(bytes: UnsafePointer<UInt8>, count: Int, out: inout Data) throws {
    var res:CInt = 0
    strm.next_in = UnsafeMutablePointer<UInt8>(mutating: bytes)
    strm.avail_in = CUnsignedInt(count)

    repeat {
      buffer.withUnsafeMutableBytes { buffer in
        let bytePtr = buffer.baseAddress!.assumingMemoryBound(to: UInt8.self)
        strm.next_out = UnsafeMutablePointer<UInt8>(bytePtr)
        strm.avail_out = CUnsignedInt(buffer.count)

        res = inflate(&strm, 0)

        let byteCount = buffer.count - Int(strm.avail_out)
        out.append(bytePtr, count: byteCount)
      }
    } while res == Z_OK && strm.avail_out == 0

    guard (res == Z_OK && strm.avail_out > 0)
            || (res == Z_BUF_ERROR && Int(strm.avail_out) == buffer.count)
    else {
      throw Error.decompressionFailed
    }
  }

  private func teardownInflate() {
    if inflateInitialized, Z_OK == inflateEnd(&strm) {
      inflateInitialized = false
    }
  }

  deinit {
    teardownInflate()
  }
}

class Compressor {
  enum Error: Swift.Error {
    case resetFailed
    case compressionFailed
  }

  private var strm = z_stream()
  private var buffer = [UInt8](repeating: 0, count: 0x2000)
  private var deflateInitialized = false
  private let windowBits:Int

  init?(windowBits: Int) {
    self.windowBits = windowBits
    guard initDeflate() else { return nil }
  }

  private func initDeflate() -> Bool {
    if Z_OK == deflateInit2_(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED,
                             -CInt(windowBits), 8, Z_DEFAULT_STRATEGY,
                             ZLIB_VERSION, CInt(MemoryLayout<z_stream>.size))
    {
      deflateInitialized = true
      return true
    }
    return false
  }

  func reset() throws {
    teardownDeflate()
    guard initDeflate() else { throw Error.resetFailed }
  }

  func compress(_ data: Data) throws -> Data {
    var compressed = Data()
    var res:CInt = 0
    data.withUnsafeBytes { pointer -> Void in
      guard let bytes = pointer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
        return
      }

      strm.next_in = UnsafeMutablePointer<UInt8>(mutating: bytes)
      strm.avail_in = CUnsignedInt(data.count)

      repeat {
        buffer.withUnsafeMutableBytes { buffer in
          let bytePtr = buffer.baseAddress!.assumingMemoryBound(to: UInt8.self)
          strm.next_out = bytePtr
          strm.avail_out = CUnsignedInt(buffer.count)
          res = deflate(&strm, Z_SYNC_FLUSH)
          let byteCount = buffer.count - Int(strm.avail_out)
          compressed.append(bytePtr, count: byteCount)
        }
      }
      while res == Z_OK && strm.avail_out == 0

    }

    guard res == Z_OK && strm.avail_out > 0
            || (res == Z_BUF_ERROR && Int(strm.avail_out) == buffer.count)
    else {
      throw Error.compressionFailed
    }

    compressed.removeLast(4)
    return compressed
  }

  private func teardownDeflate() {
    if deflateInitialized, Z_OK == deflateEnd(&strm) {
      deflateInitialized = false
    }
  }

  deinit {
    teardownDeflate()
  }
}

