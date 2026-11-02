import Foundation
@_spi(Internal) import ApolloAPI

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
        keyPath: arg.path[...],
        variables: variables
      ), !resolved.values.isEmpty else {
        return nil
      }
      
      if resolved.isList {
        guard listArgIndex == nil else {
          return nil
        }
        listArgIndex = index
        listArgValues = resolved.values
      } else {
        singleValueArgs[index] = resolved.values.first
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
        return ParsedKey(name: key, path: [])
      }
    }
  }
  
  private struct ParsedKey {
    let name: String
    let path: [String]
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

private struct ResolvedKeyArgValue {
  let values: [String]
  let isList: Bool

  init(single value: String) {
    self.values = [value]
    self.isList = false
  }

  init(list values: [String]) {
    self.values = values
    self.isList = true
  }
}

extension InputValue {
  /// Resolves the cache key components at the end of `keyPath`, with one component for each element of
  /// a list along the path. Returns `nil` if any element can't be resolved to a single leaf value.
  fileprivate func resolveValue(
    keyPath: ArraySlice<String>,
    variables: GraphQLOperation.Variables?
  ) -> ResolvedKeyArgValue? {
    switch self {
    case .list(let elements):
      var values: [String] = []
      values.reserveCapacity(elements.count)
      for element in elements {
        guard let value = element.resolveLeafValue(keyPath: keyPath, variables: variables) else {
          return nil
        }
        values.append(value)
      }
      return values.isEmpty ? nil : ResolvedKeyArgValue(list: values)

    case .object(let dict):
      guard let head = keyPath.first, let next = dict[head] else { return nil }
      return next.resolveValue(keyPath: keyPath.dropFirst(), variables: variables)

    case .variable(let varName):
      guard let jsonValue = variables?[varName]?._jsonEncodableValue?._jsonValue else {
        return nil
      }
      return Self.cacheKeyComponentStringValues(jsonValue, keyPath: keyPath)

    default:
      return resolveLeafValue(keyPath: keyPath, variables: variables).map(ResolvedKeyArgValue.init(single:))
    }
  }

  private func resolveLeafValue(
    keyPath: ArraySlice<String>,
    variables: GraphQLOperation.Variables?
  ) -> String? {
    switch self {
    case .scalar(let scalar):
      return keyPath.isEmpty ? scalar.cacheKeyComponentStringValue : nil

    case .object(let dict):
      guard let head = keyPath.first, let next = dict[head] else { return nil }
      return next.resolveLeafValue(keyPath: keyPath.dropFirst(), variables: variables)

    case .variable(let varName):
      guard let jsonValue = variables?[varName]?._jsonEncodableValue?._jsonValue else {
        return nil
      }
      return Self.cacheKeyComponentStringValue(jsonValue, keyPath: keyPath)

    default:
      return nil
    }
  }

  private static func cacheKeyComponentStringValues(
    _ jsonValue: JSONValue,
    keyPath: ArraySlice<String>
  ) -> ResolvedKeyArgValue? {
    switch jsonValue {
    case let arrVal as [JSONValue]:
      var values: [String] = []
      values.reserveCapacity(arrVal.count)
      for element in arrVal {
        guard let value = cacheKeyComponentStringValue(element, keyPath: keyPath) else {
          return nil
        }
        values.append(value)
      }
      return values.isEmpty ? nil : ResolvedKeyArgValue(list: values)

    case let objVal as JSONObject:
      guard let head = keyPath.first, let next = objVal[head] else { return nil }
      return cacheKeyComponentStringValues(next, keyPath: keyPath.dropFirst())

    default:
      return cacheKeyComponentStringValue(jsonValue, keyPath: keyPath).map(ResolvedKeyArgValue.init(single:))
    }
  }

  private static func cacheKeyComponentStringValue(
    _ jsonValue: JSONValue,
    keyPath: ArraySlice<String>
  ) -> String? {
    if let objVal = jsonValue as? JSONObject {
      guard let head = keyPath.first, let next = objVal[head] else { return nil }
      return cacheKeyComponentStringValue(next, keyPath: keyPath.dropFirst())
    }

    guard keyPath.isEmpty else { return nil }

    switch jsonValue {
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

    case is [JSONValue], is NSNull:
      return nil

    default:
      return String(describing: jsonValue)
    }
  }
}
