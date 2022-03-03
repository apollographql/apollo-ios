import Foundation
#if !COCOAPODS
import ApolloUtils
#endif

public protocol OperationMessageIdCreator {
  func requestId() -> String
}

// MARK: - Default Implementation

/// The default implementation of `OperationMessageIdCreator` that uses a sequential numbering scheme.
public struct ApolloSequencedOperationMessageIdCreator: OperationMessageIdCreator {
  private var sequenceNumberCounter = Atomic<Int>(0)

  /// Designated initializer.
  ///
  /// - Parameter startAt: The number from which the sequenced numbering scheme should start.
  public init(startAt sequenceNumber: Int = 1) {
    sequenceNumberCounter = Atomic<Int>(sequenceNumber)
  }

  /// Returns the number in the current sequence. Will be incremented when calling this method.
  public func requestId() -> String {
    let id = sequenceNumberCounter.value
    _ = sequenceNumberCounter.increment()

    return "\(id)"
  }
}
