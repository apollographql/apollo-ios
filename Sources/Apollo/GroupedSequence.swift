struct GroupedSequence<Key: Equatable, Value> {
  private(set) var keys: [Key] = []
  fileprivate var groupsForKeys: [[Value]] = []

  mutating func append(value: Value, forKey key: Key) -> (Int, Int) {
    if let index = keys.firstIndex(where: { $0 == key }) {
      groupsForKeys[index].append(value)
      return (index, groupsForKeys[index].endIndex - 1)
    } else {
      keys.append(key)
      groupsForKeys.append([value])
      return (keys.endIndex - 1, 0)
    }
  }
}

extension GroupedSequence: Sequence {
  func makeIterator() -> GroupedSequenceIterator<Key, Value> {
    return GroupedSequenceIterator(base: self)
  }
}

struct GroupedSequenceIterator<Key: Equatable, Value>: IteratorProtocol {
  private var base: GroupedSequence<Key, Value>

  private var keyIterator: EnumeratedSequence<Array<Key>>.Iterator

  init(base: GroupedSequence<Key, Value>) {
    self.base = base
    keyIterator = base.keys.enumerated().makeIterator()
  }

  mutating func next() -> (Key, [Value])? {
    if let (index, key) = keyIterator.next() {
      let values = base.groupsForKeys[index]
      return (key, values)
    } else {
      return nil
    }
  }
}
