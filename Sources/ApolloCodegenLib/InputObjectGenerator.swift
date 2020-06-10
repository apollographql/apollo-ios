import Foundation
import Stencil

public class InputObjectGenerator {
  public struct SanitizedInputObject {
    public struct SanitizedInputObjectField {
      // The raw value of the name
      public let name: String
      public let nameVariableDeclaration: String
      public let nameVariableUsage: String
      public let swiftType: String
      public let isOptional: Bool
      public let description: String?
      
      init(field: ASTTypeUsed.Field) throws {
        self.name = field.name
        self.nameVariableDeclaration = field.name.apollo.sanitizedVariableDeclaration
        self.nameVariableUsage = field.name.apollo.sanitizedVariableUsage

        let isOptional = field.typeNode.isSwiftOptional()
        self.isOptional = isOptional
        if isOptional {
          self.swiftType = try field.typeNode.toGraphQLOptional()
        } else {
          self.swiftType = try field.typeNode.toSwiftType()
        }
              
        self.description = field.description
      }
    }

    // The raw value of the name
    public let name: String
    public let nameVariableDeclaration: String
    public let nameVariableUsage: String
    public let description: String
    public let fields: [SanitizedInputObjectField]?
  }
  
  /// Designated initializer
  public init() {}
  
  public enum InputObjectEnvironmentKey: String {
    case modifier
    case modifierSpaces
    case inputType
    case fields
    case hasOptionalFields
  }
  
  func run(typeUsed: ASTTypeUsed, options: ApolloCodegenOptions) throws -> String {
    
    let fields: [SanitizedInputObject.SanitizedInputObjectField]
    if let unsanitizedFields = typeUsed.fields {
      fields = try unsanitizedFields.map { try SanitizedInputObject.SanitizedInputObjectField(field: $0) }
    } else {
      fields = []
    }
    
    let firstOptionalField = fields.first(where: { $0.isOptional })
    let hasOptionalFields = (firstOptionalField != nil)
    
    let modifier = options.modifier.prefixValue
    let modifierSpaces = modifier.map { _ in " " }.joined()
    
    let context: [InputObjectEnvironmentKey: Any] = [
      .modifier: modifier,
      .modifierSpaces: modifierSpaces,
      .inputType: typeUsed,
      .fields: fields,
      .hasOptionalFields: hasOptionalFields,
    ]
        
    return try Environment().renderTemplate(string: self.inputObjectTemplate, context: context.apollo.toStringKeyedDict)
  }
  
  /// A stencil template to use to render enums.
  ///
  /// Variable to allow custom modifications, but MODIFY AT YOUR OWN RISK.
  open var inputObjectTemplate: String {
    """
{% if inputType.description != "" %}/// {{ inputType.description }}
{% endif %}{{ modifier }}struct {{ inputType.name }}: Codable, Equatable, Hashable {
  {% for field in fields %}{% if field.description != nil %}/// {{ field.description }}
  {% endif %}{{ modifier }}var {{ field.nameVariableDeclaration }}: {{ field.swiftType }}{% if not forloop.last %}
  {% endif %}{% endfor %}{% if hasOptionalFields %}
  
  {{ modifier }}enum CodingKeys: String, CodingKey {
    {% for field in fields %}case {{ field.nameVariableDeclaration }}{% if not forloop.last %}
    {% endif %}{% endfor %}
  }{% endif %}
  
  /// Designated initializer
  ///
  /// - Parameters:
  {% for field in fields %}///   - {{ field.nameVariableDeclaration }}:{% if field.description != nil %} {{ field.description }}{% endif %}{% if not forloop.last %}
  {% endif %}{% endfor %}
  {{ modifier }}init({% for field in fields %}{{ field.nameVariableDeclaration }}: {{ field.swiftType }}{% if not forloop.last %},
       {{ modifierSpaces }}{% endif %}{% endfor %}) {
    {% for field in fields %}self.{{ field.nameVariableUsage }} = {{ field.nameVariableUsage }}{% if not forloop.last %}
    {% endif %}{% endfor %}
  }{% if hasOptionalFields %}

  {{ modifier }}func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: {{ inputType.name }}.CodingKeys.self)
    {% for field in fields %}{% if field.isOptional %}
    try container.encodeGraphQLOptional(self.{{ field.nameVariableUsage }}, forKey: .{{ field.nameVariableUsage }}){% else %}
    try container.encode(self.{{ field.nameVariableUsage }}, forKey: .{{ field.nameVariableUsage }}){% endif %}{% endfor %}
  }

  {{ modifier }}init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: {{ inputType.name }}.CodingKeys.self)
    {% for field in fields %}{% if field.isOptional %}
    self.{{ field.nameVariableUsage }} = try container.decodeGraphQLOptional(forKey: .{{ field.nameVariableUsage }}){% else %}
    self.{{ field.nameVariableUsage }} = try container.decode({{ field.swiftType }}.self, forKey: .{{ field.nameVariableUsage }}){% endif %}{% endfor %}
  }{% endif %}
}
"""
  }
}
