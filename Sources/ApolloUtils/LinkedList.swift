/// A linked list implementation.
///
/// This implementation utilizes copy on write semantics and is optimized for forward traversal
/// and appending items (which requires accessing last).
///
/// It is not optimized for backwards traversal or prepending items.
public struct LinkedList<T>: ExpressibleByArrayLiteral {
  public class Node {
    let value: T
    var next: Node?

    init(value: T) {
      self.value = value
    }
  }

  final class HeadNode: Node {
    private var lastPointer: Node?

    var last: Node {
      get {
        lastPointer ?? self
      }
      set {
        guard newValue !== self else { return }
        lastPointer = newValue
      }
    }

    func copy() -> HeadNode {
      let copiedHead = HeadNode(value: self.value)

      var currentNode: Node? = self
      var currentCopy: Node? = copiedHead

      while let nextNode = currentNode?.next {
        let nextCopy = Node(value: nextNode.value)
        currentCopy?.next = nextCopy

        currentNode = nextNode
        currentCopy = nextCopy
      }

      copiedHead.lastPointer = currentNode
      return copiedHead
    }
  }

  private var headNode: HeadNode

  /// The head (first) node in the list
  var head: Node { headNode }

  /// The last node in the list
  public var last: Node { headNode.last }

  private init(head: HeadNode) {
    self.headNode = head
  }

  public init(arrayLiteral segments: T...) {
    var segments = segments
    let headNode = HeadNode(value: segments.removeFirst())

    self.init(head: headNode)

    for segment in segments {
      append(segment)
    }
  }

  mutating func append(_ value: T) {
    append(Node(value: value))
  }

  mutating func append(_ node: Node) {
    if !isKnownUniquelyReferenced(&headNode) {
      headNode = headNode.copy()
    }
    last.next = node
    headNode.last = node
  }

}
