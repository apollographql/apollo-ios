import Foundation

public protocol WebSocketURLSession: Sendable {

 func webSocketTask(with request: URLRequest) -> URLSessionWebSocketTask

}

extension URLSession: WebSocketURLSession {}
