public protocol OutputTypeConvertible {
  @_spi(Execution)
  @inlinable static var _asOutputType: Selection.Field.OutputType { get }
}

extension String: OutputTypeConvertible {
  @_spi(Execution)
  public static let _asOutputType: Selection.Field.OutputType = .nonNull(.scalar(String.self))
}
extension Int: OutputTypeConvertible {
  @_spi(Execution)
  public static let _asOutputType: Selection.Field.OutputType = .nonNull(.scalar(Int.self))
}
extension Bool: OutputTypeConvertible {
  @_spi(Execution)
  public static let _asOutputType: Selection.Field.OutputType = .nonNull(.scalar(Bool.self))
}
extension Float: OutputTypeConvertible {
  @_spi(Execution)
  public static let _asOutputType: Selection.Field.OutputType = .nonNull(.scalar(Float.self))
}
extension Double: OutputTypeConvertible {
  @_spi(Execution)
  public static let _asOutputType: Selection.Field.OutputType = .nonNull(.scalar(Double.self))
}

extension Optional: OutputTypeConvertible where Wrapped: OutputTypeConvertible {
  @_spi(Execution)
  @inlinable public static var _asOutputType: Selection.Field.OutputType {
    guard case let .nonNull(wrappedOutputType) = Wrapped._asOutputType else {
      return Wrapped._asOutputType
    }
    return wrappedOutputType
  }
}

extension Array: OutputTypeConvertible where Element: OutputTypeConvertible {
  @_spi(Execution)
  @inlinable public static var _asOutputType: Selection.Field.OutputType {
    .nonNull(.list(Element._asOutputType))
  }
}

extension RootSelectionSet {
  @_spi(Execution)
  @inlinable public static var _asOutputType: Selection.Field.OutputType {
    .nonNull(.object(self))
  }
}

extension CustomScalarType {
  @_spi(Execution)
  @inlinable public static var _asOutputType: Selection.Field.OutputType {
    .nonNull(.customScalar(self))
  }
}
