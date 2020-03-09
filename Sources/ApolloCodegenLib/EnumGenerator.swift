import Foundation
import Stencil

public class EnumGenerator {
  
  /// Errors which can be encountered when generating an enum
  public enum EnumGenerationError: Error, LocalizedError {
    case kindIsNotAnEnum
    case enumHasNilCases
    
    public var errorDescription: String? {
      switch self {
      case .kindIsNotAnEnum:
        return "An inappropriate `ASTTypeUsed.Kind` was passed into the enum generator."
      case .enumHasNilCases:
        return "An an enum typed was passed in but it had nil values. Check your schema for possible errors."
      }
    }
  }
  
  /// Designated initializer
  public init() {
  }
  
  func run(typeUsed: ASTTypeUsed, options: ApolloCodegenOptions) throws -> String {
    guard typeUsed.kind == .EnumType else {
      throw EnumGenerationError.kindIsNotAnEnum
    }
    
    guard let enumValues = typeUsed.values else {
      throw EnumGenerationError.enumHasNilCases
    }
    
    let cases: [ASTEnumValue]
    if options.omitDeprecatedEnumCases {
      cases = enumValues.filter { !$0.isDeprecated }
    } else {
      cases = enumValues
    }

    let context: [String: Any] = [
      "modifier": options.modifier.prefixValue,
      "enumType": typeUsed,
      "cases": cases
    ]
    
    return try Environment().renderTemplate(string: self.enumTemplate, context: context)
  }
  
  /// A stencil template to use to render enums.
  ///
  /// Variable to allow custom modifications, but MODIFY AT YOUR OWN RISK.
  open var enumTemplate = """
  {% if enumType.description != "" %}/// {{ enumType.description }}
  {% endif %}{{ modifier }}enum {{ enumType.name }}: RawRepresentable, Codable, Equatable, Hashable, CaseIterable {
    {{ modifier }}typealias RawValue = String

    {% for case in cases %}{% if case.isDeprecated %}@available(*, deprecated, message: "Deprecated in schema")
    {% endif %}{% if case.description != "" %}/// {{ case.description }}
    {% endif %}case {{ case.name }}
    {% endfor %}/// An {{ enumType.name }} type not defined at the time this enum was generated
    case __unknown(String)

    {{ modifier }}var rawValue: String {
      switch self {
      {% for case in cases %}case .{{ case.name }}: return "{{ case.name }}"
      {% endfor %}case .__unknown(let value): return value
      }
    }

    {{ modifier }}init(rawValue: String) {
      switch rawValue {
      {% for case in cases %}case "{{ case.name }}": self = .{{ case.name }}
      {% endfor %}default: self = .__unknown(rawValue)
      }
    }

    {{ modifier }}static var allCases: [{{ enumType.name }}] {
      [{% for case in cases %}
        .{{ case.name }},{% endfor %}
      ]
    }
  }
  """
}
