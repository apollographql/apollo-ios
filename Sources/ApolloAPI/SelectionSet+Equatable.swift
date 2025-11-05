import Foundation

// MARK: - Equatable & Hashable
extension SelectionSet {

  /// Creates a hash using a narrowly scoped algorithm that only combines fields in the underlying data
  /// that are relevant to the `SelectionSet`. This ensures that hashes for a fragment do not
  /// consider fields that are not included in the fragment, even if they are present in the data.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.fieldsForEquality())
  }

  /// Checks for equality using a narrowly scoped algorithm that only compares fields in the underlying data
  /// that are relevant to the `SelectionSet`. This ensures that equality checks for a fragment do not
  /// consider fields that are not included in the fragment, even if they are present in the data.
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return AnySendableHashable.equatableCheck(
      lhs.fieldsForEquality(),
      rhs.fieldsForEquality()
    )
  }

  private func fieldsForEquality() -> [String: DataDict.FieldValue] {
    var fields: [String: DataDict.FieldValue] = [:]
    var addedFragments: Set<ObjectIdentifier> = []

    for fragment in type(of: self).__fulfilledFragments {
      self.addFulfilledSelections(of: fragment, to: &fields, addedFragments: &addedFragments)
    }
    return fields
  }

  private func addFulfilledSelections(
    of selectionSetType: any SelectionSet.Type,
    to fields: inout [String: DataDict.FieldValue],
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
      case .field(let field):
        add(field: field, to: &fields)

      case .inlineFragment(let typeCase):
        self.addFulfilledSelections(of: typeCase, to: &fields, addedFragments: &addedFragments)

      case .conditional(_, let selections):
        self.addConditionalSelections(selections, to: &fields, addedFragments: &addedFragments)

      case .fragment(let fragmentType):
        self.addFulfilledSelections(of: fragmentType, to: &fields, addedFragments: &addedFragments)

      case .deferred(_, let fragmentType, _):
        self.addFulfilledSelections(of: fragmentType, to: &fields, addedFragments: &addedFragments)
      }
    }

    for fragment in selectionSetType.__fulfilledFragments {
      self.addFulfilledSelections(of: fragment, to: &fields, addedFragments: &addedFragments)
    }
  }

  private func addConditionalSelections(
    _ selections: [Selection],
    to fields: inout [String: DataDict.FieldValue],
    addedFragments: inout Set<ObjectIdentifier>
  ) {
    for selection in selections {
      switch selection {
      case .inlineFragment(let typeCase):
        self.addFulfilledSelections(of: typeCase, to: &fields, addedFragments: &addedFragments)

      case .fragment(let fragment):
        self.addFulfilledSelections(of: fragment, to: &fields, addedFragments: &addedFragments)

      case .deferred(_, let fragment, _):
        self.addFulfilledSelections(of: fragment, to: &fields, addedFragments: &addedFragments)

      case .conditional(_, let selections):
        addConditionalSelections(selections, to: &fields, addedFragments: &addedFragments)

      case .field(let field):
        add(field: field, to: &fields)
      }
    }
  }

  private func add(
    field: Selection.Field,
    to fields: inout [String: DataDict.FieldValue]
  ) {
    guard !fields.keys.contains(field.responseKey) else { return }

    let nullableFieldData = self.__data._data[field.responseKey].asNullable
    let fieldData: DataDict.FieldValue
    switch nullableFieldData {
    case .some(let value):
      fieldData = value
    case .none, .null:
      return
    }
    addData(for: field.type)

    func addData(for type: Selection.Field.OutputType, inList: Bool = false) {
      switch type {
      case .scalar, .customScalar:
        fields[field.responseKey] = fieldData

      case .nonNull(let innerType):
        addData(for: innerType, inList: inList)

      case .list(let innerType):
        addData(for: innerType, inList: true)

      case .object(let selectionSetType):
        switch inList {
        case false:
          guard let objectData = fieldData as? DataDict else {
            preconditionFailure("Expected object data for object field: \(field)")
          }
          fields[field.responseKey] = selectionSetType.init(_dataDict: objectData)

        case true:
          guard let listData = fieldData as? [DataDict.FieldValue] else {
            preconditionFailure("Expected list data for field: \(field)")
          }

          fields[field.responseKey] = convertElements(of: listData, to: selectionSetType) as DataDict.FieldValue
        }
      }
    }
  }

  private func convertElements(
    of list: [DataDict.FieldValue],
    to selectionSetType: any RootSelectionSet.Type
  ) -> [DataDict.FieldValue] {
    if let dataDictList = list as? [DataDict] {
      return dataDictList.map { selectionSetType.init(_dataDict: $0) }
    }

    if let nestedList = list as? [[DataDict.FieldValue]] {
      return nestedList.map { self.convertElements(of: $0, to: selectionSetType) as DataDict.FieldValue }
    }

    preconditionFailure("Expected list data to contain objects.")
  }

}
