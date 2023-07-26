import Foundation

public enum Selection {
  /// A single field selection.
  case field(Field)
  /// A fragment spread of a named fragment definition.
  case fragment(any Fragment.Type, deferred: Bool = false)
  /// An inline fragment with a child selection set nested in a parent selection set.
  case inlineFragment(any InlineFragment.Type, deferred: Bool = false)
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
      case scalar(any ScalarType.Type)
      case customScalar(any CustomScalarType.Type)
      case object(any RootSelectionSet.Type)
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

  @inlinable static public func field(
    _ name: String,
    alias: String? = nil,
    _ type: OutputTypeConvertible.Type,
    arguments: [String: InputValue]? = nil
  ) -> Selection {
    .field(.init(name, alias: alias, type: type._asOutputType, arguments: arguments))
  }

  @inlinable static public func include(
    if condition: String,
    _ selection: Selection
  ) -> Selection {
    .conditional(Conditions([[Selection.Condition(stringLiteral: condition)]]), [selection])
  }

  @inlinable static public func include(
    if condition: String,
    _ selections: [Selection]
  ) -> Selection {
    .conditional(Conditions([[Selection.Condition(stringLiteral: condition)]]), selections)
  }

  @inlinable static public func include(
    if conditions: Conditions,
    _ selection: Selection
  ) -> Selection {
    .conditional(conditions, [selection])
  }

  @inlinable static public func include(
    if conditions: Conditions,
    _ selections: [Selection]
  ) -> Selection {
    .conditional(conditions, selections)
  }

  @inlinable static public func include(
    if condition: Condition,
    _ selection: Selection
  ) -> Selection {
    .conditional(Conditions([[condition]]), [selection])
  }

  @inlinable static public func include(
    if condition: Condition,
    _ selections: [Selection]
  ) -> Selection {
    .conditional(Conditions([[condition]]), selections)
  }

  @inlinable static public func include(
    if conditions: [Condition],
    _ selection: Selection
  ) -> Selection {
    .conditional(Conditions([conditions]), [selection])
  }

  @inlinable static public func include(
    if conditions: [Condition],
    _ selections: [Selection]
  ) -> Selection {
    .conditional(Conditions([conditions]), selections)
  }

}

// MARK: - Hashable Conformance

extension Selection: Hashable {
  public static func == (lhs: Selection, rhs: Selection) -> Bool {
    switch (lhs, rhs) {
    case let (.field(lhs), .field(rhs)):
      return lhs == rhs
    case let (.fragment(lhsFragment, lhsDeferred), .fragment(rhsFragment, rhsDeferred)):
      return lhsFragment == rhsFragment && lhsDeferred == rhsDeferred
    case let (.inlineFragment(lhsFragment, lhsDeferred), .inlineFragment(rhsFragment, rhsDeferred)):
      return lhsFragment == rhsFragment && lhsDeferred == rhsDeferred
    case let (.conditional(lhsConditions, lhsSelections),
              .conditional(rhsConditions, rhsSelections)):
      return lhsConditions == rhsConditions && lhsSelections == rhsSelections
    default: return false
    }
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self)
  }
}

extension Selection.Field: Hashable {
  public static func == (lhs: Selection.Field, rhs: Selection.Field) -> Bool {
    lhs.name == rhs.name &&
    lhs.alias == rhs.alias &&
    lhs.arguments == rhs.arguments &&
    lhs.type == rhs.type
  }
}

extension Selection.Field.OutputType: Hashable {
  public static func == (lhs: Selection.Field.OutputType, rhs: Selection.Field.OutputType) -> Bool {
    switch (lhs, rhs) {
    case let (.scalar(lhs), .scalar(rhs)):
      return lhs == rhs
    case let (.customScalar(lhs), .customScalar(rhs)):
      return lhs == rhs
    case let (.object(lhs), .object(rhs)):
      return lhs == rhs
    case let (.nonNull(lhs), .nonNull(rhs)):
      return lhs == rhs
    case let (.list(lhs), .list(rhs)):
      return lhs == rhs
    default: return false
    }
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self)
  }
}
