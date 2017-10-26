
/// Wraps a promised cancellable as a normal cancellable.
public class PromisedCancellable: Cancellable {
  /// The cancellable promise.
  internal let promise: Promise<Cancellable>
  
  /// Whether the promised cancellable has been cancelled.
  private var isCancelledValue: Bool = false
  
  /// Mutex to protect the access to `isCancelledValue`.
  private var mutex = Mutex()
  
  /// Designated initializer.
  ///
  /// - Parameters:
  ///   - promise: The cancellable promise to wrap.
  public init(promise: Promise<Cancellable>) {
    self.promise = promise
  }
  
  /// Cancels the wrapped promise.
  public func cancel() {
    mutex.withLock {
      isCancelledValue = true
    }
    promise.andThen { $0.cancel() }
  }
  
  /// Whether the promised cancellable has been cancelled.
  public var isCancelled: Bool {
    get {
      return mutex.withLock { isCancelledValue }
    }
  }
}
