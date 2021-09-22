import Foundation

public enum Selection {
  case field(Field)
  case booleanCondition(BooleanCondition)
  case fragment(Fragment.Type)
  case typeCase(ApolloAPI.TypeCase.Type)

  public struct Field {
    public let name: String
    public let alias: String?
    #warning("TODO: can we just change this to [String: InputValue] and kill Arguments?")
    public let arguments: Arguments?
    public let type: OutputType

    public var responseKey: String {
      return alias ?? name
    }

    public init(
      _ name: String,
      alias: String? = nil,
      type: OutputType,
      arguments: Arguments? = nil
    ) {
      self.name = name
      self.alias = alias

      self.arguments = arguments

      self.type = type
    }

    public struct Arguments: ExpressibleByDictionaryLiteral {
      public let arguments: InputValue

      @inlinable public init(dictionaryLiteral elements: (String, InputValue)...) {
        arguments = .object(Dictionary(elements, uniquingKeysWith: { (_, last) in last }))
      }
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
    arguments: Field.Arguments? = nil
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
