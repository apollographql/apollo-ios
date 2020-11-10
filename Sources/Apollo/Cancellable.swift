import Foundation

/// An object that can be used to cancel an in progress action.
public protocol Cancellable: class {
    /// Cancel an in progress action.
    func cancel()
}

// MARK: - URL Session Conformance

extension URLSessionTask: Cancellable {}

// MARK: - Early-Exit Helper

/// A class to return when we need to bail out of something which still needs to return `Cancellable`.
public final class EmptyCancellable: Cancellable {

  // Needs to be public so this can be instantiated outside of the current framework.
  public init() {}

  public func cancel() {
    // Do nothing, an error occurred and there is nothing to cancel.
  }
}
