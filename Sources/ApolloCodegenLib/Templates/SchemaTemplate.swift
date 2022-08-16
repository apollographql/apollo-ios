import Foundation

/// Provides the format to define a schema in Swift code. The schema represents metadata used by
/// the GraphQL executor at runtime to convert response data into corresponding Swift types.
struct SchemaTemplate: TemplateRenderer {
  // IR representation of source GraphQL schema.
  let schema: IR.Schema

  let config: ApolloCodegen.ConfigurationContext

  let schemaName: String

  let target: TemplateTarget = .schemaFile(type: .schema)

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
      typealias SelectionSet = \(schemaName)_SelectionSet

      \(embeddedAccessControlModifier)\
      typealias InlineFragment = \(schemaName)_InlineFragment

      \(embeddedAccessControlModifier)\
      typealias MutableSelectionSet = \(schemaName)_MutableSelectionSet

      \(embeddedAccessControlModifier)\
      typealias MutableInlineFragment = \(schemaName)_MutableInlineFragment
      """),
    else: protocolDefinition(prefix: nil, schemaName: schemaName))

    \(documentation: schema.documentation, config: config)
    \(embeddedAccessControlModifier)\
    enum Schema: SchemaConfiguration {
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
        "case \"\($0.name.firstUppercased)\": return \(schemaName).Objects.\($0.name.firstUppercased)"
      }, separator: "\n")
      default: return nil
      }
    }
    """
  }
  /// Swift code that must be rendered outside of any namespace.
  var detachedTemplate: TemplateString? {
    guard !config.output.schemaTypes.isInModule else { return nil }

    return protocolDefinition(prefix: "\(schemaName)_", schemaName: schemaName)
  }

  init(schema: IR.Schema, config: ApolloCodegen.ConfigurationContext) {
    self.schema = schema
    self.schemaName = schema.name.firstUppercased
    self.config = config
  }

  private func protocolDefinition(prefix: String?, schemaName: String) -> TemplateString {
    let apolloAPITargetName = ImportStatementTemplate.ApolloAPIImportTargetName(forConfig: config)
    return TemplateString("""
      public protocol \(prefix ?? "")SelectionSet: \(apolloAPITargetName).SelectionSet & \(apolloAPITargetName).RootSelectionSet
      where Schema == \(schemaName).Schema {}

      public protocol \(prefix ?? "")InlineFragment: \(apolloAPITargetName).SelectionSet & \(apolloAPITargetName).InlineFragment
      where Schema == \(schemaName).Schema {}

      public protocol \(prefix ?? "")MutableSelectionSet: \(apolloAPITargetName).MutableRootSelectionSet
      where Schema == \(schemaName).Schema {}

      public protocol \(prefix ?? "")MutableInlineFragment: \(apolloAPITargetName).MutableSelectionSet & \(apolloAPITargetName).InlineFragment
      where Schema == \(schemaName).Schema {}
      """
    )
  }
}
