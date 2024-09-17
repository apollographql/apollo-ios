import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

@_spi(Execution)
public struct FieldSelectionGrouping {
  fileprivate(set) var fieldInfoList: [String: FieldExecutionInfo] = [:]
  fileprivate(set) var fulfilledFragments: Set<ObjectIdentifier> = []
  fileprivate(set) var deferredFragments: Set<ObjectIdentifier> = []
  fileprivate(set) var cachedFragmentIdentifierTypes: [ObjectIdentifier: any SelectionSet.Type] = [:]

  init(info: ObjectExecutionInfo) {
    self.fulfilledFragments = info.fulfilledFragments
    self.deferredFragments = info.deferredFragments
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
    precondition(
      !deferredFragments.contains(type: type),
      "Cannot fulfill \(type.self) fragment, it's already deferred!"
    )

    let identifier = ObjectIdentifier(type)
    fulfilledFragments.insert(identifier)
    cachedFragmentIdentifierTypes[identifier] = type
  }

  mutating func addDeferredFragment<T: SelectionSet>(_ type: T.Type) {
    precondition(
      !fulfilledFragments.contains(type: type),
      "Cannot defer \(type.self) fragment, it's already fulfilled!"
    )

    let identifier = ObjectIdentifier(type)
    deferredFragments.insert(identifier)
    cachedFragmentIdentifierTypes[identifier] = type
  }
  
}

/// A protocol for a type that defines how to collect and group the selections for an object
/// during GraphQLExecution.
///
/// A `FieldSelectionController` is responsible for determining which selections should be executed
/// and which fragments are being fulfilled during execution. It does this by adding them to the
/// provided `FieldSelectionGrouping`.
@_spi(Execution)
public protocol FieldSelectionCollector<ObjectData> {

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

@_spi(Execution)
public struct DefaultFieldSelectionCollector: FieldSelectionCollector {
  static public  func collectFields(
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

      case let .deferred(condition, typeCase, _):
        // In Apollo's implementation (Router + Server) of deferSpec=20220824 ALL defer directives
        // will be honoured and sent as separate incremental responses. This means deferred
        // selection fields only need to be collected when they are parsed with the incremental
        // data, at which time they are no longer deferred. The deferred fragment identifiers still
        // need to be collected becuase that is how the user determines the state of the deferred
        // fragment via the @Deferred property wrapper.
        //
        // If the defer condition evaluates to false though, the fragment is considered to be fulfilled
        // and and the fields must be collected.
        let isDeferred: Bool = {
          if let condition, !condition.evaluate(with: info.variables) {
            return false
          }
          return true
        }()

        if isDeferred {
          groupedFields.addDeferredFragment(typeCase)

        } else {
          groupedFields.addFulfilledFragment(typeCase)
          try collectFields(from: typeCase.__selections, into: &groupedFields, for: object, info: info)
        }

      case let .fragment(fragment):
        groupedFields.addFulfilledFragment(fragment)
        try collectFields(from: fragment.__selections,
                          into: &groupedFields,
                          for: object,
                          info: info)

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

      case let .deferred(_, deferredFragment, _):
        if groupedFields.fulfilledFragments.contains(type: deferredFragment) {
          try collectFields(
            from: deferredFragment.__selections,
            into: &groupedFields, 
            for: object,
            info: info,
            asConditionalFields: false
          )
        }

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
