import Foundation
#if !COCOAPODS
@_spi(Internal) import ApolloAPI
#endif

enum FieldPolicyResult {
  case single(CacheKeyInfo)
  case list([CacheKeyInfo])
}

struct FieldPolicyDirectiveEvaluator {
  let field: Selection.Field
  let fieldPolicy: Selection.FieldPolicyDirective
  let arguments: [String: InputValue]
  let variables: GraphQLOperation.Variables?
  
  init?(
    field: Selection.Field,
    variables: GraphQLOperation.Variables?
  ) {
    self.field = field
    self.variables = variables
    
    guard let fieldPolicy = field.fieldPolicy else {
      return nil
    }
    self.fieldPolicy = fieldPolicy
    
    guard let arguments = field.arguments else {
      return nil
    }
    self.arguments = arguments
  }
  
  func resolveFieldPolicy() -> FieldPolicyResult? {   
    let keyArgs = parseKeyArgs(for: fieldPolicy)

    var singleValueArgs = [String?](repeating: nil, count: keyArgs.count)
    var listArgIndex: Int? = nil
    var listArgValues: [String] = []

    for (index, arg) in keyArgs.enumerated() {
      guard let argVal = arguments[arg.name] else {
        return nil
      }

      guard let resolved = argVal.resolveValue(
        keyPath: arg.path,
        variables: variables
      ), !resolved.isEmpty else {
        return nil
      }
      
      if resolved.count > 1 {
        listArgIndex = index
        listArgValues = resolved
      } else {
        guard let value = resolved.first else {
          return nil
        }
        singleValueArgs[index] = value
      }
    }

    if let listArgIndex = listArgIndex {
      guard let cacheKeyList = processKeyList(
        listArgIndex: listArgIndex,
        listArgValues: listArgValues,
        singleValueArgs: singleValueArgs,
        keyArgs: keyArgs
      ) else {
        return nil
      }
      return .list(cacheKeyList)
    } else {
      let parts = singleValueArgs.compactMap { $0 }
      return .single(CacheKeyInfo(id: parts.joined(separator: "+")))
    }
  }
  
  private func processKeyList(
    listArgIndex: Int,
    listArgValues: [String],
    singleValueArgs: [String?],
    keyArgs: [ParsedKey]
  ) -> [CacheKeyInfo]? {
    var keys: [CacheKeyInfo] = []
    keys.reserveCapacity(listArgValues.count)
    for value in listArgValues {
      var parts = [String]()
      parts.reserveCapacity(keyArgs.count)
      for keyIndex in 0..<keyArgs.count {
        if keyIndex == listArgIndex {
          parts.append(value)
        } else if let singleValue = singleValueArgs[keyIndex] {
          parts.append(singleValue)
        } else {
          return nil
        }
      }
      keys.append(CacheKeyInfo(id: parts.joined(separator: "+")))
    }
    return keys
  }
  
  private func parseKeyArgs(for fieldPolicy: Selection.FieldPolicyDirective) -> [ParsedKey] {
    fieldPolicy.keyArgs.map { key in
      if let dot = key.firstIndex(of: ".") {
        let name = String(key[..<dot])
        let rest = key[key.index(after: dot)...]
        return ParsedKey(name: name, path: rest.split(separator: ".").map(String.init))
      } else {
        return ParsedKey(name: key, path: nil)
      }
    }
  }
  
  private struct ParsedKey {
    let name: String
    let path: [String]?
  }
}

extension ScalarType {
  fileprivate var cacheKeyComponentStringValue: String {
    switch self {
    case let strVal as String:
      return strVal
      
    case let boolVal as Bool:
      return boolVal ? "true" : "false"
      
    case let intVal as Int:
      return String(intVal)
      
    case let doubleVal as Double:
      return String(doubleVal)
      
    case let floatVal as Float:
      return String(floatVal)
      
    default:
      return String(describing: self)
    }
  }
}

extension JSONObject {
  fileprivate func traverse(
    to path: ArraySlice<String>
  ) -> JSONValue? {
    guard let head = path.first else { return self as JSONValue }
    guard let next = self[head] else { return nil }
    if path.count == 1 { return next }
    if let nested = next as? JSONObject {
      return nested.traverse(to: path.dropFirst())
    }
    return nil
  }
}

extension InputValue {
  fileprivate func resolveValue(keyPath: [String]? = nil, variables: [String: (any GraphQLOperationVariableValue)]? = nil) -> [String]? {
    switch self {
    case .scalar(let scalar):
      return [scalar.cacheKeyComponentStringValue]
    case .variable(let varName):
      guard let varValue = variables?[varName] else {
        return nil
      }
      if let encodableValue = varValue._jsonEncodableValue {
        return cacheKeyComponentStringValue(encodableValue._jsonValue, keyPath: keyPath)
      }
      return nil
    case .list(let list):
      if list.contains(where: { if case .list = $0 { return true } else { return false } }) {
        return nil
      }
      let values = list.compactMap { $0.resolveValue()?.first }
      guard !values.isEmpty else { return nil }
      return values
    case .object(let dict):
      guard let keyPath, !keyPath.isEmpty else { return nil }
      guard let targetValue = self.traverse(through: dict, to: keyPath[...]) else { return nil }
      return targetValue.resolveValue()
    default:
      return nil
    }
  }
  
  fileprivate func traverse(
    through dict: [String: InputValue],
    to path: ArraySlice<String>
  ) -> InputValue? {
    guard let head = path.first else { return .object(dict) }
    guard let next = dict[head] else { return nil }
    if path.count == 1 { return next }
    if case .object(let nested) = next {
      return traverse(through: nested, to: path.dropFirst())
    }
    return nil
  }
  
  fileprivate func cacheKeyComponentStringValue(_ jsonValue: JSONValue, keyPath: [String]? = nil) -> [String]? {
    switch jsonValue {
    case let strVal as String:
      return [strVal]
      
    case let boolVal as Bool:
      return boolVal ? ["true"] : ["false"]
      
    case let intVal as Int:
      return [String(intVal)]
      
    case let doubleVal as Double:
      return [String(doubleVal)]
      
    case let floatVal as Float:
      return [String(floatVal)]
      
    case let arrVal as [JSONValue]:
      let values: [String] = arrVal.compactMap { cacheKeyComponentStringValue($0)?.first }
      guard !values.isEmpty else { return nil }
      return values
      
    case let objVal as JSONObject:
      guard let keyPath, !keyPath.isEmpty else { return nil }
      guard let targetValue = objVal.traverse(to: keyPath[...]) else { return nil }
      return cacheKeyComponentStringValue(targetValue)
      
    default:
      return [String(describing: self)]
    }
  }

}
