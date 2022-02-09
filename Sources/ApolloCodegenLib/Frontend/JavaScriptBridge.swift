import JavaScriptCore

// JavaScriptCore APIs haven't been annotated for nullability, but most of its methods will never return `null`
// and can be safely force unwrapped. (Even when an exception is thrown they would still return
// a `JSValue` representing a JavaScript `undefined` value.)

/// An errror thrown during JavaScript execution.
/// See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error
public class JavaScriptError: JavaScriptObject, Error, @unchecked Sendable {
  lazy var name: String? = self["name"]
  
  lazy var message: String? = self["message"]
  
  lazy var stack: String? = self["stack"]
}

extension JavaScriptError: CustomStringConvertible {
  public var description: String {
    return jsValue.toString()
  }
}

/// A type that references an underlying JavaScript object.
public class JavaScriptObject: JavaScriptValueDecodable {
  let jsValue: JSValue
  unowned let bridge: JavaScriptBridge
  
  static func fromJSValue(_ jsValue: JSValue, bridge: JavaScriptBridge) -> Self {
    return bridge.wrap(jsValue)
  }
    
  required init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
    precondition(jsValue.isObject)
        
    self.jsValue = jsValue
    self.bridge = bridge
  }
  
  subscript(property: Any) -> JSValue {
    return jsValue[property]
  }
  
  subscript<Decodable: JavaScriptValueDecodable>(property: Any) -> Decodable {
    return bridge.fromJSValue(jsValue[property])
  }
  
  private func call(_ functionName: String, with arguments: [Any]) throws -> JSValue {
    return try bridge.throwingJavaScriptErrorIfNeeded {
      let function = jsValue[functionName]
      
      precondition(!function.isUndefined, "Function \(functionName) is undefined")
      
      return function.call(withArguments: bridge.unwrap(arguments))!
    }
  }
  
  func call(_ functionName: String, with arguments: Any...) throws -> JSValue {
    try call(functionName, with: arguments)
  }
  
  func call<Decodable: JavaScriptValueDecodable>(_ functionName: String, with arguments: Any...) throws -> Decodable {
    return bridge.fromJSValue(try call(functionName, with: arguments))
  }
  
  private func invokeMethod(_ methodName: String, with arguments: [Any]) throws -> JSValue {
    return try bridge.throwingJavaScriptErrorIfNeeded {
      jsValue.invokeMethod(methodName, withArguments: bridge.unwrap(arguments))
    }
  }
  
  func invokeMethod(_ methodName: String, with arguments: Any...) throws -> JSValue {
    try invokeMethod(methodName, with: arguments)
  }
  
  func invokeMethod<Decodable: JavaScriptValueDecodable>(_ methodName: String, with arguments: Any...) throws -> Decodable {
    return bridge.fromJSValue(try invokeMethod(methodName, with: arguments))
  }
  
  func construct<Wrapper: JavaScriptObject>(with arguments: Any...) throws -> Wrapper {
    return bridge.fromJSValue(try bridge.throwingJavaScriptErrorIfNeeded {
      jsValue.construct(withArguments: bridge.unwrap(arguments))
    })
  }
}

extension JavaScriptObject: Equatable {
  public static func ==(lhs: JavaScriptObject, rhs: JavaScriptObject) -> Bool {
    return lhs.jsValue == rhs.jsValue
  }
}

extension JavaScriptObject: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "<\(type(of: self)): \(jsValue.toString()!)>"
  }
}

/// The JavaScript bridge is responsible for converting values to and from type-safe wrapper objects. It also ensures exceptions thrown from JavaScript wrapped and rethrown.
class JavaScriptBridge {
  private var context: JSContext
  
  // In JavaScript, classes are represented by constructor functions. We need access to these when checking
  // the type of a received value in `wrap(_)` below.
  // We keep a bidirectional mapping between constructors and wrapper types so we can both access the
  // corresponding wrapper type, and perform an `instanceof` check based on the corresponding constructor
  // for the expected wrapper type in case there isn't a direct match and we are receiving a subtype.
  private var constructorToWrapperType: [JSValue /* constructor function */: JavaScriptObject.Type] = [:]
  private var wrapperTypeToConstructor: [AnyHashable /* JavaScriptObject.Type */: JSValue] = [:]
  
  // We keep a map between `JSValue` objects and wrapper objects, to avoid repeatedly creating new wrappers and
  // to guarantee referential equality.
  // TODO: We may want to consider a weak map here, because this does mean we'll be keeping alive
  // all objects that are passed over the bridge both on the Swift side and in JavaScript
  // ('JSValue` is an Objective-C object that uses `JSValueProtect` to mark the underlying JavaScript
  // object as inelligable for garbage collection.)
  private var wrapperMap: [JSValue: JavaScriptObject] = [:]
  
  init(context: JSContext) {
    self.context = context
    
    register(JavaScriptObject.self, forJavaScriptClass: "Object", from: context.globalObject)
    register(JavaScriptError.self, forJavaScriptClass: "Error", from: context.globalObject)
  }
  
  public func register(_ wrapperType: JavaScriptObject.Type, forJavaScriptClass className: String? = nil, from scope: JavaScriptObject) {
    register(wrapperType, forJavaScriptClass: className, from: scope.jsValue)
  }
  
  public func register(_ wrapperType: JavaScriptObject.Type, forJavaScriptClass className: String? = nil, from scope: JSValue) {
    let className = className ?? String(describing: wrapperType)
    
    let constructor = scope[className]
    precondition(constructor.isObject, "Couldn't find JavaScript constructor function for class \(className). Make sure the class is exported from the library's entry point.")

    constructorToWrapperType[constructor] = wrapperType
    wrapperTypeToConstructor[ObjectIdentifier(wrapperType)] = constructor
  }
  
  func fromJSValue<Decodable: JavaScriptValueDecodable>(_ jsValue: JSValue) -> Decodable {
    return Decodable.fromJSValue(jsValue, bridge: self)
  }
  
  fileprivate func wrap<Wrapper: JavaScriptObject>(_ jsValue: JSValue) -> Wrapper {
    if let wrapper = wrapperMap[jsValue] {
      return checkedDowncast(wrapper)
    }
    
    precondition(jsValue.isObject, "Expected JavaScript object but found: \(jsValue)")
    
    let wrapperType: JavaScriptObject.Type
    
    let constructor = jsValue["constructor"]
    
    // If an object doesn't have a prototype or has `Object` as its direct prototype,
    // we assume it is of the expected type and let the wrapper handle further type checks if needed.
    // This occurs for pseudo-classes like the AST nodes for example, that rely on a `kind` property
    // to indicate their type instead of a prototype.
    if constructor.isUndefined || constructor["name"].toString() == "Object" {
      wrapperType = Wrapper.self
    } else if let registeredType = constructorToWrapperType[constructor] {
      // We have a wrapper type registered for the JavaScript class.
      wrapperType = registeredType
    } else {
      // We may have received an unregistered subtype of the expected type, and we don't necessarily
      // have a wrapper registered for every subtype (this is likely to happen with
      // subtypes of `Error` for example). So if we can verify the value is indeed an instance of
      // the expected type we use that as the wrapper.
      
      guard let expectedConstructor = wrapperTypeToConstructor[ObjectIdentifier(Wrapper.self)] else {
        preconditionFailure("""
          Couldn't find JavaScript constructor for wrapper type \(Wrapper.self). \
          Make sure the type is registered with the bridge."
          """)
      }
      
      if jsValue.isInstance(of: expectedConstructor) {
        wrapperType = Wrapper.self
      } else {
        preconditionFailure("""
          Object with JavaScript constructor \(constructor["name"]) doesn't seem to be \
          an instance of expected type \(expectedConstructor["name"])"
          """)
      }
    }
    
    let wrapper = wrapperType.init(jsValue, bridge: self)
    wrapperMap[jsValue] = wrapper
    return checkedDowncast(wrapper)
  }
  
  fileprivate func unwrap(_ values: [Any]) -> [Any] {
    return values.map { value in
      if let unwrappable = value as? CustomJavaScriptValueUnwrappable {
        return unwrappable.unwrapJSValue
      } else {
        return value
      }
    }
  }
  
  @discardableResult func throwingJavaScriptErrorIfNeeded<ReturnValue>(body: () -> ReturnValue) throws -> ReturnValue {
    let result = body()
        
    // Errors thrown from JavaScript are stored on the context and ignored by default.
    // To surface these to callers, we wrap them in a `JavaScriptError` and throw.
    if let exception = context.exception {
      throw fromJSValue(exception) as JavaScriptError
    }
    
    return result
  }  
}

/// A type that can decode itself from a JavaScript value.
protocol JavaScriptValueDecodable {
  // We rely on a static `fromJSValue` method to allow for polymorphic construction and to be able
  // to return existing wrappers instead of creating new instances.
  static func fromJSValue(_ jsValue: JSValue, bridge: JavaScriptBridge) -> Self
  
  init(_ jsValue: JSValue, bridge: JavaScriptBridge)
}

extension JavaScriptValueDecodable {
  static func fromJSValue(_ jsValue: JSValue, bridge: JavaScriptBridge) -> Self {
    return Self.init(jsValue, bridge: bridge)
  }
}

extension Optional: JavaScriptValueDecodable where Wrapped: JavaScriptValueDecodable {
  init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
    if jsValue.isUndefined || jsValue.isNull {
      self = nil
    } else {
      self = Wrapped.fromJSValue(jsValue, bridge: bridge)
    }
  }
}

extension Array: JavaScriptValueDecodable where Element: JavaScriptValueDecodable {
  init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
    self = jsValue.toArray { Element.fromJSValue($0, bridge: bridge) }
  }
}

extension Dictionary: JavaScriptValueDecodable where Key == String, Value: JavaScriptValueDecodable {
  init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
    self = jsValue.toDictionary { Value.fromJSValue($0, bridge: bridge) }
  }
}

extension String: JavaScriptValueDecodable {
  init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
    precondition(jsValue.isString, "Expected JavaScript string but found: \(jsValue)")
    self = jsValue.toString()
  }
}

extension Int: JavaScriptValueDecodable {
  init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
    precondition(jsValue.isNumber, "Expected JavaScript number but found: \(jsValue)")
    self = jsValue.toInt()
  }
}

extension Bool: JavaScriptValueDecodable {
  init(_ jsValue: JSValue, bridge: JavaScriptBridge) {
    precondition(jsValue.isBoolean, "Expected JavaScript boolean but found: \(jsValue)")
    self = jsValue.toBool()
  }
}

extension JSValue {
  subscript(_ property: Any) -> JSValue {
    return objectForKeyedSubscript(property)
  }
  
  func toInt() -> Int {
    return Int(toInt32())
  }
  
  // The regular `toArray()` does a deep convert of all elements, which means JavaScript objects
  // will be converted to `NSDictionary` and we lose the ability to pass references back to JavaScript.
  // That's why we manually construct an array by iterating over the indexes here.
  func toArray<Element>(_ transform: (JSValue) throws -> Element) rethrows -> [Element] {
    precondition(isArray, "Expected JavaScript array but found: \(self)")
    
    let length = self["length"].toInt()
    
    var array = [Element]()
    array.reserveCapacity(length)
    
    for index in 0..<length {
      let element = try transform(self[index])
      array.append(element)
    }
    
    return array
  }
  
  // The regular `toDictionary()` does a deep convert of all elements, which means JavaScript objects
  // will be converted to `NSDictionary` and we lose the ability to pass references back to JavaScript.
  // That's why we manually construct a dictionary by iterating over the keys here.
  func toDictionary<Value>(_ transform: (JSValue) throws -> Value) rethrows -> [String: Value] {
    precondition(isObject, "Expected JavaScript object but found: \(self)")
    
    guard let keys = context.globalObject["Object"].invokeMethod("keys", withArguments: [self])?.toArray() as? [String] else {
      preconditionFailure("Couldn't get keys for object \(self)")
    }
        
    var dictionary = [String: Value]()
    
    for key in keys {
      let element = try transform(self.objectForKeyedSubscript(key))
      dictionary[key] = element
    }
    
    return dictionary
  }
}

private func checkedDowncast<ExpectedType: AnyObject>(_ object: AnyObject) -> ExpectedType {
  guard let expected = object as? ExpectedType else {
    preconditionFailure("Expected type to be \(ExpectedType.self), but found \(type(of: object))")
  }
  
  return expected
}

fileprivate protocol CustomJavaScriptValueUnwrappable {
  var unwrapJSValue: Any { get }
}

extension JavaScriptObject: CustomJavaScriptValueUnwrappable {
  var unwrapJSValue: Any {
    return jsValue
  }
}

extension Optional: CustomJavaScriptValueUnwrappable where Wrapped: CustomJavaScriptValueUnwrappable {
  var unwrapJSValue: Any {
    return map(\.unwrapJSValue) as Any
  }
}

extension Array: CustomJavaScriptValueUnwrappable where Element: CustomJavaScriptValueUnwrappable {
  var unwrapJSValue: Any {
    return map(\.unwrapJSValue)
  }
}

extension Dictionary: CustomJavaScriptValueUnwrappable where Key == String, Value: CustomJavaScriptValueUnwrappable {
  var unwrapJSValue: Any {
    return mapValues(\.unwrapJSValue)
  }
}
