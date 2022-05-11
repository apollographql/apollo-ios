public protocol Union: ParentTypeConvertible {
  static var possibleTypes: [Object.Type] { get }
}
