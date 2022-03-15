import Foundation
import OrderedCollections

extension IR {

  class Field: Equatable, CustomDebugStringConvertible {
    let underlyingField: CompilationResult.Field
    var inclusionConditions: AnyOf<InclusionConditions>?

    var name: String { underlyingField.name }
    var alias: String? { underlyingField.alias }
    var responseKey: String { underlyingField.responseKey }
    var type: GraphQLType { underlyingField.type }
    var arguments: [CompilationResult.Argument]? { underlyingField.arguments }

    fileprivate init(
      _ field: CompilationResult.Field,
      inclusionConditions: AnyOf<InclusionConditions>? = nil
    ) {
      self.underlyingField = field
      self.inclusionConditions = inclusionConditions
    }

    static func ==(lhs: Field, rhs: Field) -> Bool {
      lhs.underlyingField == rhs.underlyingField
    }

    var debugDescription: String {
      underlyingField.debugDescription
    }
  }

  final class ScalarField: Field {
    override init(
      _ field: CompilationResult.Field,
      inclusionConditions: AnyOf<InclusionConditions>? = nil
    ) {
      super.init(field, inclusionConditions: inclusionConditions)
    }
  }

  final class EntityField: Field {
    let selectionSet: SelectionSet
    var entity: Entity { selectionSet.typeInfo.entity }

    init(
      _ field: CompilationResult.Field,
      inclusionConditions: AnyOf<InclusionConditions>? = nil,
      selectionSet: SelectionSet
    ) {
      self.selectionSet = selectionSet
      super.init(field, inclusionConditions: inclusionConditions)
    }

    static func ==(lhs: EntityField, rhs: EntityField) -> Bool {
      lhs.underlyingField == rhs.underlyingField &&
      lhs.selectionSet == rhs.selectionSet
    }
  }

}
