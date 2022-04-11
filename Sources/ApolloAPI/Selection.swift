import Foundation

public enum Selection {
  /// A single field selection.
  case field(Field)
  /// A fragment spread of a named fragment definition.
  case fragment(Fragment.Type)
  /// An inline fragment with a child selection set nested in a parent selection set.
  case inlineFragment(ApolloAPI.InlineFragment.Type)
  /// A group of selections that have `@include/@skip` directives.
  case conditional(Conditions, [Selection])

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
    if condition: String,
    _ selection: Selection
  ) -> Selection {
    .conditional([[Selection.Condition(stringLiteral: condition)]], [selection])
  }

  static public func include(
    if condition: String,
    _ selections: [Selection]
  ) -> Selection {
    .conditional([[Selection.Condition(stringLiteral: condition)]], selections)
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
    if condition: Condition,
    _ selection: Selection
  ) -> Selection {
    .conditional([[condition]], [selection])
  }

  static public func include(
    if condition: Condition,
    _ selections: [Selection]
  ) -> Selection {
    .conditional([[condition]], selections)
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

}
