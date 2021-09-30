@testable import ApolloCodegenLib
@testable import JavaScriptCore

extension JavaScriptObject {

  @objc public class func emptyMockObject() -> Self {
    let context = JSContext()!
    let object = JSValue(newObjectIn: context)!
    return Self.init(object, bridge: JavaScriptBridge(context: context))
  }
}
