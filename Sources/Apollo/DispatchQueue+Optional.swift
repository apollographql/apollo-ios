import Foundation
#if !COCOAPODS
import ApolloCore
#endif

extension DispatchQueue: ApolloCompatible {}

public extension ApolloExtension where Base == DispatchQueue {

  static func performAsyncIfNeeded(on callbackQueue: DispatchQueue?, action: @escaping () -> Void) {
    if let callbackQueue = callbackQueue {
      // A callback queue was provided, perform the action on that queue
      callbackQueue.async {
        action()
      }
    } else {
      // Perform the action on the current queue
      action()
    }
  }

  static func returnResultAsyncIfNeeded<T>(on callbackQueue: DispatchQueue?,
                                           action: ((Result<T, Error>) -> Void)?,
                                           result: Result<T, Error>) {
    if let action = action {
      self.performAsyncIfNeeded(on: callbackQueue) {
        action(result)
      }
    } else if case .failure(let error) = result {
      assertionFailure("Encountered failure result, but no completion handler was defined to handle it: \(error)")
    }
  }
}
