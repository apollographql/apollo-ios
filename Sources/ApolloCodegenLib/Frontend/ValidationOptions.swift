import Foundation
import JavaScriptCore

public struct ValidationOptions {

  let disallowedScalarFieldNames: Set<String>
  let disallowedEntityFieldNames: Set<String>
  let disallowedEntityListFieldNames: Set<String>
  let disallowedInputParameterNames: Set<String>

  init(config: ApolloCodegen.ConfigurationContext) {
    self.disallowedScalarFieldNames = SwiftKeywords.DisallowedFieldNames

    self.disallowedEntityFieldNames = [config.schemaName.firstLowercased]

    let singularizedSchemaName = config.pluralizer.singularize(config.schemaName)
    let pluralizedSchemaName = config.pluralizer.pluralize(config.schemaName)
    switch (config.schemaName) {
    case singularizedSchemaName:
      self.disallowedEntityListFieldNames = [pluralizedSchemaName.firstLowercased]
    case pluralizedSchemaName:
      self.disallowedEntityListFieldNames = [singularizedSchemaName.firstLowercased]
    default:
      fatalError("Could not derive singular/plural of schema name \(config.schemaName)")
    }

    self.disallowedInputParameterNames =
    SwiftKeywords.DisallowedInputParameterNames.union([config.schemaName.firstLowercased])
  }

  public class Bridged: JavaScriptObject {
    convenience init(from options: ValidationOptions, bridge: JavaScriptBridge) {
      let jsValue = JSValue(newObjectIn: bridge.context)

      jsValue?.setValue(
        JSValue(object: Array(options.disallowedScalarFieldNames), in: bridge.context),
        forProperty: "disallowedScalarFieldNames"
      )

      jsValue?.setValue(
        JSValue(object: Array(options.disallowedEntityFieldNames), in: bridge.context),
        forProperty: "disallowedEntityFieldNames"
      )

      jsValue?.setValue(
        JSValue(object: Array(options.disallowedEntityListFieldNames), in: bridge.context),
        forProperty: "disallowedEntityListFieldNames"
      )

      jsValue?.setValue(
        JSValue(object: Array(options.disallowedInputParameterNames), in: bridge.context),
        forProperty: "disallowedInputParameterNames"
      )

      self.init(jsValue!, bridge: bridge)
    }
  }

}
