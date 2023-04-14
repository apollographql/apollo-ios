@testable import ApolloCodegenLib
@testable import JXKit

private var mockJavaScriptBridge = try! JavaScriptBridge()

extension JavaScriptObject {

  @objc public class func emptyMockObject() -> Self {
    let object = JXValue(newObjectIn: mockJavaScriptBridge.context)!
    return Self.fromJXValue(object, bridge: mockJavaScriptBridge)
  }

}
