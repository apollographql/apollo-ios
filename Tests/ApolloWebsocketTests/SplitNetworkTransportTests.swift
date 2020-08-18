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
  
  private let mockTransportName = "TestMockNetworkTransport"
  private let mockTransportVersion = "TestMockNetworkTransportVersion"
  
  private let webSocketName = "TestWebSocketTransport"
  private let webSocketVersion = "TestWebSocketTransportVersion"
  
  private lazy var mockTransport: MockNetworkTransport = {
    let store = ApolloStore(cache: InMemoryNormalizedCache())
    let transport = MockNetworkTransport(body: JSONObject(),
                                         store: store)
    
    transport.clientName = self.mockTransportName
    transport.clientVersion = self.mockTransportVersion
    return transport
  }()

  private lazy var webSocketTransport: WebSocketTransport = {
    let request = URLRequest(url: TestURL.starWarsWebSocket.url)
    return WebSocketTransport(request: request,
                              clientName: self.webSocketName,
                              clientVersion: self.webSocketVersion)
  }()
  
  private lazy var splitTransport = SplitNetworkTransport(
    uploadingNetworkTransport: self.mockTransport,
    webSocketNetworkTransport: self.webSocketTransport
  )
  
  func testGettingSplitClientNameWithDifferentNames() {
    let splitName = self.splitTransport.clientName
    XCTAssertTrue(splitName.hasPrefix("SPLIT_"))
    XCTAssertTrue(splitName.contains(self.mockTransportName))
    XCTAssertTrue(splitName.contains(self.webSocketName))
  }
  
  func testGettingSplitClientVersionWithDifferentVersions() {
    let splitVersion = self.splitTransport.clientVersion
    XCTAssertTrue(splitVersion.hasPrefix("SPLIT_"))
    XCTAssertTrue(splitVersion.contains(self.mockTransportVersion))
    XCTAssertTrue(splitVersion.contains(self.webSocketVersion))
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
