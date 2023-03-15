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
    TemplateString(
    """
    \(embeddedAccessControlModifier)\
    typealias ID = String

    \(if: !config.output.schemaTypes.isInModule,
      TemplateString("""
      \(embeddedAccessControlModifier)\
      typealias SelectionSet = \(schemaNamespace)_SelectionSet

      \(embeddedAccessControlModifier)\
      typealias InlineFragment = \(schemaNamespace)_InlineFragment

      \(embeddedAccessControlModifier)\
      typealias MutableSelectionSet = \(schemaNamespace)_MutableSelectionSet

      \(embeddedAccessControlModifier)\
      typealias MutableInlineFragment = \(schemaNamespace)_MutableInlineFragment
      """),
    else: protocolDefinition(prefix: nil, schemaNamespace: schemaNamespace))

    \(documentation: schema.documentation, config: config)
    \(embeddedAccessControlModifier)\
    enum SchemaMetadata: \(config.ApolloAPITargetName).SchemaMetadata {
      public static let configuration: \(config.ApolloAPITargetName).SchemaConfiguration.Type = SchemaConfiguration.self

      \(objectTypeFunction)
    }

    \(embeddedAccessControlModifier)\
    enum Objects {}
    \(embeddedAccessControlModifier)\
    enum Interfaces {}
    \(embeddedAccessControlModifier)\
    enum Unions {}

    """
    )
  }

  var objectTypeFunction: TemplateString {
    return """
    public static func objectType(forTypename typename: String) -> Object? {
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
    return TemplateString("""
      public protocol \(prefix ?? "")SelectionSet: \(config.ApolloAPITargetName).SelectionSet & \(config.ApolloAPITargetName).RootSelectionSet
      where Schema == \(schemaNamespace).SchemaMetadata {}

      public protocol \(prefix ?? "")InlineFragment: \(config.ApolloAPITargetName).SelectionSet & \(config.ApolloAPITargetName).InlineFragment
      where Schema == \(schemaNamespace).SchemaMetadata {}

      public protocol \(prefix ?? "")MutableSelectionSet: \(config.ApolloAPITargetName).MutableRootSelectionSet
      where Schema == \(schemaNamespace).SchemaMetadata {}

      public protocol \(prefix ?? "")MutableInlineFragment: \(config.ApolloAPITargetName).MutableSelectionSet & \(config.ApolloAPITargetName).InlineFragment
      where Schema == \(schemaNamespace).SchemaMetadata {}
      """
    )
  }
}
