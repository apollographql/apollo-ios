import Foundation
import JavaScriptCore

public struct ValidationOptions {

  struct DisallowedFieldNames {
    let allFields: Set<String>
    let entity: Set<String>
    let entityList: Set<String>

    var asDictionary: Dictionary<String, Array<String>> {
      return [
        "allFields": Array(allFields),
        "entity": Array(entity),
        "entityList": Array(entityList)
      ]
    }
  }

  let schemaNamespace: String
  let disallowedFieldNames: DisallowedFieldNames
  let disallowedInputParameterNames: Set<String>

  init(config: ApolloCodegen.ConfigurationContext) {
    self.schemaNamespace = config.schemaNamespace

    let singularizedSchemaNamespace = config.pluralizer.singularize(config.schemaNamespace)
    let pluralizedSchemaNamespace = config.pluralizer.pluralize(config.schemaNamespace)
    let disallowedEntityListFieldNames: Set<String>
    switch (config.schemaNamespace) {
    case singularizedSchemaNamespace:
      disallowedEntityListFieldNames = [pluralizedSchemaNamespace.firstLowercased]
    case pluralizedSchemaNamespace:
      disallowedEntityListFieldNames = [singularizedSchemaNamespace.firstLowercased]
    default:
      fatalError("Could not derive singular/plural of schema name '\(config.schemaNamespace)'")
    }

    self.disallowedFieldNames = DisallowedFieldNames(
      allFields: SwiftKeywords.DisallowedFieldNames,
      entity: [config.schemaNamespace.firstLowercased],
      entityList: disallowedEntityListFieldNames
    )

    self.disallowedInputParameterNames =
    SwiftKeywords.DisallowedInputParameterNames.union([config.schemaNamespace.firstLowercased])
  }

  public class Bridged: JavaScriptObject {
    convenience init(from options: ValidationOptions, bridge: JavaScriptBridge) {
      let jsValue = JSValue(newObjectIn: bridge.context)

      jsValue?.setValue(
        JSValue(object: options.schemaNamespace, in: bridge.context),
        forProperty: "schemaNamespace"
      )

      jsValue?.setValue(
        JSValue(object: options.disallowedFieldNames.asDictionary, in: bridge.context),
        forProperty: "disallowedFieldNames"
      )

      jsValue?.setValue(
        JSValue(object: Array(options.disallowedInputParameterNames), in: bridge.context),
        forProperty: "disallowedInputParameterNames"
      )

      self.init(jsValue!, bridge: bridge)
    }
  }

}
