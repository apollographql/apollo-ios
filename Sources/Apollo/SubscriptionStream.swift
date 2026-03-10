import Foundation

/// A stream of GraphQL subscription responses that also exposes the subscription's
/// current lifecycle ``state``.
///
/// `SubscriptionStream` conforms to `AsyncSequence`, so you can iterate over it
/// using `for try await`:
///
/// ```swift
/// let stream = try client.subscribe(subscription: MySubscription())
/// print(stream.state) // .pending
///
/// for try await response in stream {
///   print(stream.state) // .active
///   // process response
/// }
///
/// print(stream.state) // .finished(.completed)
/// ```
///
/// The ``state`` property reflects the subscription's position in its lifecycle
/// and is updated by the underlying transport. For WebSocket-based subscriptions,
/// this includes states like ``SubscriptionState/reconnecting`` and
/// ``SubscriptionState/paused`` that reflect the connection's health.
public struct SubscriptionStream<Element: Sendable>: AsyncSequence, Sendable {

  public struct AsyncIterator: AsyncIteratorProtocol {
    private var base: AsyncThrowingStream<Element, any Error>.AsyncIterator

    init(_ base: AsyncThrowingStream<Element, any Error>.AsyncIterator) {
      self.base = base
    }

    public mutating func next() async throws -> Element? {
      try await base.next()
    }
  }

  /// The underlying stream wrapped by the `SubscriptionStream`.
  public let stream: AsyncThrowingStream<Element, any Error>
  private let stateProvider: @Sendable () -> SubscriptionState

  /// The current lifecycle state of this subscription.
  ///
  /// This property is safe to read from any context. For WebSocket-based
  /// subscriptions, the state is updated by the transport as the subscription
  /// moves through its lifecycle.
  public var state: SubscriptionState {
    stateProvider()
  }

  /// Creates a subscription stream wrapping the given `AsyncThrowingStream`.
  ///
  /// - Parameters:
  ///   - stream: The underlying stream of elements.
  ///   - stateProvider: A closure that returns the current subscription state.
  package init(
    stream: AsyncThrowingStream<Element, any Error>,
    stateProvider: @escaping @Sendable () -> SubscriptionState
  ) {
    self.stream = stream
    self.stateProvider = stateProvider
  }

  public func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator(stream.makeAsyncIterator())
  }
}
