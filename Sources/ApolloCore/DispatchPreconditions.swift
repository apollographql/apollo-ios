import Dispatch

@inlinable public func ensureOnQueueIfPossible(_ queue: DispatchQueue) {
  if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
    dispatchPrecondition(condition: .onQueue(queue))
  }
}

@inlinable public func ensureNotOnQueueIfPossible(_ queue: DispatchQueue) {
  if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
    dispatchPrecondition(condition: .notOnQueue(queue))
  }
}
