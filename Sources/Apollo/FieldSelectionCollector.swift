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

      case let .conditional(conditions, conditionalSelections):
        if conditions.evaluate(with: info.variables) {
          try collectFields(from: conditionalSelections,
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

/// This field collector is intended for usage when writing custom selection set data to the cache.
/// It is used by the cache writing APIs in ``ApolloStore/ReadWriteTransaction``.
///
/// This ``FieldSelectionCollector`` attempts to write all of the given object data to the cache.
/// It collects fields that are wrapped in inclusion conditions if data for the field exists,
/// ignoring the inclusion condition and variables. This ensures that object data for these fields
/// will be written to the cache.
struct CustomCacheDataWritingFieldSelectionCollector: FieldSelectionCollector {
  func collectFields(
    from selections: [Selection],
    into groupedFields: inout FieldSelectionGrouping,
    for object: JSONObject,
    info: ObjectExecutionInfo
  ) throws {
    try collectFields(
      from: selections,
      into: &groupedFields,
      for: object,
      info: info,
      asConditionalFields: false
    )
  }

  func collectFields(
    from selections: [Selection],
    into groupedFields: inout FieldSelectionGrouping,
    for object: JSONObject,
    info: ObjectExecutionInfo,
    asConditionalFields: Bool
  ) throws {
    for selection in selections {
      switch selection {
      case let .field(field):
        if asConditionalFields && !field.type.isNullable {
          guard let value = object[field.responseKey], !(value is NSNull) else {
            continue
          }
        }
        groupedFields.append(field: field, withInfo: info)

      case let .conditional(_, conditionalSelections):
        try collectFields(from: conditionalSelections,
                          into: &groupedFields,
                          for: object,
                          info: info,
                          asConditionalFields: true)

      case let .fragment(fragment):
        try collectFields(from: fragment.__selections,
                          into: &groupedFields,
                          for: object,
                          info: info,
                          asConditionalFields: asConditionalFields)

      case let .inlineFragment(typeCase):
        if let runtimeType = info.runtimeObjectType(for: object),
           typeCase.__parentType.canBeConverted(from: runtimeType) {
          try collectFields(from: typeCase.__selections,
                            into: &groupedFields,
                            for: object,
                            info: info,
                            asConditionalFields: asConditionalFields)
        }
      }
    }
  }
}
