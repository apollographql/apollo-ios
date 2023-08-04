import Foundation
import OrderedCollections

extension IR {

  class DirectSelections: Equatable, CustomDebugStringConvertible {

    fileprivate(set) var fields: OrderedDictionary<String, Field> = [:]
    fileprivate(set) var inlineFragments: OrderedDictionary<ScopeCondition, InlineFragmentSpread> = [:]
    fileprivate(set) var namedFragments: OrderedDictionary<String, NamedFragmentSpread> = [:]

    init() {}

    init(
      fields: [Field] = [],
      inlineFragments: [InlineFragmentSpread] = [],
      namedFragments: [NamedFragmentSpread] = []
    ) {
      mergeIn(fields)
      mergeIn(inlineFragments)
      mergeIn(namedFragments)
    }

    init(
      fields: OrderedDictionary<String, Field> = [:],
      inlineFragments: OrderedDictionary<ScopeCondition, InlineFragmentSpread> = [:],
      namedFragments: OrderedDictionary<String, NamedFragmentSpread> = [:]
    ) {
      mergeIn(fields.values)
      mergeIn(inlineFragments.values)
      mergeIn(namedFragments.values)
    }

    func mergeIn(_ selections: DirectSelections) {
      mergeIn(selections.fields.values)
      mergeIn(selections.inlineFragments.values)
      mergeIn(selections.namedFragments.values)
    }

    func mergeIn(_ field: Field) {
      let keyInScope = field.hashForSelectionSetScope

      if let existingField = fields[keyInScope] {

        if let existingField = existingField as? EntityField, let field = field as? EntityField {
          fields[keyInScope] = merge(field, with: existingField)

        } else {
          existingField.inclusionConditions =
          (existingField.inclusionConditions || field.inclusionConditions)

        }
      } else {
        fields[keyInScope] = field
      }
    }

    private func merge(_ newField: EntityField, with existingField: EntityField) -> EntityField {
      var mergedField = existingField

      if existingField.inclusionConditions == newField.inclusionConditions {
        mergedField.selectionSet.selections.direct!
          .mergeIn(newField.selectionSet.selections.direct!)

      } else if existingField.inclusionConditions != nil {
        mergedField = createInclusionWrapperField(wrapping: existingField, mergingIn: newField)

      } else {
        merge(field: newField, intoInclusionWrapperField: existingField)
      }

      return mergedField
    }

    private func createInclusionWrapperField(
      wrapping existingField: EntityField,
      mergingIn newField: EntityField
    ) -> EntityField {
      let wrapperScope = existingField.selectionSet.scopePath.mutatingLast { _ in
        ScopeDescriptor.descriptor(
          forType: existingField.selectionSet.parentType,
          inclusionConditions: nil,
          givenAllTypesInSchema: existingField.selectionSet.scope.allTypesInSchema
        )
      }

      let wrapperField = EntityField(
        existingField.underlyingField,
        inclusionConditions: (existingField.inclusionConditions || newField.inclusionConditions),
        selectionSet: SelectionSet(
          entity: existingField.entity,
          scopePath: wrapperScope
        )
      )

      merge(field: existingField, intoInclusionWrapperField: wrapperField)
      merge(field: newField, intoInclusionWrapperField: wrapperField)

      return wrapperField
    }

    private func merge(field newField: EntityField, intoInclusionWrapperField wrapperField: EntityField) {
      if let newFieldConditions = newField.selectionSet.inclusionConditions {
        let newFieldSelectionSet = SelectionSet(
          entity: newField.entity,
          scopePath: wrapperField.selectionSet.scopePath.mutatingLast {
            $0.appending(newFieldConditions)
          },
          selections: newField.selectionSet.selections.direct.unsafelyUnwrapped
        )
        let newFieldInlineFragment = InlineFragmentSpread(
          selectionSet: newFieldSelectionSet,
          isDeferred: false
        )
        wrapperField.selectionSet.selections.direct?.mergeIn(newFieldInlineFragment)

      } else {
        wrapperField.selectionSet.selections.direct?.mergeIn(newField.selectionSet.selections.direct.unsafelyUnwrapped)
      }
    }

    func mergeIn(_ fragment: InlineFragmentSpread) {
      let scopeCondition = fragment.selectionSet.scope.scopePath.last.value

      if let existingTypeCase = inlineFragments[scopeCondition]?.selectionSet {
        existingTypeCase.selections.direct!
          .mergeIn(fragment.selectionSet.selections.direct!)

      } else {
        inlineFragments[scopeCondition] = fragment
      }
    }

    func mergeIn(_ fragment: NamedFragmentSpread) {
      if let existingFragment = namedFragments[fragment.hashForSelectionSetScope] {
        existingFragment.inclusionConditions =
        (existingFragment.inclusionConditions || fragment.inclusionConditions)
        return
      }

      namedFragments[fragment.hashForSelectionSetScope] = fragment
    }

    func mergeIn<T: Sequence>(_ fields: T) where T.Element == Field {
      fields.forEach { mergeIn($0) }
    }

    func mergeIn<T: Sequence>(_ inlineFragments: T) where T.Element == InlineFragmentSpread {
      inlineFragments.forEach { mergeIn($0) }
    }

    func mergeIn<T: Sequence>(_ fragments: T) where T.Element == NamedFragmentSpread {
      fragments.forEach { mergeIn($0) }
    }

    var isEmpty: Bool {
      fields.isEmpty && inlineFragments.isEmpty && namedFragments.isEmpty
    }

    static func == (lhs: DirectSelections, rhs: DirectSelections) -> Bool {
      lhs.fields == rhs.fields &&
      lhs.inlineFragments == rhs.inlineFragments &&
      lhs.namedFragments == rhs.namedFragments
    }

    var debugDescription: String {
      """
      Fields: \(fields.values.elements)
      InlineFragments: \(inlineFragments.values.elements.map(\.debugDescription))
      Fragments: \(namedFragments.values.elements.map(\.debugDescription))
      """
    }

    var readOnlyView: ReadOnly {
      ReadOnly(value: self)
    }

    struct ReadOnly: Equatable {
      fileprivate let value: DirectSelections

      var fields: OrderedDictionary<String, Field> { value.fields }
      var inlineFragments: OrderedDictionary<ScopeCondition, InlineFragmentSpread> { value.inlineFragments }
      var namedFragments: OrderedDictionary<String, NamedFragmentSpread> { value.namedFragments }
      var isEmpty: Bool { value.isEmpty }
    }

    var groupedByInclusionCondition: GroupedByInclusionCondition {
      GroupedByInclusionCondition(self)
    }

    class GroupedByInclusionCondition: Equatable {

      private(set) var unconditionalSelections:
      DirectSelections.ReadOnly = .init(value: DirectSelections())

      private(set) var inclusionConditionGroups:
      OrderedDictionary<AnyOf<IR.InclusionConditions>, DirectSelections.ReadOnly> = [:]

      init(_ directSelections: DirectSelections) {
        for selection in directSelections.fields {
          if let condition = selection.value.inclusionConditions {
            inclusionConditionGroups.updateValue(
              forKey: condition,
              default: .init(value: DirectSelections())) { selections in
                selections.value.fields[selection.key] = selection.value
              }

          } else {
            unconditionalSelections.value.fields[selection.key] = selection.value
          }
        }

        for selection in directSelections.inlineFragments {
          if let condition = selection.value.inclusionConditions {
            inclusionConditionGroups.updateValue(
              forKey: AnyOf(condition),
              default: .init(value: DirectSelections())) { selections in
                selections.value.inlineFragments[selection.key] = selection.value
              }

          } else {
            unconditionalSelections.value.inlineFragments[selection.key] = selection.value
          }
        }

        for selection in directSelections.namedFragments {
          if let condition = selection.value.inclusionConditions {
            inclusionConditionGroups.updateValue(
              forKey: condition,
              default: .init(value: DirectSelections())) { selections in
                selections.value.namedFragments[selection.key] = selection.value
              }

          } else {
            unconditionalSelections.value.namedFragments[selection.key] = selection.value
          }
        }
      }

      static func == (
        lhs: IR.DirectSelections.GroupedByInclusionCondition,
        rhs: IR.DirectSelections.GroupedByInclusionCondition
      ) -> Bool {
        lhs.unconditionalSelections == rhs.unconditionalSelections &&
        lhs.inclusionConditionGroups == rhs.inclusionConditionGroups
      }
    }

  }

  class MergedSelections: Equatable, CustomDebugStringConvertible {

    struct MergedSource: Hashable {
      let typeInfo: SelectionSet.TypeInfo

      /// The `NamedFragment` that the merged selections were contained in.
      ///
      /// - Note: If `fragment` is present, the `typeInfo` is relative to the fragment,
      /// instead of the operation directly.
      unowned let fragment: NamedFragment?
    }

    typealias MergedSources = OrderedSet<MergedSource>

    private let directSelections: DirectSelections.ReadOnly?
    let typeInfo: SelectionSet.TypeInfo
    
    fileprivate(set) var mergedSources: MergedSources = []
    fileprivate(set) var fields: OrderedDictionary<String, Field> = [:]
    fileprivate(set) var inlineFragments: OrderedDictionary<ScopeCondition, InlineFragmentSpread> = [:]
    fileprivate(set) var namedFragments: OrderedDictionary<String, NamedFragmentSpread> = [:]

    init(
      directSelections: DirectSelections.ReadOnly?,
      typeInfo: SelectionSet.TypeInfo
    ) {
      self.directSelections = directSelections
      self.typeInfo = typeInfo
    }

    func mergeIn(_ selections: EntityTreeScopeSelections, from source: MergedSource) {
      @IsEverTrue var didMergeAnySelections: Bool

      selections.fields.values.forEach { didMergeAnySelections = self.mergeIn($0) }
      selections.namedFragments.values.forEach { didMergeAnySelections = self.mergeIn($0) }

      if didMergeAnySelections {
        mergedSources.append(source)
      }
    }

    private func mergeIn(_ field: IR.Field) -> Bool {
      let keyInScope = field.hashForSelectionSetScope
      if let directSelections = directSelections,
          directSelections.fields.keys.contains(keyInScope) {
        return false
      }

      let fieldToMerge: IR.Field
      if let entityField = field as? IR.EntityField {
        fieldToMerge = createShallowlyMergedNestedEntityField(from: entityField)

      } else {
        fieldToMerge = field
      }

      fields[keyInScope] = fieldToMerge
      return true
    }

    private func createShallowlyMergedNestedEntityField(from field: IR.EntityField) -> IR.EntityField {
      let newSelectionSet = IR.SelectionSet(
        entity: field.entity,
        scopePath: self.typeInfo.scopePath.appending(field.selectionSet.typeInfo.scope),
        mergedSelectionsOnly: true
      )      
      return IR.EntityField(
        field.underlyingField,        
        inclusionConditions: field.inclusionConditions,
        selectionSet: newSelectionSet
      )
    }

    private func mergeIn(_ fragment: IR.NamedFragmentSpread) -> Bool {
      let keyInScope = fragment.hashForSelectionSetScope
      if let directSelections = directSelections,
          directSelections.namedFragments.keys.contains(keyInScope) {
        return false
      }

      namedFragments[keyInScope] = fragment

      return true
    }

    func addMergedInlineFragment(with condition: ScopeCondition) {
      guard typeInfo.isEntityRoot else { return }

      createShallowlyMergedInlineFragmentIfNeeded(with: condition)
    }

    private func createShallowlyMergedInlineFragmentIfNeeded(
      with condition: ScopeCondition
    ) {
      if let directSelections = directSelections,
         directSelections.inlineFragments.keys.contains(condition) {
        return
      }

      guard !inlineFragments.keys.contains(condition) else { return }

      let inlineFragment = IR.InlineFragmentSpread(
        selectionSet: .init(
          entity: self.typeInfo.entity,
          scopePath: self.typeInfo.scopePath.mutatingLast { $0.appending(condition) },
          mergedSelectionsOnly: true
        ),
        isDeferred: condition.isDeferred
      )
      inlineFragments[condition] = inlineFragment
    }

    var isEmpty: Bool {
      fields.isEmpty && inlineFragments.isEmpty && namedFragments.isEmpty
    }

    static func == (lhs: MergedSelections, rhs: MergedSelections) -> Bool {
      lhs.mergedSources == rhs.mergedSources &&
      lhs.fields == rhs.fields &&
      lhs.inlineFragments == rhs.inlineFragments &&
      lhs.namedFragments == rhs.namedFragments
    }

    var debugDescription: String {
      """
      Merged Sources: \(mergedSources)
      Fields: \(fields.values.elements)
      InlineFragments: \(inlineFragments.values.elements.map(\.debugDescription))
      NamedFragments: \(namedFragments.values.elements.map(\.debugDescription))
      """
    }

  }

}

extension IR.MergedSelections.MergedSource: CustomDebugStringConvertible {
  var debugDescription: String {
    typeInfo.debugDescription + ", fragment: \(fragment?.debugDescription ?? "nil")"
  }
}
