import Foundation

/// The GraphQL over WebSocket protocols supported by apollo-ios.
public enum WebSocketProtocol: CustomStringConvertible {
  /// WebSocket protocol `graphql-ws`. This is implemented by the [subscriptions-transport-ws](https://github.com/apollographql/subscriptions-transport-ws)
  /// and AWS AppSync libraries.
  case graphql_ws
  /// WebSocket protocol `graphql-transport-ws`. This is implemented by the [graphql-ws](https://github.com/enisdenjo/graphql-ws)
  /// library.
  case graphql_transport_ws

  public var description: String {
    switch self {
    case .graphql_ws: return "graphql-ws"
    case .graphql_transport_ws: return "graphql-transport-ws"
    }
  }
}
