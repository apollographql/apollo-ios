//  Created by Joseph Ross on 7/16/14.
//  Copyright © 2017 Joseph Ross.
//  Modified by Anthony Miller & Apollo GraphQL on 8/12/21
//
//  This is a derived work derived from
//  Starscream(https://github.com/daltoniam/Starscream)
//
//  Original Work License: http://www.apache.org/licenses/LICENSE-2.0
//  Derived Work License: https://github.com/apollographql/apollo-ios/blob/main/LICENSE
//
//  Compression implementation is implemented in conformance with RFC 7692 Compression Extensions
//  for WebSocket: https://tools.ietf.org/html/rfc7692

import XCTest
@testable import ApolloWebSocket

class CompressionTests: XCTestCase {

  func testBasic() {
    let compressor = Compressor(windowBits: 15)!
    let decompressor = Decompressor(windowBits: 15)!

    let rawData = "Hello, World! Hello, World! Hello, World! Hello, World! Hello, World!".data(using: .utf8)!

    let compressed = try! compressor.compress(rawData)
    let uncompressed = try! decompressor.decompress(compressed, finish: true)

    XCTAssertEqual(rawData, uncompressed)
  }

  func testHugeData() {
    let compressor = Compressor(windowBits: 15)!
    let decompressor = Decompressor(windowBits: 15)!

    // 2 Gigs!
    var rawData = Data(repeating: 0, count: 0x80000)
    let rawDataLen = rawData.count
    rawData.withUnsafeMutableBytes { ptr -> Void in
      arc4random_buf(ptr.baseAddress, rawDataLen)
    }

    let compressed = try! compressor.compress(rawData)
    let uncompressed = try! decompressor.decompress(compressed, finish: true)

    XCTAssertEqual(rawData, uncompressed)
  }

}
