import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

struct FieldSelectionGrouping: Sequence {
  private var fieldInfoList: [String: FieldExecutionInfo] = [:]
  fileprivate(set) var fulfilledFragments: Set<ObjectIdentifier> = []

  init(info: ObjectExecutionInfo) {
    self.fulfilledFragments = info.fulfilledFragments
  }

  var count: Int { fieldInfoList.count }

  mutating func append(field: Selection.Field, withInfo info: ObjectExecutionInfo) {
    let fieldKey = field.responseKey
    if let fieldInfo = fieldInfoList[fieldKey] {
      fieldInfo.mergedFields.append(field)
      fieldInfoList[fieldKey] = fieldInfo
    } else {
      fieldInfoList[fieldKey] = FieldExecutionInfo(field: field, parentInfo: info)
    }
  }

  mutating func addFulfilledFragment<T: SelectionSet>(_ type: T.Type) {
    fulfilledFragments.insert(ObjectIdentifier(type))
  }

  func makeIterator() -> Dictionary<String, FieldExecutionInfo>.Iterator {
    fieldInfoList.makeIterator()
  }
}

/// A protocol for a type that defines how to collect and group the selections for an object
/// during GraphQLExecution.
///
/// A `FieldSelectionController` is responsible for determining which selections should be executed
/// and which fragments are being fulfilled during execution. It does this by adding them to the
/// provided `FieldSelectionGrouping`.
protocol FieldSelectionCollector<ObjectData> {

  associatedtype ObjectData

  /// Groups fields that share the same response key for simultaneous resolution.
  ///
  /// Before execution, the selection set is converted to a grouped field set.
  /// Each entry in the grouped field set is a list of fields that share a response key.
  /// This ensures all fields with the same response key (alias or field name) included via
  /// referenced fragments are executed at the same time.
  static func collectFields(
    from selections: [Selection],
    into groupedFields: inout FieldSelectionGrouping,
    for object: ObjectData,
    info: ObjectExecutionInfo
  ) throws

}

struct DefaultFieldSelectionCollector: FieldSelectionCollector {
  static func collectFields(
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

      case .deferred(_, _, _):
        assertionFailure("Defer execution must be implemented (#3145).")
      case let .fragment(fragment):
        groupedFields.addFulfilledFragment(fragment)
        try collectFields(from: fragment.__selections,
                          into: &groupedFields,
                          for: object,
                          info: info)

      // TODO: _ is fine for now but will need to be handled in #3145
      case let .inlineFragment(typeCase):
        if let runtimeType = info.runtimeObjectType(for: object),
           typeCase.__parentType.canBeConverted(from: runtimeType) {
          groupedFields.addFulfilledFragment(typeCase)
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
  static func collectFields(
    from selections: [Selection],
    into groupedFields: inout FieldSelectionGrouping,
    for object: DataDict,
    info: ObjectExecutionInfo
  ) throws {
    groupedFields.fulfilledFragments = object._fulfilledFragments
    try collectFields(
      from: selections,
      into: &groupedFields,
      for: object,
      info: info,
      asConditionalFields: false
    )
  }

  static func collectFields(
    from selections: [Selection],
    into groupedFields: inout FieldSelectionGrouping,
    for object: DataDict,
    info: ObjectExecutionInfo,
    asConditionalFields: Bool
  ) throws {
    for selection in selections {
      switch selection {
      case let .field(field):
        if asConditionalFields && !field.type.isNullable {
          guard let value = object._data[field.responseKey], !(value is NSNull) else {
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
      case .deferred(_, _, _):
        assertionFailure("Defer execution must be implemented (#3145).")
      case let .fragment(fragment):
        if groupedFields.fulfilledFragments.contains(type: fragment) {
          try collectFields(from: fragment.__selections,
                            into: &groupedFields,
                            for: object,
                            info: info,
                            asConditionalFields: false)
        }

      case let .inlineFragment(typeCase):
        if groupedFields.fulfilledFragments.contains(type: typeCase) {
          try collectFields(from: typeCase.__selections,
                            into: &groupedFields,
                            for: object,
                            info: info,
                            asConditionalFields: false)
        }
      }
    }
  }
}

fileprivate extension Set<ObjectIdentifier> {
  func contains(type: Any.Type) -> Bool {
    contains(ObjectIdentifier(type.self))
  }
}
