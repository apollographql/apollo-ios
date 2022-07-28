import Foundation
#if !COCOAPODS
import Apollo
#endif

public protocol OperationMessageIdCreator {
  func requestId() -> String
}

// MARK: - Default Implementation

/// The default implementation of `OperationMessageIdCreator` that uses a sequential numbering scheme.
public struct ApolloSequencedOperationMessageIdCreator: OperationMessageIdCreator {
  @Atomic private var sequenceNumberCounter: Int = 0

  /// Designated initializer.
  ///
  /// - Parameter startAt: The number from which the sequenced numbering scheme should start.
  public init(startAt sequenceNumber: Int = 1) {
    _sequenceNumberCounter = Atomic<Int>(wrappedValue: sequenceNumber)
  }

  /// Returns the number in the current sequence. Will be incremented when calling this method.
  public func requestId() -> String {
    let id = sequenceNumberCounter
    _ = $sequenceNumberCounter.increment()

    return "\(id)"
  }
}
