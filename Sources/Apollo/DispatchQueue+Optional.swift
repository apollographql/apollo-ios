import Dispatch

extension DispatchQueue {

  @available(*, deprecated)
  static func performAsyncIfNeeded(
    on callbackQueue: DispatchQueue?,
    action: @escaping @Sendable () -> Void
  ) {
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

  @available(*, deprecated)
  static func returnResultAsyncIfNeeded<T: Sendable>(
    on callbackQueue: DispatchQueue?,
    action: (@Sendable (Result<T, any Swift.Error>) -> Void)?,
    result: Result<T, any Swift.Error>
  ) {
      if let action = action {
        self.performAsyncIfNeeded(on: callbackQueue) {
          action(result)
        }
      } else if case .failure(let error) = result {
        debugPrint("Apollo: Encountered failure result, but no completion handler was defined to handle it: \(error)")
      }
  }

}
