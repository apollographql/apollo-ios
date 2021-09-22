import Foundation

public enum Selection {
  case field(Field)
  case booleanCondition(BooleanCondition)
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

  public struct BooleanCondition {
    public let variableName: String
    public let inverted: Bool
    public let selections: [Selection]

    public init(variableName: String,
                inverted: Bool,
                selections: [Selection]) {
      self.variableName = variableName
      self.inverted = inverted;
      self.selections = selections;
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
    .booleanCondition(.init(variableName: variableName, inverted: false, selections: [selection]))
  }

  static public func include(
    if variableName: String,
    _ selections: [Selection]
  ) -> Selection {
    .booleanCondition(.init(variableName: variableName, inverted: false, selections: selections))
  }

  static public func skip(
    if variableName: String,
    _ selection: Selection
  ) -> Selection {
    .booleanCondition(.init(variableName: variableName, inverted: true, selections: [selection]))
  }

  static public func skip(
    if variableName: String,
    _ selections: [Selection]
  ) -> Selection {
    .booleanCondition(.init(variableName: variableName, inverted: true, selections: selections))
  }
}
