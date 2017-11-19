public final class CancelController: Cancellable {
  public let signal = CancelSignal()
  
  public func cancel() {
    signal.cancel()
  }
}

public final class CancelSignal {
  private let promise: Promise<Void>
  private let fulfill: (() -> Void)
  
  fileprivate init() {
    var _fulfill: (() -> Void)!
    promise = Promise { (fulfill, _) in
      _fulfill = fulfill
    }
    
    fulfill = _fulfill
  }
  
  fileprivate func cancel() {
    fulfill()
  }
  
  public var isCancelled: Bool {
    return !promise.isPending
  }
  
  public func onCancel(_ whenCancelled: @escaping () -> Void) {
    promise.andThen(whenCancelled)
  }
}

public struct CancelError: Error {
}

