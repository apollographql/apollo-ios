import Foundation

public enum Selection {
  case field(Field)
  /// A group of selections that have `@include/@skip` directives.
  case conditional(Conditions, [Selection])
  case fragment(Fragment.Type)
  case typeCase(ApolloAPI.TypeCase.Type)

  public struct Field {
    public let name: String
    public let alias: String?
    public let arguments: [String: InputValue]?
    public let type: OutputType

    public var responseKey: String {
      return alias ?? name
    }

    public init(
      _ name: String,
      alias: String? = nil,
      type: OutputType,
      arguments: [String: InputValue]? = nil
    ) {
      self.name = name
      self.alias = alias

      self.arguments = arguments

      self.type = type
    }

    public indirect enum OutputType {
      case scalar(ScalarType.Type)
      case customScalar(CustomScalarType.Type)
      case object(RootSelectionSet.Type)
      case nonNull(OutputType)
      case list(OutputType)

      public var namedType: OutputType {
        switch self {
        case .nonNull(let innerType), .list(let innerType):
          return innerType.namedType
        case .scalar, .customScalar, .object:
          return self
        }
      }

      public var isNullable: Bool {
        if case .nonNull = self { return false }
        return true
      }
    }
  }

  /// The conditions representing a group of `@include/@skip` directives.
  ///
  /// The conditions are a two-dimensional array of `Selection.Condition`s.
  /// The outer array represents groups of conditions joined together with a logical "or".
  /// Conditions in the same inner array are joined together with a logical "and".
  public struct Conditions: ExpressibleByArrayLiteral {
    public let value: [[Condition]]

    @inlinable
    public init(_ value: [[Condition]]) {
      self.value = value
    }

    @inlinable
    public init(arrayLiteral elements: [Condition]...) {
      self.value = Array(elements)
    }

    @inlinable
    public static func ||(_ lhs: Conditions, rhs: [Condition]) -> Conditions {
      var newValue = lhs.value
      newValue.append(rhs)
      return .init(newValue)
    }

    @inlinable
    public static func ||(_ lhs: Conditions, rhs: Condition) -> Conditions {
      lhs || [rhs]
    }
  }

  public struct Condition: ExpressibleByStringLiteral {
    public let variableName: String
    public let inverted: Bool

    @inlinable
    public init(
      variableName: String,
      inverted: Bool
    ) {
      self.variableName = variableName
      self.inverted = inverted;
    }

    @inlinable
    public init(stringLiteral value: StringLiteralType) {
      self.variableName = value
      self.inverted = false
    }

    @inlinable
    public static prefix func !(value: Condition) -> Condition {
      .init(variableName: value.variableName, inverted: !value.inverted)
    }

    @inlinable
    public static func &&(_ lhs: Condition, rhs: Condition) -> [Condition] {
      [lhs, rhs]
    }

    @inlinable
    public static func &&(_ lhs: [Condition], rhs: Condition) -> [Condition] {
      var newValue = lhs
      newValue.append(rhs)
      return newValue
    }

    @inlinable
    public static func ||(_ lhs: Condition, rhs: Condition) -> Conditions {
      .init([[lhs], [rhs]])
    }

    @inlinable
    public static func ||(_ lhs: [Condition], rhs: Condition) -> Conditions {
      .init([lhs, [rhs]])
    }

  }

  // MARK: - Convenience Initializers

  static public func field(
    _ name: String,
    alias: String? = nil,
    _ type: OutputTypeConvertible.Type,
    arguments: [String: InputValue]? = nil
  ) -> Selection {
    .field(.init(name, alias: alias, type: type.asOutputType, arguments: arguments))
  }  

  static public func include(
    if variableName: String,
    _ selection: Selection
  ) -> Selection {
    .conditional([[.init(variableName: variableName, inverted: false)]], [selection])
  }

  static public func include(
    if variableName: String,
    _ selections: [Selection]
  ) -> Selection {
    .conditional([[.init(variableName: variableName, inverted: false)]], selections)
  }

  static public func include(
    if conditions: Conditions,
    _ selection: Selection
  ) -> Selection {
    .conditional(conditions, [selection])
  }

  static public func include(
    if conditions: Conditions,
    _ selections: [Selection]
  ) -> Selection {
    .conditional(conditions, selections)
  }

  static public func include(
    if conditions: [Condition],
    _ selection: Selection
  ) -> Selection {
    .conditional([conditions], [selection])
  }

  static public func include(
    if conditions: [Condition],
    _ selections: [Selection]
  ) -> Selection {
    .conditional([conditions], selections)
  }

  static public func skip(
    if variableName: String,
    _ selection: Selection
  ) -> Selection {
    .conditional([[.init(variableName: variableName, inverted: true)]], [selection])
  }

  static public func skip(
    if variableName: String,
    _ selections: [Selection]
  ) -> Selection {
    .conditional([[.init(variableName: variableName, inverted: true)]], selections)
  }
}
