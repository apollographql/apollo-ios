//  Created by Dalton Cherry on 7/16/14.
//  Copyright (c) 2014-2017 Dalton Cherry.
//  Modified by Anthony Miller & Apollo GraphQL on 8/12/21
//
//  This is a derived work derived from
//  Starscream (https://github.com/daltoniam/Starscream)
//
//  Original Work License: http://www.apache.org/licenses/LICENSE-2.0
//  Derived Work License: https://github.com/apollographql/apollo-ios/blob/main/LICENSE

import Foundation

protocol WebSocketStreamDelegate: AnyObject {
  func newBytesInStream()
  func streamDidError(error: Error?)
}

// This protocol is to allow custom implemention of the underlining stream.
// This way custom socket libraries (e.g. linux) can be used
protocol WebSocketStream {
  var delegate: WebSocketStreamDelegate? { get set }

  func connect(url: URL,
               port: Int,
               timeout: TimeInterval,
               ssl: SSLSettings,
               completion: @escaping ((Error?) -> Void))

  func write(data: Data) -> Int
  func read() -> Data?
  func cleanup()

  #if os(Linux) || os(watchOS)
  #else
  func sslTrust() -> (trust: SecTrust?, domain: String?)
  #endif
}

class FoundationStream : NSObject, WebSocketStream, StreamDelegate  {
  private let workQueue = DispatchQueue(label: "com.apollographql.websocket", attributes: [])
  private var inputStream: InputStream?
  private var outputStream: OutputStream?
  weak var delegate: WebSocketStreamDelegate?
  let BUFFER_MAX = 4096

  var enableSOCKSProxy = false

  func connect(url: URL, port: Int, timeout: TimeInterval, ssl: SSLSettings, completion: @escaping ((Error?) -> Void)) {
    var readStream: Unmanaged<CFReadStream>?
    var writeStream: Unmanaged<CFWriteStream>?
    let h = url.host! as NSString
    CFStreamCreatePairWithSocketToHost(nil, h, UInt32(port), &readStream, &writeStream)
    inputStream = readStream!.takeRetainedValue()
    outputStream = writeStream!.takeRetainedValue()

    #if os(watchOS) //watchOS us unfortunately is missing the kCFStream properties to make this work
    #else
    if enableSOCKSProxy {
      let proxyDict = CFNetworkCopySystemProxySettings()
      let socksConfig = CFDictionaryCreateMutableCopy(nil, 0, proxyDict!.takeRetainedValue())
      let propertyKey = CFStreamPropertyKey(rawValue: kCFStreamPropertySOCKSProxy)
      CFWriteStreamSetProperty(outputStream, propertyKey, socksConfig)
      CFReadStreamSetProperty(inputStream, propertyKey, socksConfig)
    }
    #endif

    guard let inStream = inputStream, let outStream = outputStream else { return }
    inStream.delegate = self
    outStream.delegate = self
    if ssl.useSSL {
      inStream.setProperty(StreamSocketSecurityLevel.negotiatedSSL as AnyObject, forKey: Stream.PropertyKey.socketSecurityLevelKey)
      outStream.setProperty(StreamSocketSecurityLevel.negotiatedSSL as AnyObject, forKey: Stream.PropertyKey.socketSecurityLevelKey)
      #if os(watchOS) //watchOS us unfortunately is missing the kCFStream properties to make this work
      #else
      var settings = [NSObject: NSObject]()
      if ssl.disableCertValidation {
        settings[kCFStreamSSLValidatesCertificateChain] = NSNumber(value: false)
      }
      if ssl.overrideTrustHostname {
        if let hostname = ssl.desiredTrustHostname {
          settings[kCFStreamSSLPeerName] = hostname as NSString
        } else {
          settings[kCFStreamSSLPeerName] = kCFNull
        }
      }
      if let sslClientCertificate = ssl.sslClientCertificate {
        settings[kCFStreamSSLCertificates] = sslClientCertificate.streamSSLCertificates
      }

      inStream.setProperty(settings, forKey: kCFStreamPropertySSLSettings as Stream.PropertyKey)
      outStream.setProperty(settings, forKey: kCFStreamPropertySSLSettings as Stream.PropertyKey)
      #endif

      #if os(Linux)
      #else
      if let cipherSuites = ssl.cipherSuites {
        #if os(watchOS) //watchOS us unfortunately is missing the kCFStream properties to make this work
        #else
        if let sslContextIn = CFReadStreamCopyProperty(inputStream, CFStreamPropertyKey(rawValue: kCFStreamPropertySSLContext)) as! SSLContext?,
           let sslContextOut = CFWriteStreamCopyProperty(outputStream, CFStreamPropertyKey(rawValue: kCFStreamPropertySSLContext)) as! SSLContext? {
          let resIn = SSLSetEnabledCiphers(sslContextIn, cipherSuites, cipherSuites.count)
          let resOut = SSLSetEnabledCiphers(sslContextOut, cipherSuites, cipherSuites.count)
          if resIn != errSecSuccess {
            completion(WebSocket.WSError(
                        type: .invalidSSLError,
                        message: "Error setting ingoing cypher suites",
                        code: Int(resIn)))
          }
          if resOut != errSecSuccess {
            completion(WebSocket.WSError(
                        type: .invalidSSLError,
                        message: "Error setting outgoing cypher suites",
                        code: Int(resOut)))
          }
        }
        #endif
      }
      #endif
    }

    CFReadStreamSetDispatchQueue(inStream, workQueue)
    CFWriteStreamSetDispatchQueue(outStream, workQueue)
    inStream.open()
    outStream.open()

    var out = timeout// wait X seconds before giving up
    workQueue.async { [weak self] in
      while !outStream.hasSpaceAvailable {
        usleep(100) // wait until the socket is ready
        out -= 100
        if out < 0 {
          completion(
            WebSocket.WSError(
              type: .writeTimeoutError,
              message: "Timed out waiting for the socket to be ready for a write",
              code: 0))
          return

        } else if let error = outStream.streamError {
          completion(error)
          return // disconnectStream will be called.

        } else if self == nil {
          completion(WebSocket.WSError(
                      type: .closeError,
                      message: "socket object has been dereferenced",
                      code: 0))
          return
        }
      }
      completion(nil) //success!
    }
  }

  func write(data: Data) -> Int {
    guard let outStream = outputStream else {return -1}
    let buffer = UnsafeRawPointer((data as NSData).bytes).assumingMemoryBound(to: UInt8.self)
    return outStream.write(buffer, maxLength: data.count)
  }

  func read() -> Data? {
    guard let stream = inputStream else {return nil}
    let buf = NSMutableData(capacity: BUFFER_MAX)
    let buffer = UnsafeMutableRawPointer(mutating: buf!.bytes).assumingMemoryBound(to: UInt8.self)
    let length = stream.read(buffer, maxLength: BUFFER_MAX)
    if length < 1 {
      return nil
    }
    return Data(bytes: buffer, count: length)
  }

  func cleanup() {
    if let stream = inputStream {
      stream.delegate = nil
      CFReadStreamSetDispatchQueue(stream, nil)
      stream.close()
    }
    if let stream = outputStream {
      stream.delegate = nil
      CFWriteStreamSetDispatchQueue(stream, nil)
      stream.close()
    }
    outputStream = nil
    inputStream = nil
  }

  #if os(Linux) || os(watchOS)
  #else
  func sslTrust() -> (trust: SecTrust?, domain: String?) {
    guard let outputStream = outputStream else { return (nil, nil) }

    let trust = outputStream.property(forKey: kCFStreamPropertySSLPeerTrust as Stream.PropertyKey) as! SecTrust?
    var domain = outputStream.property(forKey: kCFStreamSSLPeerName as Stream.PropertyKey) as! String?
    if domain == nil,
       let sslContextOut = CFWriteStreamCopyProperty(outputStream, CFStreamPropertyKey(rawValue: kCFStreamPropertySSLContext)) as! SSLContext? {
      var peerNameLen: Int = 0
      SSLGetPeerDomainNameLength(sslContextOut, &peerNameLen)
      var peerName = Data(count: peerNameLen)
      let _ = peerName.withUnsafeMutableBytes { ptr in
        guard let ptr = ptr.baseAddress?.assumingMemoryBound(to: Int8.self) else { return }
        SSLGetPeerDomainName(sslContextOut, ptr, &peerNameLen)
      }

      if let peerDomain = String(bytes: peerName, encoding: .utf8), peerDomain.count > 0 {
        domain = peerDomain
      }
    }

    return (trust, domain)
  }
  #endif

  /**
   Delegate for the stream methods. Processes incoming bytes
   */
  open func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    if eventCode == .hasBytesAvailable {
      if aStream == inputStream {
        delegate?.newBytesInStream()
      }
    } else if eventCode == .errorOccurred {
      delegate?.streamDidError(error: aStream.streamError)
    } else if eventCode == .endEncountered {
      delegate?.streamDidError(error: nil)
    }
  }
}
