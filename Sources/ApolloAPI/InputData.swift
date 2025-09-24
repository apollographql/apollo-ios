import Foundation

extension FieldPolicy {
  
  /// An opaque wrapper for input data of a GraphQL operation. This type wraps data from the
  /// arguments and variables for the given field/operation to provide an easy way to work
  /// with that data to create cache keys.
  public struct InputData {
    public let _rawType: RawType
    public let _variables: GraphQLOperation.Variables?
    
    public init(
      _rawType: RawType,
      _variables: GraphQLOperation.Variables?
    ) {
      self._rawType = _rawType
      self._variables = _variables
    }
    
    @inlinable public subscript(_ key: String) -> (any ScalarType)? {
      switch _rawType {
      case .inputValue(let dict):
        guard let value = dict[key] else {
          return nil
        }
        return value.toAnyScalar(_variables: _variables)
      case .json(let dict):
        guard let value = dict[key] else {
          return nil
        }
        return jsonValueToAnyScalar(value)
      }
    }
    
    @_disfavoredOverload
    @inlinable public subscript(_ key: String) -> InputListData? {
      switch _rawType {
      case .inputValue(let dict):
        guard let value = dict[key] else {
          return nil
        }
        return value.toFieldInputListData(_variables: _variables)
      case .json(let dict):
        guard let value = dict[key] else {
          return nil
        }
        return jsonValueToFieldInputListData(value)
      }
    }
    
    @_disfavoredOverload
    @inlinable public subscript(_ key: String) -> InputData? {
      switch _rawType {
      case .inputValue(let dict):
        guard let value = dict[key] else { return nil }
        return value.toFieldInputData(_variables: _variables)
      case .json(let dict):
        guard let value = dict[key] else {
          return nil
        }
        return jsonValueToFieldInputData(value)
      }
    }
    
    public enum RawType {
      case inputValue([String: InputValue])
      case json(JSONObject)
    }
  }

  /// An opaque wrapper for input data of a GraphQL operation. This type wraps data from the
  /// arguments and variables for the given field/operation to provide an easy way to work
  /// with that data to create cache keys.
  public struct InputListData {
    public let _rawType: RawType
    public let _variables: GraphQLOperation.Variables?
    public let count: Int
    
    public init(
      _rawType: RawType,
      _variables: GraphQLOperation.Variables?
    ) {
      self._rawType = _rawType
      self._variables = _variables
      
      switch _rawType {
      case .hashable(let list):
        self.count = list.count
      case .inputValue(let list):
        self.count = list.count
      }
    }
    
    @inlinable public subscript(_ index: Int) -> (any ScalarType)? {
      switch _rawType {
      case .hashable(let list):
        let value: JSONValue = list[index]
        return jsonValueToAnyScalar(value)
      case .inputValue(let list):
        let value = list[index]
        return value.toAnyScalar(_variables: _variables)
      }
    }
    
    @_disfavoredOverload
    @inlinable public subscript(_ index: Int) -> InputData? {
      switch _rawType {
      case .hashable(let list):
        let value = list[index]
        return jsonValueToFieldInputData(value)
      case .inputValue(let list):
        let value = list[index]
        return value.toFieldInputData(_variables: _variables)
      }
    }
    
    @_disfavoredOverload
    @inlinable public subscript(_ index: Int) -> InputListData? {
      switch _rawType {
      case .hashable(let list):
        let value = list[index]
        return jsonValueToFieldInputListData(value)
      case .inputValue(let list):
        let value = list[index]
        return value.toFieldInputListData(_variables: _variables)
      }
    }
   
    public enum RawType {
      case hashable([JSONValue])
      case inputValue([InputValue])
    }
  }
  
  // MARK: - JSONValue Helper Functions
  
  @usableFromInline static func jsonValueToAnyScalar(_ val: any Hashable & Sendable) -> (any ScalarType)? {
    var value = val
    switch value {
    case let boolVal as Bool:
      value = boolVal
    case let intVal as any FixedWidthInteger:
      value = Int32(intVal)
    case let str as NSString:
      value = str as String
    default:
      break
    }
    
    switch value {
    case let scalar as any ScalarType:
      return scalar
    case let customScalar as any CustomScalarType:
      return customScalar._jsonValue as? (any ScalarType)
    default:
      return nil
    }
  }
  
  @usableFromInline static func jsonValueToFieldInputListData(_ val: JSONValue) -> FieldPolicy.InputListData? {
    if let list = val as? [JSONValue] {
      return FieldPolicy.InputListData(_rawType: .hashable(list), _variables: nil)
    }
    return nil
  }
  
  @usableFromInline static func jsonValueToFieldInputData(_ val: JSONValue) -> FieldPolicy.InputData? {
    if let object = val as? JSONObject {
      return FieldPolicy.InputData(_rawType: .json(object), _variables: nil)
    }
    return nil
  }
}

extension InputValue {
  @usableFromInline func toAnyScalar(_variables: GraphQLOperation.Variables?) -> (any ScalarType)? {
    switch self {
    case .scalar(let scalar):
      return scalar
    case .variable(let varName):
      guard let varValue = _variables?[varName] else { return nil }
      return varValue._jsonEncodableValue?._jsonValue as? (any ScalarType)
    default:
      return nil
    }
  }
  
  @usableFromInline func toFieldInputListData(_variables: GraphQLOperation.Variables?) -> FieldPolicy.InputListData? {
    switch self {
    case .list(let list):
      return FieldPolicy.InputListData(_rawType: .inputValue(list), _variables: _variables)
    case .variable(let varName):
      guard let varValue = _variables?[varName],
            let list = varValue._jsonEncodableValue?._jsonValue as? [JSONValue] else {
        return nil
      }
      return FieldPolicy.InputListData(_rawType: .hashable(list), _variables: _variables)
    default:
      return nil
    }
  }
  
  @usableFromInline func toFieldInputData(_variables: GraphQLOperation.Variables?) -> FieldPolicy.InputData? {
    switch self {
    case .object(let object):
      return FieldPolicy.InputData(_rawType: .inputValue(object), _variables: _variables)
    case .variable(let varName):
      guard let varValue = _variables?[varName],
            let object = varValue._jsonEncodableValue?._jsonValue as? JSONObject else {
        return nil
      }
      return FieldPolicy.InputData(_rawType: .json(object), _variables: _variables)
    default:
      return nil
    }
  }
}
