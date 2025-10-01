import Foundation

/// A protocol for a networking session used by Apollo to execute network requests.
///
/// This protocol allows you to provide a custom networking implementation to Apollo.
///
/// For ease of use, `URLSession` already conforms to this protocol. You may configure a custom `URLSession` and
/// implement your own delegate.
public protocol ApolloURLSession: Sendable {

  /// Returns a data stream of the response chunks for the request.
  ///
  /// For a multi-part response, each element emitted by the ``AsyncChunkSequence`` should be the `Data` for an
  /// individual chunked part of the response.
  ///
  /// - Parameter request: The `URLRequest` to load data for.
  /// - Returns: An async stream of data chunks and the `URLResponse` for the request.
  func chunks(for request: URLRequest) async throws -> (any AsyncChunkSequence, URLResponse)
}

extension URLSession: ApolloURLSession {
  public func chunks(for request: URLRequest) async throws -> (any AsyncChunkSequence, URLResponse) {
    try Task.checkCancellation()
    let (bytes, response) = try await bytes(for: request, delegate: nil)
    return (bytes.chunks, response)
  }
}
