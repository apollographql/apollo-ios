import Foundation

/// Provides the format to define a schema in Swift code. The schema represents metadata used by
/// the GraphQL executor at runtime to convert response data into corresponding Swift types.
struct SchemaMetadataTemplate: TemplateRenderer {
  // IR representation of source GraphQL schema.
  let schema: IR.Schema

  let config: ApolloCodegen.ConfigurationContext

  let schemaNamespace: String

  let target: TemplateTarget = .schemaFile(type: .schemaMetadata)

  var template: TemplateString { embeddableTemplate }

  /// Swift code that can be embedded within a namespace.
  var embeddableTemplate: TemplateString {
    let accessLevel = embeddedAccessControlModifier(target: target)

    return TemplateString(
    """
    \(accessLevel)\
    typealias ID = String

    \(if: !config.output.schemaTypes.isInModule,
      TemplateString("""
      \(accessLevel)\
      typealias SelectionSet = \(schemaNamespace)_SelectionSet

      \(accessLevel)\
      typealias InlineFragment = \(schemaNamespace)_InlineFragment

      \(accessLevel)\
      typealias MutableSelectionSet = \(schemaNamespace)_MutableSelectionSet

      \(accessLevel)\
      typealias MutableInlineFragment = \(schemaNamespace)_MutableInlineFragment
      """),
    else: protocolDefinition(prefix: nil, schemaNamespace: schemaNamespace))

    \(documentation: schema.documentation, config: config)
    \(accessLevel)\
    enum SchemaMetadata: \(config.ApolloAPITargetName).SchemaMetadata {
      \(accessLevel)\
    static let configuration: \(config.ApolloAPITargetName).SchemaConfiguration.Type = SchemaConfiguration.self

      \(objectTypeFunction)
    }

    \(accessLevel)\
    enum Objects {}
    \(accessLevel)\
    enum Interfaces {}
    \(accessLevel)\
    enum Unions {}

    """
    )
  }

  var objectTypeFunction: TemplateString {
    return """
    \(embeddedAccessControlModifier(target: target))\
    static func objectType(forTypename typename: String) -> Object? {
      switch typename {
      \(schema.referencedTypes.objects.map {
        "case \"\($0.name)\": return \(schemaNamespace).Objects.\($0.name.firstUppercased)"
      }, separator: "\n")
      default: return nil
      }
    }
    """
  }
  /// Swift code that must be rendered outside of any namespace.
  var detachedTemplate: TemplateString? {
    guard !config.output.schemaTypes.isInModule else { return nil }

    return protocolDefinition(prefix: "\(schemaNamespace)_", schemaNamespace: schemaNamespace)
  }

  init(schema: IR.Schema, config: ApolloCodegen.ConfigurationContext) {
    self.schema = schema
    self.schemaNamespace = config.schemaNamespace.firstUppercased
    self.config = config
  }

  private func protocolDefinition(prefix: String?, schemaNamespace: String) -> TemplateString {
    let accessLevel = embeddedAccessControlModifier(target: target)

    return TemplateString("""
      \(accessLevel)protocol \(prefix ?? "")SelectionSet: \(config.ApolloAPITargetName).SelectionSet & \(config.ApolloAPITargetName).RootSelectionSet
      where Schema == \(schemaNamespace).SchemaMetadata {}

      \(accessLevel)protocol \(prefix ?? "")InlineFragment: \(config.ApolloAPITargetName).SelectionSet & \(config.ApolloAPITargetName).InlineFragment
      where Schema == \(schemaNamespace).SchemaMetadata {}

      \(accessLevel)protocol \(prefix ?? "")MutableSelectionSet: \(config.ApolloAPITargetName).MutableRootSelectionSet
      where Schema == \(schemaNamespace).SchemaMetadata {}

      \(accessLevel)protocol \(prefix ?? "")MutableInlineFragment: \(config.ApolloAPITargetName).MutableSelectionSet & \(config.ApolloAPITargetName).InlineFragment
      where Schema == \(schemaNamespace).SchemaMetadata {}
      """
    )
  }
}
