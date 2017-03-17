// Based on https://oleb.net/blog/2017/01/dictionary-key-paths/

// TODO: Remove the StringProtocol workaround once Xcode 8.3 lands and we can use concrete same-type requirements

protocol StringProtocol {
  init(string: String)
}

extension String: StringProtocol {
  init(string: String) {
    self = string
  }
}

extension Dictionary where Key: StringProtocol {
  subscript(keyPath keyPath: KeyPath) -> Any? {
    get {
      switch keyPath.headAndTail() {
      case nil:
        // key path is empty.
        return nil
      case let (head, remainingKeyPath)? where remainingKeyPath.isEmpty:
        // Reached the end of the key path.
        let key = Key(string: head)
        return self[key]
      case let (head, remainingKeyPath)?:
        // Key path has a tail we need to traverse.
        let key = Key(string: head)
        switch self[key] {
        case let nestedDictionary as [Key: Any]:
          // Next nest level is a dictionary.
          // Start over with remaining key path.
          return nestedDictionary[keyPath: remainingKeyPath]
        default:
          // Next nest level isn't a dictionary.
          // Invalid key path, abort.
          return nil
        }
      }
    }
    
    set {
      switch keyPath.headAndTail() {
      case nil:
        // key path is empty.
        return
      case let (head, remainingKeyPath)? where remainingKeyPath.isEmpty:
        // Reached the end of the key path.
        let key = Key(string: head)
        self[key] = newValue as? Value
      case let (head, remainingKeyPath)?:
        let key = Key(string: head)
        let value = self[key]
        switch value {
        case var nestedDictionary as [Key: Any]:
          // Key path has a tail we need to traverse
          nestedDictionary[keyPath: remainingKeyPath] = newValue
          self[key] = nestedDictionary as? Value
        default:
          // Invalid keyPath
          return
        }
      }
    }
  }
}

// TODO: See if we can replace these with generic subscripts once these get implemented

extension Dictionary where Key: StringProtocol {
  subscript(stringAt keyPath: KeyPath) -> String? {
    get { return self[keyPath: keyPath] as? String }
    set { self[keyPath: keyPath] = newValue }
  }
  
  subscript(dictionaryAt keyPath: KeyPath) -> [Key: Any]? {
    get { return self[keyPath: keyPath] as? [Key: Any] }
    set { self[keyPath: keyPath] = newValue }
  }
  
  subscript(arrayAt keyPath: KeyPath) -> [Any]? {
    get { return self[keyPath: keyPath] as? [Any] }
    set { self[keyPath: keyPath] = newValue }
  }
}

struct KeyPath {
  var segments: [String]
  
  var isEmpty: Bool {
    return segments.isEmpty
  }
  
  var path: String {
    return segments.joined(separator: ".")
  }
  
  /// Strips off the first segment and returns a pair
  /// consisting of the first segment and the remaining key path.
  /// Returns nil if the key path has no segments.
  func headAndTail() -> (head: String, tail: KeyPath)? {
    guard !isEmpty else { return nil }
    
    var tail = segments
    let head = tail.removeFirst()
    return (head, KeyPath(segments: tail))
  }
}

extension KeyPath {
  init(_ string: String) {
    segments = string.components(separatedBy: ".")
  }
}

extension KeyPath: ExpressibleByStringLiteral {
  init(stringLiteral value: String) {
    self.init(value)
  }
  
  init(unicodeScalarLiteral value: String) {
    self.init(value)
  }
  
  init(extendedGraphemeClusterLiteral value: String) {
    self.init(value)
  }
}
