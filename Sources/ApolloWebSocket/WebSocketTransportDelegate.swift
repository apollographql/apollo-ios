import ApolloAPI
import Foundation

/// A delegate that receives lifecycle events from a ``WebSocketTransport``.
///
/// All delegate methods receive the ``WebSocketTransport`` as an `isolated` parameter. This
/// means the transport **awaits** each delegate call before continuing its receive loop,
/// giving you a synchronization point to inspect or mutate transport state without race
/// conditions.
///
/// If your delegate implementation is lightweight (e.g. logging), simply implement the
/// methods directly. If you need to perform work that should **not** block the transport,
/// dispatch a `Task` inside your implementation:
///
/// ```swift
/// func webSocketTransportDidConnect(_ transport: isolated WebSocketTransport) {
///   Task { await self.updateUI() }
/// }
/// ```
///
/// Default no-op implementations are provided for all methods, so you only need to
/// implement the ones you care about.
public protocol WebSocketTransportDelegate: AnyObject {

  /// Called when the transport successfully establishes a connection and receives
  /// `connection_ack` from the server.
  func webSocketTransportDidConnect(
    _ webSocketTransport: isolated WebSocketTransport
  )

  /// Called when the transport successfully reconnects after a previous disconnection
  /// and receives `connection_ack` from the server.
  func webSocketTransportDidReconnect(
    _ webSocketTransport: isolated WebSocketTransport
  )

  /// Called when the transport disconnects from the server.
  ///
  /// - Parameter error: The error that caused the disconnection, or `nil` for a
  ///   clean disconnection (e.g. stream ended normally or task was cancelled).
  func webSocketTransport(
    _ webSocketTransport: isolated WebSocketTransport,
    didDisconnectWithError error: (any Error)?
  )

  /// Called when the transport receives a `ping` message from the server.
  ///
  /// The transport automatically responds with a `pong` message as required by the
  /// `graphql-transport-ws` protocol. This callback is informational only.
  ///
  /// - Parameter payload: The optional payload included in the ping message.
  func webSocketTransport(
    _ webSocketTransport: isolated WebSocketTransport,
    didReceivePingWithPayload payload: JSONObject?
  )

  /// Called when the transport receives a `pong` message from the server.
  ///
  /// - Parameter payload: The optional payload included in the pong message.
  func webSocketTransport(
    _ webSocketTransport: isolated WebSocketTransport,
    didReceivePongWithPayload payload: JSONObject?
  )
}

// MARK: - Default Implementations

public extension WebSocketTransportDelegate {

  func webSocketTransportDidConnect(
    _ webSocketTransport: isolated WebSocketTransport
  ) {}

  func webSocketTransportDidReconnect(
    _ webSocketTransport: isolated WebSocketTransport
  ) {}

  func webSocketTransport(
    _ webSocketTransport: isolated WebSocketTransport,
    didDisconnectWithError error: (any Error)?
  ) {}

  func webSocketTransport(
    _ webSocketTransport: isolated WebSocketTransport,
    didReceivePingWithPayload payload: JSONObject?
  ) {}

  func webSocketTransport(
    _ webSocketTransport: isolated WebSocketTransport,
    didReceivePongWithPayload payload: JSONObject?
  ) {}
}
