public extension Dictionary {
  static func += (lhs: inout Dictionary, rhs: Dictionary) {
    lhs.merge(rhs) { (_, new) in new }
  }
}

extension Dictionary {
  init<S: Sequence>(_ entries: S) where S.Iterator.Element == Element {
    self = Dictionary(minimumCapacity: entries.underestimatedCount)
    for (key, value) in entries {
      self[key] = value
    }
  }
}
