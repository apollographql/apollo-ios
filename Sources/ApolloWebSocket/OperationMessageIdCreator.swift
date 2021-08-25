import Foundation
#if !COCOAPODS
import ApolloUtils
#endif

public protocol OperationMessageIdCreator {
  func requestId() -> String
}

// MARK: - Default Implementation

public struct ApolloSequencedOperationMessageIdCreator: OperationMessageIdCreator {
  private var sequenceNumberCounter = Atomic<Int>(0)
  
  // Internal init methods cannot be used in public methods
  public init(startAt sequenceNumber: Int = 1) {
    sequenceNumberCounter = Atomic<Int>(sequenceNumber)
  }
  
  public func requestId() -> String {
    let id = sequenceNumberCounter.value
    _ = sequenceNumberCounter.increment()

    return "\(id)"
  }
}
