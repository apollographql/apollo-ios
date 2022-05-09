public protocol Union: ParentTypeConvertible {
  static var possibleTypes: [Object.Type] { get }
  var object: Object { get }

  init(_ object: Object)
}

extension Union {

  public static func ==(lhs: Self, rhs: Self) -> Bool {
    return lhs.object === rhs.object
  }

}
