/// A doubly linked list implementation.
///
/// This implementation utilizes copy on write semantics and is optimized for forward and backwards
/// traversal and appending items (which requires accessing last).
///
/// It is not optimized for prepending or insertion of items.
public struct LinkedList<T>: ExpressibleByArrayLiteral {
  public class Node {
    public let value: T
    fileprivate let index: Int

    public fileprivate(set) weak var previous: Node?
    public fileprivate(set) var next: Node? {
      didSet {
        next?.previous = self
        oldValue?.previous = nil
      }
    }

    fileprivate init(value: T, index: Int) {
      self.value = value
      self.index = index
    }
  }

  final class HeadNode: Node {
    fileprivate var lastPointer: Node?

    var last: Node! {
      get {
        lastPointer ?? self
      }
      set {
        guard newValue !== self else { return }
        lastPointer = newValue
      }
    }

    fileprivate init(value: T) {
      super.init(value: value, index: 0)
    }

    func copy() -> HeadNode {
      let copiedHead = HeadNode(value: self.value)

      var currentNode: Node? = self
      var currentCopy: Node? = copiedHead

      while let nextNode = currentNode?.next {
        let nextCopy = Node(value: nextNode.value, index: nextNode.index)
        currentCopy?.next = nextCopy

        currentNode = nextNode
        currentCopy = nextCopy
      }

      copiedHead.last = currentCopy
      return copiedHead
    }
  }

  private var headNode: HeadNode

  /// The head (first) node in the list
  public var head: Node { headNode }

  /// The last node in the list
  public var last: Node { headNode.last }

  private init(head: HeadNode) {
    self.headNode = head
  }

  public init(_ headValue: T) {    
    self.init(head: HeadNode(value: headValue))
  }

  public init(array: [T]) {
    var segments = array
    let headNode = HeadNode(value: segments.removeFirst())

    self.init(head: headNode)

    for segment in segments {
      append(segment)
    }
  }

  public init(arrayLiteral segments: T...) {
    self.init(array: segments)
  }

  private func copy() -> Self {
    return Self.init(head: headNode.copy())
  }

  public mutating func append(_ value: T) {
    append(Node(value: value, index: last.index + 1))
  }

  private mutating func append(_ node: Node) {
    copyOnWriteIfNeeded()
    last.next = node
    headNode.last = node
  }

  public mutating func append<S: Sequence>(_ sequence: S) where S.Element == T {
    copyOnWriteIfNeeded()
    var last: Node = last

    for element in sequence {
      let node = Node(value: element, index: last.index + 1)
      last.next = node
      last = node
    }

    headNode.last = last
  }

  private mutating func copyOnWriteIfNeeded() {
    if !isKnownUniquelyReferenced(&headNode) {
      headNode = headNode.copy()
    }
  }

  public func appending(_ value: T) -> LinkedList<T> {
    var copy = self.copy()
    copy.append(value)
    return copy
  }

  public func appending<S: Sequence>(
    _ sequence: S
  ) -> LinkedList<T> where S.Element == T {
    var copy = self.copy()
    copy.append(sequence)
    return copy
  }

  public mutating func mutateLast(_ mutate: (T) -> T) {
    copyOnWriteIfNeeded()

    if let last = headNode.lastPointer {
      let newLast = Node(value: mutate(last.value), index: last.index)
      last.previous!.next = newLast
      headNode.last = newLast

    } else {
      headNode = HeadNode(value: mutate(headNode.value))
    }
  }

  public func mutatingLast(_ mutate: (T) -> T) -> LinkedList<T> {
    var copy = self.copy()
    copy.mutateLast(mutate)
    return copy
  }

}

extension LinkedList.Node: Equatable where T: Equatable {
  public static func == (lhs: LinkedList<T>.Node, rhs: LinkedList<T>.Node) -> Bool {
    lhs.value == rhs.value &&
    lhs.next == rhs.next
  }
}

extension LinkedList: Equatable where T: Equatable {
  public static func == (lhs: LinkedList<T>, rhs: LinkedList<T>) -> Bool {
    lhs.headNode == rhs.headNode
  }
}

extension LinkedList.Node: Hashable where T: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
    hasher.combine(next)
  }
}

extension LinkedList: Hashable where T: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(headNode)
  }
}

// MARK: - Collection Conformance

extension LinkedList: Collection {

  public var startIndex: Int { 0 }

  public var endIndex: Int { last.index + 1 }

  public var count: Int { endIndex }

  public var isEmpty: Bool { false }

  public subscript(position: Int) -> T {
    _read {
      let traverseFromFront = position <= last.index / 2
      let numberOfIndiciesToTarget = traverseFromFront ? position : last.index - position

      var node = traverseFromFront ? head : last
      for _ in 0..<numberOfIndiciesToTarget {
        node = traverseFromFront ? node.next.unsafelyUnwrapped : node.previous.unsafelyUnwrapped
      }
      yield node.value
    }
  }

  public func index(after i: Int) -> Int {
    i + 1
  }

}

// MARK: - Sequence Conformance

extension LinkedList: Sequence {
  public typealias Element = T

  public class Iterator: IteratorProtocol {
    var currentNode: Node?

    init(_ list: LinkedList) {
      currentNode = list.headNode
    }

    public func next() -> Element? {
      let next = currentNode?.next
      defer { currentNode = next }
      return currentNode?.value
    }
  }

  public func makeIterator() -> Iterator {
    Iterator(self)
  }
}

extension LinkedList: CustomDebugStringConvertible where T: CustomDebugStringConvertible {
  public var debugDescription: String {
    "[\(headNode.debugDescription)]"
  }
}

extension LinkedList.Node: CustomDebugStringConvertible {
  public var debugDescription: String {
    var string = "\(value)"
    if let next = next {
      string += " -> \(next.debugDescription)"
    }
    return string
  }
}
