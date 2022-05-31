/// A structure that wraps the underlying data dictionary used by `SelectionSet`s.
public struct DataDict: Hashable {

  public let _data: JSONObject
  public let _variables: GraphQLOperation.Variables?

  @inlinable public init(
    _ data: JSONObject,
    variables: GraphQLOperation.Variables?
  ) {
    self._data = data
    self._variables = variables
  }

  @inlinable public subscript<T: AnyScalarType>(_ key: String) -> T {
    _data[key] as! T
  }
  
  @inlinable public subscript<T: SelectionSetEntityValue>(_ key: String) -> T {
    T.init(fieldData: _data[key], variables: _variables)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(_data)
    hasher.combine(_variables?.jsonEncodableValue?.jsonValue)
  }

  public static func == (lhs: DataDict, rhs: DataDict) -> Bool {
    lhs._data == rhs._data &&
    lhs._variables?.jsonEncodableValue?.jsonValue == rhs._variables?.jsonEncodableValue?.jsonValue
  }
}

public protocol SelectionSetEntityValue {
  init(fieldData: AnyHashable?, variables: GraphQLOperation.Variables?)
}

extension AnySelectionSet {
  @inlinable public init(fieldData: AnyHashable?, variables: GraphQLOperation.Variables?) {
    guard let fieldData = fieldData as? JSONObject else {
      fatalError("\(Self.self) expected data for entity.")
    }
    self.init(data: DataDict(fieldData, variables: variables))
  }
}

extension Optional: SelectionSetEntityValue where Wrapped: SelectionSetEntityValue {
  @inlinable public init(fieldData: AnyHashable?, variables: GraphQLOperation.Variables?) {
    guard case let .some(fieldData) = fieldData else {
      self = .none
      return
    }
    self = .some(Wrapped.init(fieldData: fieldData, variables: variables))
  }
}

extension Array: SelectionSetEntityValue where Element: SelectionSetEntityValue {
  @inlinable public init(fieldData: AnyHashable?, variables: GraphQLOperation.Variables?) {
    guard let fieldData = fieldData as? [AnyHashable?] else {
      fatalError("\(Self.self) expected list of data for entity.")
    }
    self = fieldData.map { Element.init(fieldData:$0, variables: variables) }
  }
}
