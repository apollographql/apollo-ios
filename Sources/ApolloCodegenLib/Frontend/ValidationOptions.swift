import Foundation
import JavaScriptCore

public struct ValidationOptions {

  struct DisallowedFieldNames {
    let scalar: Set<String>
    let entity: Set<String>
    let entityList: Set<String>

    var asDictionary: Dictionary<String, Array<String>> {
      return [
        "scalar": Array(scalar),
        "entity": Array(entity),
        "entityList": Array(entityList)
      ]
    }
  }

  let schemaName: String
  let disallowedFieldNames: DisallowedFieldNames
  let disallowedInputParameterNames: Set<String>

  init(config: ApolloCodegen.ConfigurationContext) {
    self.schemaName = config.schemaName

    let singularizedSchemaName = config.pluralizer.singularize(config.schemaName)
    let pluralizedSchemaName = config.pluralizer.pluralize(config.schemaName)
    let disallowedEntityListFieldNames: Set<String>
    switch (config.schemaName) {
    case singularizedSchemaName:
      disallowedEntityListFieldNames = [pluralizedSchemaName.firstLowercased]
    case pluralizedSchemaName:
      disallowedEntityListFieldNames = [singularizedSchemaName.firstLowercased]
    default:
      fatalError("Could not derive singular/plural of schema name '\(config.schemaName)'")
    }

    self.disallowedFieldNames = DisallowedFieldNames(
      scalar: SwiftKeywords.DisallowedFieldNames,
      entity: [config.schemaName.firstLowercased],
      entityList: disallowedEntityListFieldNames
    )

    self.disallowedInputParameterNames =
    SwiftKeywords.DisallowedInputParameterNames.union([config.schemaName.firstLowercased])
  }

  public class Bridged: JavaScriptObject {
    convenience init(from options: ValidationOptions, bridge: JavaScriptBridge) {
      let jsValue = JSValue(newObjectIn: bridge.context)

      jsValue?.setValue(
        JSValue(object: options.schemaName, in: bridge.context),
        forProperty: "schemaName"
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
