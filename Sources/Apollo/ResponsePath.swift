/// A response path is stored as a linked list because using an array turned out to be
/// a performance bottleneck during decoding/execution.
struct ResponsePath: ExpressibleByArrayLiteral {
  typealias Key = String

  private final class Node {
    let previous: Node?
    let key: Key

    init(previous: Node?, key: Key) {
      self.previous = previous
      self.key = key
    }

    lazy var joined: String = {
      if let previous = previous {
        return previous.joined + ".\(key)"
      } else {
        return key
      }
    }()
  }

  private var head: Node?
  var joined: String {
    return head?.joined ?? ""
  }

  init(arrayLiteral segments: Key...) {
    for segment in segments {
      append(segment)
    }
  }

  mutating func append(_ key: Key) {
    head = Node(previous: head, key: key)
  }

  func appending(_ key: Key) -> ResponsePath {
    var copy = self
    copy.append(key)
    return copy
  }

  static func + (lhs: ResponsePath, rhs: Key) -> ResponsePath {
    lhs.appending(rhs)
  }
}

extension ResponsePath: CustomStringConvertible {
  var description: String {
    return joined
  }
}

extension ResponsePath: Equatable {
  static func == (lhs: ResponsePath, rhs: ResponsePath) -> Bool {
    return lhs.joined == rhs.joined
  }
}
