import Foundation

public protocol ApolloURLSession: Sendable {
  func chunks(for request: some GraphQLRequest) async throws -> (any AsyncChunkSequence, URLResponse)

  func invalidateAndCancel()
}

extension URLSession: ApolloURLSession {
  public func chunks(for request: some GraphQLRequest) async throws -> (any AsyncChunkSequence, URLResponse) {
    try Task.checkCancellation()
    let (bytes, response) = try await bytes(for: request.toURLRequest(), delegate: nil)
    return (bytes.chunks, response)
  }
}
