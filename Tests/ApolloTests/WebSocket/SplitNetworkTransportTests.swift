//
//  SplitNetworkTransportTests.swift
//  ApolloWebSocketTests
//
//  Created by Ellen Shapiro on 10/23/19.
//

import Foundation
import XCTest
import Apollo
import ApolloTestSupport
@testable import ApolloWebSocket

class SplitNetworkTransportTests: XCTestCase {
  
  private static let mockTransportName = "TestMockNetworkTransport"
  private static let mockTransportVersion = "TestMockNetworkTransportVersion"
  private static let webSocketName = "TestWebSocketTransport"
  private static let webSocketVersion = "TestWebSocketTransportVersion"
  
  private var mockTransport: MockNetworkTransport!
  private var webSocketTransport: MockWebSocketTransport!
  private var splitTransport: SplitNetworkTransport!

  override func setUp() {
    super.setUp()

    mockTransport = {
      let transport = MockNetworkTransport(server: MockGraphQLServer(), store: ApolloStore())

      transport.clientName = Self.mockTransportName
      transport.clientVersion = Self.mockTransportVersion
      return transport
    }()

    webSocketTransport = MockWebSocketTransport(
      clientName: Self.webSocketName,
      clientVersion: Self.webSocketVersion
    )

    splitTransport = SplitNetworkTransport(
      uploadingNetworkTransport: mockTransport,
      webSocketNetworkTransport: webSocketTransport
    )
  }

  override func tearDown() {
    mockTransport = nil
    webSocketTransport = nil
    splitTransport = nil

    super.tearDown()
  }
  
  func testGettingSplitClientNameWithDifferentNames() {
    let splitName = self.splitTransport.clientName
    XCTAssertTrue(splitName.hasPrefix("SPLIT_"))
    XCTAssertTrue(splitName.contains(Self.mockTransportName))
    XCTAssertTrue(splitName.contains(Self.webSocketName))
  }
  
  func testGettingSplitClientVersionWithDifferentVersions() {
    let splitVersion = self.splitTransport.clientVersion
    XCTAssertTrue(splitVersion.hasPrefix("SPLIT_"))
    XCTAssertTrue(splitVersion.contains(Self.mockTransportVersion))
    XCTAssertTrue(splitVersion.contains(Self.webSocketVersion))
  }

  func testGettingSplitClientNameWithTheSameNames() {
    let splitName = "TestSplitClientName"
    
    self.webSocketTransport.clientName = splitName
    self.mockTransport.clientName = splitName
    
    XCTAssertEqual(self.splitTransport.clientName, splitName)
  }
  
  func testGettingSplitClientVersionWithTheSameVersions() {
    let splitVersion = "TestSplitClientVersion"
    
    self.webSocketTransport.clientVersion = splitVersion
    self.mockTransport.clientVersion = splitVersion
    
    XCTAssertEqual(self.splitTransport.clientVersion, splitVersion)
  }
}
