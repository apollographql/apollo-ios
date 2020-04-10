//
//  SplitNetworkTransportTests.swift
//  ApolloWebSocketTests
//
//  Created by Ellen Shapiro on 10/23/19.
//

import Foundation
import XCTest
import Apollo
@testable import ApolloWebSocket

class SplitNetworkTransportTests: XCTestCase {
  
  private let httpName = "TestHTTPNetworkTransport"
  private let httpVersion = "TestHTTPNetworkTransportVersion"
  
  private let webSocketName = "TestWebSocketTransport"
  private let webSocketVersion = "TestWebSocketTransportVersion"
  
  private lazy var httpTransport: HTTPNetworkTransport = {
    let url = URL(string: "http://localhost:8080/graphql")!
    let transport = HTTPNetworkTransport(url: url)
    
    transport.clientName = self.httpName
    transport.clientVersion = self.httpVersion
    return transport
  }()

  private lazy var webSocketTransport: WebSocketTransport = {
    let url = URL(string: "ws://localhost:8080/websocket")!
    let request = URLRequest(url: url)
    return WebSocketTransport(request: request,
                              clientName: self.webSocketName,
                              clientVersion: self.webSocketVersion)
  }()
  
  private lazy var splitTransport = SplitNetworkTransport(
    httpNetworkTransport: self.httpTransport,
    webSocketNetworkTransport: self.webSocketTransport
  )
  
  func testGettingSplitClientNameWithDifferentNames() {
    let splitName = self.splitTransport.clientName
    XCTAssertTrue(splitName.hasPrefix("SPLIT_"))
    XCTAssertTrue(splitName.contains(self.httpName))
    XCTAssertTrue(splitName.contains(self.webSocketName))
  }
  
  func testGettingSplitClientVersionWithDifferentVersions() {
    let splitVersion = self.splitTransport.clientVersion
    XCTAssertTrue(splitVersion.hasPrefix("SPLIT_"))
    XCTAssertTrue(splitVersion.contains(self.httpVersion))
    XCTAssertTrue(splitVersion.contains(self.webSocketVersion))
  }

  func testGettingSplitClientNameWithTheSameNames() {
    let splitName = "TestSplitClientName"
    
    self.webSocketTransport.clientName = splitName
    self.httpTransport.clientName = splitName
    
    XCTAssertEqual(self.splitTransport.clientName, splitName)
  }
  
  func testGettingSplitClientVersionWithTheSameVersions() {
    let splitVersion = "TestSplitClientVersion"
    
    self.webSocketTransport.clientVersion = splitVersion
    self.httpTransport.clientVersion = splitVersion
    
    XCTAssertEqual(self.splitTransport.clientVersion, splitVersion)
  }
}
