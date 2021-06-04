import Foundation

public enum Selection {
  case field(Field)
  case booleanCondition(BooleanCondition)
  case typeCase(TypeCase)
  case fragmentSpread(FragmentSpread)

  public struct Field {
    let name: String
    let alias: String?
    let arguments: Arguments?
    let type: OutputType

    var responseKey: String {
      return alias ?? name
    }

    public init(_ name: String,
                alias: String? = nil,
                arguments: Arguments? = nil,
                type: OutputType) {
      self.name = name
      self.alias = alias

      self.arguments = arguments

      self.type = type
    }

    public struct Arguments: ExpressibleByDictionaryLiteral {
      let arguments: InputValue

      public init(dictionaryLiteral elements: (String, InputValue)...) {
        arguments = .object(Dictionary(elements, uniquingKeysWith: { (_, last) in last }))
      }
    }

    public indirect enum OutputType {
      case scalar(Any.Type)
      case object([Selection])
      case nonNull(OutputType)
      case list(OutputType)

      var namedType: OutputType {
        switch self {
        case .nonNull(let innerType), .list(let innerType):
          return innerType.namedType
        case .scalar, .object:
          return self
        }
      }
    }
  }

  public struct BooleanCondition {
    let variableName: String
    let inverted: Bool
    let selections: [Selection]

    public init(variableName: String,
                inverted: Bool,
                selections: [Selection]) {
      self.variableName = variableName
      self.inverted = inverted;
      self.selections = selections;
    }
  }

  public struct FragmentSpread {
    let fragment: AnySelectionSet.Type

    public init(_ fragment: AnySelectionSet.Type) {
      self.fragment = fragment
    }
  }

  public struct TypeCase {
    let variants: [String: [Selection]]
    let `default`: [Selection]

    public init(variants: [String: [Selection]], default: [Selection]) {
      self.variants = variants
      self.default = `default`;
    }
  }
}
