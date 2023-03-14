import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

struct FieldSelectionGrouping: Sequence {
  private var fieldInfoList: [String: FieldExecutionInfo] = [:]

  var count: Int { fieldInfoList.count }

  mutating func append(field: Selection.Field, withInfo info: ObjectExecutionInfo) {
    let fieldKey = field.responseKey
    if var fieldInfo = fieldInfoList[fieldKey] {
      fieldInfo.mergedFields.append(field)
      fieldInfoList[fieldKey] = fieldInfo
    } else {
      fieldInfoList[fieldKey] = FieldExecutionInfo(field: field, parentInfo: info)
    }
  }

  func makeIterator() -> Dictionary<String, FieldExecutionInfo>.Iterator {
    fieldInfoList.makeIterator()
  }
}

protocol FieldSelectionCollector {

  func collectFields(
    from selections: [Selection],
    into groupedFields: inout FieldSelectionGrouping,
    for object: JSONObject,
    info: ObjectExecutionInfo
  ) throws

}

struct DefaultFieldSelectionCollector: FieldSelectionCollector {
  func collectFields(
    from selections: [Selection],
    into groupedFields: inout FieldSelectionGrouping,
    for object: JSONObject,
    info: ObjectExecutionInfo
  ) throws {
    for selection in selections {
      switch selection {
      case let .field(field):
        groupedFields.append(field: field, withInfo: info)

      case let .conditional(conditions, selections):
        if conditions.evaluate(with: info.variables) {
          try collectFields(from: selections,
                            into: &groupedFields,
                            for: object,
                            info: info)
        }

      case let .fragment(fragment):
        try collectFields(from: fragment.__selections,
                          into: &groupedFields,
                          for: object,
                          info: info)

      case let .inlineFragment(typeCase):
        if let runtimeType = info.runtimeObjectType(for: object),
           typeCase.__parentType.canBeConverted(from: runtimeType) {
          try collectFields(from: typeCase.__selections,
                            into: &groupedFields,
                            for: object,
                            info: info)
        }
      }
    }
  }
}
