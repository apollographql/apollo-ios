@testable import ApolloCodegenLib
@testable import JavaScriptCore

private var mockJavaScriptBridge = try! JavaScriptBridge()

extension JavaScriptObject {

  @objc public class func emptyMockObject() -> Self {
    let object = JSValue(newObjectIn: mockJavaScriptBridge.context)!
    return Self.fromJSValue(object, bridge: mockJavaScriptBridge)
  }
  
}
