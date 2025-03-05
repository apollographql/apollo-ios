public protocol OutputTypeConvertible {
  @inlinable static var _asOutputType: Selection.Field.OutputType { get }
}

extension String: OutputTypeConvertible {
  public static let _asOutputType: Selection.Field.OutputType = .nonNull(.scalar(String.self))
}
extension Int: OutputTypeConvertible {
  public static let _asOutputType: Selection.Field.OutputType = .nonNull(.scalar(Int.self))
}
extension Bool: OutputTypeConvertible {
  public static let _asOutputType: Selection.Field.OutputType = .nonNull(.scalar(Bool.self))
}
extension Float: OutputTypeConvertible {
  public static let _asOutputType: Selection.Field.OutputType = .nonNull(.scalar(Float.self))
}
extension Double: OutputTypeConvertible {
  public static let _asOutputType: Selection.Field.OutputType = .nonNull(.scalar(Double.self))
}

extension Optional: OutputTypeConvertible where Wrapped: OutputTypeConvertible {
  @inlinable public static var _asOutputType: Selection.Field.OutputType {
    guard case let .nonNull(wrappedOutputType) = Wrapped._asOutputType else {
      return Wrapped._asOutputType
    }
    return wrappedOutputType
  }
}

extension Array: OutputTypeConvertible where Element: OutputTypeConvertible {
  @inlinable public static var _asOutputType: Selection.Field.OutputType {
    .nonNull(.list(Element._asOutputType))
  }
}

extension RootSelectionSet {
  @inlinable public static var _asOutputType: Selection.Field.OutputType {
    .nonNull(.object(self))
  }
}
