import Foundation

extension GraphQLType {

  var isListType: Bool {
    switch self {
    case .list: return true
    case let .nonNull(innerType): return innerType.isListType
    case .entity, .enum, .inputObject, .scalar: return false
    }
  }
  
}

extension IR.EntityField {

  /// Takes the associated ``IR.EntityField`` and formats it into a selection set name
  func formattedSelectionSetName(
    with pluralizer: Pluralizer
  ) -> String {
    IR.Entity.FieldPathComponent(name: responseKey, type: type)
      .formattedSelectionSetName(with: pluralizer)
  }

}

extension IR.Entity.FieldPathComponent {

  /// Takes the associated ``IR.Entity.FieldPathComponent`` and formats it into a selection set name
  func formattedSelectionSetName(
    with pluralizer: Pluralizer
  ) -> String {
    var fieldName = name.firstUppercased
    if type.isListType {
      fieldName = pluralizer.singularize(fieldName)
    }
    return fieldName.asSelectionSetName
  }

}
