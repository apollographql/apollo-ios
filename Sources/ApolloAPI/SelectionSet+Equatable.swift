import Foundation

public extension SelectionSet {

  typealias FieldValue = any Hashable

  /// Creates a hash using a narrowly scoped algorithm that only combines fields in the underlying data
  /// that are relevant to the `SelectionSet`. This ensures that hashes for a fragment do not
  /// consider fields that are not included in the fragment, even if they are present in the data.
  func hash(into hasher: inout Hasher) {
    hasher.combine(self.fieldsForEquality())
  }

  /// Checks for equality using a narrowly scoped algorithm that only compares fields in the underlying data
  /// that are relevant to the `SelectionSet`. This ensures that equality checks for a fragment do not
  /// consider fields that are not included in the fragment, even if they are present in the data.
  static func ==(lhs: Self, rhs: Self) -> Bool {
    return Self.equatableCheck(
      lhs.fieldsForEquality(),
      rhs.fieldsForEquality()
    )
  }

  @inlinable
  internal static func equatableCheck(
    _ lhs: [String: any Hashable],
    _ rhs: [String: any Hashable]
  ) -> Bool {
    guard lhs.keys == rhs.keys else { return false }

    return lhs.allSatisfy {
      guard let rhsValue = rhs[$0.key],
            equatableCheck($0.value, rhsValue) else {
        return false
      }
      return true
    }
  }

  @inlinable
  internal static func equatableCheck<T: Hashable>(
    _ lhs: T,
    _ rhs: any Hashable
  ) -> Bool {
    if let lhs = lhs as? [any Hashable],
       let rhs = rhs as? [any Hashable]  {

      return lhs.elementsEqual(rhs) { l, r in
        equatableCheck(l, r)
      }
    }

    return lhs == rhs as? T
  }

  private func fieldsForEquality() -> [String: FieldValue] {
    var fields: [String: FieldValue] = [:]
    var addedFragments: Set<ObjectIdentifier> = []

    for fragment in type(of: self).__fulfilledFragments {
      self.addFulfilledSelections(of: fragment, to: &fields, addedFragments: &addedFragments)
    }

    return fields
  }

  private func addFulfilledSelections(
    of selectionSetType: any SelectionSet.Type,
    to fields: inout [String: FieldValue],
    addedFragments: inout Set<ObjectIdentifier>
  ) {
    let selectionSetTypeId = ObjectIdentifier(selectionSetType)
    guard !addedFragments.contains(selectionSetTypeId),
          self.__data.fragmentIsFulfilled(selectionSetType) else {
      return
    }

    addedFragments.insert(selectionSetTypeId)

    for selection in selectionSetType.__selections {
      switch selection {
      case let .field(field):
        add(field: field, to: &fields)

      case let .inlineFragment(typeCase):
        self.addFulfilledSelections(of: typeCase, to: &fields, addedFragments: &addedFragments)

      case let .conditional(_, selections):
        self.addConditionalSelections(selections, to: &fields, addedFragments: &addedFragments)

      case let .fragment(fragmentType):
        self.addFulfilledSelections(of: fragmentType, to: &fields, addedFragments: &addedFragments)

      case let .deferred(_, fragmentType, _):
        self.addFulfilledSelections(of: fragmentType, to: &fields, addedFragments: &addedFragments)
      }
    }
  }

  private func addConditionalSelections(
    _ selections: [Selection],
    to fields: inout [String: FieldValue],
    addedFragments: inout Set<ObjectIdentifier>
  ) {
    for selection in selections {
      switch selection {
      case let .inlineFragment(typeCase):
        self.addFulfilledSelections(of: typeCase, to: &fields, addedFragments: &addedFragments)

      case let .fragment(fragment):
        self.addFulfilledSelections(of: fragment, to: &fields, addedFragments: &addedFragments)

      case let .deferred(_, fragment, _):
        self.addFulfilledSelections(of: fragment, to: &fields, addedFragments: &addedFragments)

      case let .conditional(_, selections):
        addConditionalSelections(selections, to: &fields, addedFragments: &addedFragments)

      case let .field(field):
        add(field: field, to: &fields)
      }
    }
  }

  private func add(
    field: Selection.Field,
    to fields: inout [String: FieldValue]
  ) {
    let nullableFieldData = (self.__data._data[field.responseKey]?.base as? FieldValue).asNullable
    let fieldData: FieldValue
    switch nullableFieldData {
    case let .some(value):
      fieldData = value
    case .none, .null:
      return
    }

    addData(for: field.type)

    func addData(for type: Selection.Field.OutputType, inList: Bool = false) {
      switch type {
      case .scalar, .customScalar:
        if inList {
          guard let listData = fieldData as? [AnyHashable] else {
            preconditionFailure("Expected list data for field: \(field)")
          }

          fields[field.responseKey] = unwrapAnyHashable(list: listData) as FieldValue
        } else {
          fields[field.responseKey] = fieldData
        }

      case let .nonNull(innerType):
        addData(for: innerType, inList: inList)

      case let .list(innerType):
        addData(for: innerType, inList: true)

      case let .object(selectionSetType):
        switch inList {
        case false:
          guard let objectData = fieldData as? DataDict else {
            preconditionFailure("Expected object data for object field: \(field)")
          }
          fields[field.responseKey] = selectionSetType.init(_dataDict: objectData)

        case true:
          guard let listData = fieldData as? [FieldValue] else {
            preconditionFailure("Expected list data for field: \(field)")
          }

          fields[field.responseKey] = convertElements(of: listData, to: selectionSetType) as FieldValue
        }
      }
    }
  }

  private func convertElements(
    of list: [FieldValue],
    to selectionSetType: any RootSelectionSet.Type
  ) -> [FieldValue] {
    if let dataDictList = list as? [DataDict] {
      return dataDictList.map { selectionSetType.init(_dataDict: $0) }
    }

    if let nestedList = list as? [[FieldValue]] {
      return nestedList.map { self.convertElements(of: $0, to: selectionSetType) as FieldValue }
    }

    preconditionFailure("Expected list data to contain objects.")
  }

  private func unwrapAnyHashable(
    list: [AnyHashable]
  ) -> [FieldValue] {
    if let nestedList = list as? [[AnyHashable]] {
      return nestedList.map { self.unwrapAnyHashable(list: $0) as FieldValue }
    }

    return list.map {
      guard let base = $0.base as? FieldValue else {
        preconditionFailure("Expected list data to contain objects.")
      }
      return base
    }

  }

}

extension Hasher {

  @inlinable
  public mutating func combine(_ optionalJSONValue: (any Hashable)?) {
    if let value = optionalJSONValue {
      self.combine(1 as UInt8)
      self.combine(value)
    } else {
      // This mimics the implementation of combining a nil optional from the Swift language core
      // Source reference at:
      // https://github.com/swiftlang/swift/blob/main/stdlib/public/core/Optional.swift#L590
      self.combine(0 as UInt8)
    }
  }

  @inlinable
  public mutating func combine<T: Hashable>(
    _ dictionary: [T: any Hashable]
  ) {
    // From Dictionary's Hashable implementation
    var commutativeHash = 0
    for (key, value) in dictionary {
      var elementHasher = self
      elementHasher.combine(key)
      elementHasher.combine(AnyHashable(value))
      commutativeHash ^= elementHasher.finalize()
    }
    self.combine(commutativeHash)
  }

  @inlinable
  public mutating func combine<T: Hashable>(
    _ dictionary: [T: any Hashable]?
  ) {
    if let value = dictionary {
      self.combine(value)
    } else {
      self.combine(Optional<[T: any Hashable]>.none)
    }
  }
}

fileprivate protocol AnyOptional {}

@_spi(Internal)
extension Optional: AnyOptional { }

fileprivate extension Optional {

  /// Converts the optional to a `GraphQLNullable.
  ///
  /// - Double nested optional (ie. `Optional.some(nil)`) -> `GraphQLNullable.null`.
  /// - `Optional.none` -> `GraphQLNullable.none`
  /// - `Optional.some` -> `GraphQLNullable.some`
  var asNullable: GraphQLNullable<Wrapped> {
    unwrapAsNullable()
  }

  private func unwrapAsNullable(nullIfNil: Bool = false) -> GraphQLNullable<Wrapped> {
    switch self {
    case .none: return nullIfNil ? .null : .none

    case .some(let value as any AnyOptional):
      return (value as! Self).unwrapAsNullable(nullIfNil: true)

    case .some(is NSNull):
      return .null

    case .some(let value):
      return .some(value)
    }
  }
}
