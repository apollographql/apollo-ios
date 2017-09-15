extension Dictionary {
  subscript(key: Key, withDefault value: @autoclosure () -> Value) -> Value {
    mutating get {
      if self[key] == nil {
        self[key] = value()
      }
      return self[key]!
    }
    set {
      self[key] = newValue
    }
  }
}

public extension Dictionary {
  static func += (lhs: inout Dictionary, rhs: Dictionary) {
    #if swift(>=3.2)
    lhs.merge(rhs) { (_, new) in new }
    #else
    for (key, value) in rhs {
      lhs[key] = value
    }
    #endif
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

struct GroupedSequence<Key: Equatable, Value> {
  private(set) var keys: [Key] = []
  fileprivate var groupsForKeys: [[Value]] = []
  
  mutating func append(value: Value, forKey key: Key) -> (Int, Int) {
    if let index = keys.index(where: { $0 == key }) {
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
  
  private var keyIterator: EnumeratedIterator<IndexingIterator<Array<Key>>>
  
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

public func unzip<Element1, Element2>(_ array: [(Element1, Element2)]) -> ([Element1], [Element2]) {
  var array1: [Element1] = []
  var array2: [Element2] = []
  
  for element in array {
    array1.append(element.0)
    array2.append(element.1)
  }
  
  return (array1, array2)
}

public func unzip<Element1, Element2, Element3>(_ array: [(Element1, Element2, Element3)]) -> ([Element1], [Element2], [Element3]) {
  var array1: [Element1] = []
  var array2: [Element2] = []
  var array3: [Element3] = []
  
  for element in array {
    array1.append(element.0)
    array2.append(element.1)
    array3.append(element.2)
  }
  
  return (array1, array2, array3)
}

public func unzip<Element>(_ array: [[Element]], count: Int) -> [[Element]] {  
  var unzippedArray: [[Element]] = Array(repeating: [], count: count)
  
  for valuesForElement in array {
    for (index, value) in valuesForElement.enumerated() {
      unzippedArray[index].append(value)
    }
  }
  
  return unzippedArray
}
