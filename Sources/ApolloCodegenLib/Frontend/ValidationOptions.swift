import Foundation
import JavaScriptCore

public struct ValidationOptions {

  let disallowedFieldNames: Set<String>
  let disallowedInputParameterNames: Set<String>

  init(config: ApolloCodegenConfiguration) {
    self.disallowedFieldNames =
    SwiftKeywords.DisallowedFieldNames.union([config.schemaName.firstLowercased])

    self.disallowedInputParameterNames =
    SwiftKeywords.DisallowedInputParameterNames.union([config.schemaName.firstLowercased])
  }

  public class Bridged: JavaScriptObject {
    convenience init(from options: ValidationOptions, bridge: JavaScriptBridge) {
      let jsValue = JSValue(newObjectIn: bridge.context)
      jsValue?.setValue(
        JSValue(object: Array(options.disallowedFieldNames), in: bridge.context),
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
