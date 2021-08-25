import Foundation
#if !COCOAPODS
import ApolloUtils
#endif

public protocol OperationMessageIdCreator {
  func requestId() -> String
}

// MARK: - Default Implementation

// Helper struct to create ids independently of HTTP operations.
public struct ApolloOperationMessageIdCreator: OperationMessageIdCreator {
  fileprivate let sequenceNumberCounter = Atomic<Int>(0)
  
  // Internal init methods cannot be used in public methods
  public init() { }
  
  public func requestId() -> String {
    return "\(sequenceNumberCounter.increment())"
  }
}
