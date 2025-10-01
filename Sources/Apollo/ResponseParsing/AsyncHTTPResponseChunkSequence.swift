import Foundation

/// An `AsyncSequence` that emits `Data` for each chunk of a network response.
///
/// For a multi-part response, each element emitted by the sequence should be the `Data` for an individual chunked part
/// of the response.
public protocol AsyncChunkSequence: AsyncSequence, Sendable where Element == Data {
  
}

/// An ``AsyncChunkSequence`` implementation that parses the chunks of an HTTP multi-part response from a
/// `URLSession.AsyncBytes` data stream. It uses the multi-part boundary specified by the `HTTPURLResponse` to split
/// the data into chunks as it is received.
public struct AsyncHTTPResponseChunkSequence: AsyncChunkSequence {
  public typealias Element = Data

  private let bytes: URLSession.AsyncBytes
  
  /// Designated Initializer
  ///
  /// - Parameter bytes: The response byte stream to be seperated into multi-part chunks. Must be the result of an
  /// HTTP `URLRequest` to ensure that `bytes.task.response` is an `HTTPURLResponse`.
  public init(_ bytes: URLSession.AsyncBytes) {
    self.bytes = bytes
  }

  public func makeAsyncIterator() -> AsyncIterator {
    return AsyncIterator(bytes.makeAsyncIterator(), boundary: chunkBoundary)
  }

  private var chunkBoundary: String? {
    guard let response = bytes.task.response as? HTTPURLResponse else {
      return nil
    }

    return response.multipartHeaderComponents.boundary
  }

  public struct AsyncIterator: AsyncIteratorProtocol {
    public typealias Element = Data

    private var underlyingIterator: URLSession.AsyncBytes.AsyncIterator

    private let boundary: Data?

    private typealias Constants = MultipartResponseParsing

    init(
      _ underlyingIterator: URLSession.AsyncBytes.AsyncIterator,
      boundary: String?
    ) {
      self.underlyingIterator = underlyingIterator

      if let boundaryString = boundary?.data(using: .utf8) {
        self.boundary = Constants.Delimeter + boundaryString
      } else {
        self.boundary = nil
      }
    }

    public mutating func next() async throws -> Data? {
      var buffer = Data()

      while let next = try await self.underlyingIterator.next() {
        buffer.append(next)

        if let boundary,
           let boundaryRange = buffer.range(of: boundary, options: [.anchored, .backwards]) {
          buffer.removeSubrange(boundaryRange)

          formatAsChunk(&buffer)

          if !buffer.isEmpty {
            return buffer
          }
        }
      }

      formatAsChunk(&buffer)

      return buffer.isEmpty ? nil : buffer
    }

    private func formatAsChunk(_ buffer: inout Data) {
      if buffer.prefix(Constants.CRLF.count) == Constants.CRLF {
        buffer.removeFirst(Constants.CRLF.count)
      }

      if buffer == Constants.CloseDelimeter {
        buffer.removeAll()
      }
    }
  }
}

// MARK: - AsyncBytes.chunks helper function
extension URLSession.AsyncBytes {

  var chunks: AsyncHTTPResponseChunkSequence {
    return AsyncHTTPResponseChunkSequence(self)
  }

}
