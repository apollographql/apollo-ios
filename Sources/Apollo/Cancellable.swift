import Foundation

/// An object that can be used to cancel an in progress action.
public protocol Cancellable: class {
    /// Cancel an in progress action.
    func cancel()
}

// MARK: - URL Session Conformance

extension URLSessionTask: Cancellable {}

/// A class to return when an error that should cause us to bail out of something still needs to return `Cancellable`.
public final class ErrorCancellable: Cancellable {
  
  public init() {}
  
  public func cancel() {
    // Do nothing, an error occured and there is nothing to cancel.
  }
}



