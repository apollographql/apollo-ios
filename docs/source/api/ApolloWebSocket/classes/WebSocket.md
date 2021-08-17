**CLASS**

# `WebSocket`

```swift
public final class WebSocket: NSObject, WebSocketClient, StreamDelegate, WebSocketStreamDelegate
```

## Properties
### `delegate`

```swift
public weak var delegate: WebSocketClientDelegate?
```

Responds to callback about new messages coming in over the WebSocket
and also connection/disconnect messages.

### `callbackQueue`

```swift
public var callbackQueue = DispatchQueue.main
```

### `onConnect`

```swift
public var onConnect: (() -> Void)?
```

### `onDisconnect`

```swift
public var onDisconnect: ((Error?) -> Void)?
```

### `onText`

```swift
public var onText: ((String) -> Void)?
```

### `onData`

```swift
public var onData: ((Data) -> Void)?
```

### `onPong`

```swift
public var onPong: ((Data?) -> Void)?
```

### `onHttpResponseHeaders`

```swift
public var onHttpResponseHeaders: (([String: String]) -> Void)?
```

### `disableSSLCertValidation`

```swift
public var disableSSLCertValidation = false
```

### `overrideTrustHostname`

```swift
public var overrideTrustHostname = false
```

### `desiredTrustHostname`

```swift
public var desiredTrustHostname: String? = nil
```

### `sslClientCertificate`

```swift
public var sslClientCertificate: SSLClientCertificate? = nil
```

### `enableCompression`

```swift
public var enableCompression = true
```

### `security`

```swift
public var security: SSLTrustValidator?
```

### `enabledSSLCipherSuites`

```swift
public var enabledSSLCipherSuites: [SSLCipherSuite]?
```

### `isConnected`

```swift
public var isConnected: Bool
```

### `request`

```swift
public var request: URLRequest
```

### `currentURL`

```swift
public var currentURL: URL
```

### `respondToPingWithPong`

```swift
public var respondToPingWithPong: Bool = true
```

## Methods
### `init(request:)`

```swift
public init(request: URLRequest)
```

Used for setting protocols.

### `init(url:)`

```swift
public convenience init(url: URL)
```

### `init(url:writeQueueQOS:)`

```swift
public convenience init(url: URL, writeQueueQOS: QualityOfService)
```

### `connect()`

```swift
public func connect()
```

Connect to the WebSocket server on a background thread.

### `disconnect()`

```swift
public func disconnect()
```

### `write(string:)`

```swift
public func write(string: String)
```

### `write(ping:completion:)`

```swift
public func write(ping: Data, completion: (() -> ())? = nil)
```

Write a ping to the websocket. This sends it as a control frame.

### `newBytesInStream()`

```swift
public func newBytesInStream()
```

Delegate for the stream methods. Processes incoming bytes

### `streamDidError(error:)`

```swift
public func streamDidError(error: Error?)
```

### `deinit`

```swift
deinit
```
