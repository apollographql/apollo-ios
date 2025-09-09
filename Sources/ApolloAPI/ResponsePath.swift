/// Represents a list of string components joined into a path using a reverse linked list.
///
/// A response path is stored as a linked list because using an array turned out to be
/// a performance bottleneck during decoding/execution.
///
/// In order to optimize for calculation of a path string, `ResponsePath` does not allow insertion
/// of components in the middle or at the beginning of the path. Components may only be appended to
/// the end of an existing path.
public struct ResponsePath: Sendable, ExpressibleByArrayLiteral {
  public typealias Key = String

  private final class Node: Sendable {
    let previous: Node?
    let key: Key
    let joined: String

    init(previous: Node?, key: Key) {
      self.previous = previous
      self.key = key

      self.joined = {
        if let previous = previous {
          return previous.joined + ".\(key)"
        } else {
          return key
        }
      }()
    }
  }

  private var head: Node?
  public var joined: String {
    return head?.joined ?? ""
  }

  public init(arrayLiteral segments: Key...) {
    for segment in segments {
      append(segment)
    }
  }

  public init(_ key: Key) {
    append(key)
  }

  public mutating func append(_ key: Key) {
    head = Node(previous: head, key: key)
  }

  public func appending(_ key: Key) -> ResponsePath {
    var copy = self
    copy.append(key)
    return copy
  }

  public var isEmpty: Bool {
    head == nil
  }

  public static func + (lhs: ResponsePath, rhs: Key) -> ResponsePath {
    lhs.appending(rhs)
  }
}

extension ResponsePath: CustomStringConvertible {
  public var description: String {
    return joined
  }
}

extension ResponsePath: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(joined)
  }
}

extension ResponsePath: Equatable {
  static public func == (lhs: ResponsePath, rhs: ResponsePath) -> Bool {
    return lhs.joined == rhs.joined
  }
}
