@testable import ApolloCodegenLib
@testable import JavaScriptCore

extension JavaScriptObject {

  public static func mock() -> Self {
    let context = JSContext()!
    let object = JSValue(newObjectIn: context)!
    return Self.init(object, bridge: JavaScriptBridge(context: context))
  }
}
