import Foundation

private typealias GroupedFields = GroupedSequence<String, GraphQLField>

func decode<SelectionSet: GraphQLSelectionSet>(selectionSet: SelectionSet.Type,
                                               from object: JSONObject,
                                               variables: GraphQLMap? = nil) throws -> SelectionSet {
  var groupedFields = GroupedFields()
  try collectFields(from: selectionSet.selections,
                    into: &groupedFields,
                    variables: variables)
  let resultMap = try decode(groupedFields: groupedFields,
                             from: object,
                             path: [],
                             variables: variables)

  return SelectionSet.init(unsafeResultMap: resultMap)
}

private func decode(groupedFields: GroupedFields,
                    from object: JSONObject,
                    path: ResponsePath,
                    variables: GraphQLMap?) throws -> ResultMap {
  var fieldEntries: [(String, Any?)] = []
  fieldEntries.reserveCapacity(groupedFields.keys.count)

  for (responseName, fields) in groupedFields {
    let fieldEntry = try decode(fields: fields,
                                from: object,
                                path: path + responseName,
                                variables: variables)
    fieldEntries.append((responseName, fieldEntry))
  }

  return ResultMap(fieldEntries)
}

/// Before execution, the selection set is converted to a grouped field set. Each entry in the grouped field set is a list of fields that share a response key. This ensures all fields with the same response key (alias or field name) included via referenced fragments are executed at the same time.
private func collectFields(from selections: [GraphQLSelection],
                           forRuntimeType runtimeType: String? = nil,
                           into groupedFields: inout GroupedFields,
                           variables: GraphQLMap?) throws {
  for selection in selections {
    switch selection {
    case let field as GraphQLField:
      _ = groupedFields.append(value: field, forKey: field.responseKey)
    case let booleanCondition as GraphQLBooleanCondition:
      guard let value = variables?[booleanCondition.variableName] else {
        throw GraphQLError("Variable \(booleanCondition.variableName) was not provided.")
      }
      if value as? Bool == !booleanCondition.inverted {
        try collectFields(from: booleanCondition.selections,
                          forRuntimeType: runtimeType,
                          into: &groupedFields,
                          variables: variables)
      }
    case let fragmentSpread as GraphQLFragmentSpread:
      let fragment = fragmentSpread.fragment

      if let runtimeType = runtimeType, fragment.possibleTypes.contains(runtimeType) {
        try collectFields(from: fragment.selections,
                          forRuntimeType: runtimeType,
                          into: &groupedFields,
                          variables: variables)
      }
    case let typeCase as GraphQLTypeCase:
      let selections: [GraphQLSelection]
      if let runtimeType = runtimeType {
        selections = typeCase.variants[runtimeType] ?? typeCase.default
      } else {
        selections = typeCase.default
      }
      try collectFields(from: selections,
                        forRuntimeType: runtimeType,
                        into: &groupedFields,
                        variables: variables)
    default:
      preconditionFailure()
    }
  }
}

/// Each field requested in the grouped field set that is defined on the selected objectType will result in an entry in the response map. Field execution first coerces any provided argument values, then resolves a value for the field, and finally completes that value either by recursively executing another selection set or coercing a scalar value.
private func decode(fields: [GraphQLField],
                    from object: JSONObject,
                    path: ResponsePath,
                    variables: GraphQLMap?) throws -> Any? {
  // GraphQL validation makes sure all fields sharing the same response key have the same arguments and are of the same type, so we only need to resolve one field.
  let firstField = fields[0]

  do {
    guard let value = object[firstField.responseKey] else {
      throw JSONDecodingError.missingValue
    }

    return try complete(value: value,
                        ofType: firstField.type,
                        fields: fields,
                        path: path,
                        variables: variables)
  } catch {
    if !(error is GraphQLResultError) {
      throw GraphQLResultError(path: path, underlying: error)
    } else {
      throw error
    }
  }
}

/// After resolving the value for a field, it is completed by ensuring it adheres to the expected return type. If the return type is another Object type, then the field execution process continues recursively.
private func complete(value: JSONValue,
                      ofType returnType: GraphQLOutputType,
                      fields: [GraphQLField],
                      path: ResponsePath,
                      variables: GraphQLMap?) throws -> Any? {
  if case .nonNull(let innerType) = returnType {
    if value is NSNull {
      throw JSONDecodingError.nullValue
    }

    return try complete(value: value,
                        ofType: innerType,
                        fields: fields,
                        path: path,
                        variables: variables)
  }

  if value is NSNull {
    return nil
  }

  switch returnType {
  case .scalar(let decodable):
    return try decodable.init(jsonValue: value)
  case .list(let innerType):
    guard let array = value as? [JSONValue] else { throw JSONDecodingError.wrongType }

    return try array.enumerated().map { index, element -> Any? in
      var path = path
      path.append(String(index))
      return try complete(value: element,
                          ofType: innerType,
                          fields: fields,
                          path: path,
                          variables: variables)
    }
  case .object:
    guard let object = value as? JSONObject else { throw JSONDecodingError.wrongType }
    guard let runtimeType = object["__typename"] as? String else {
      throw GraphQLResultError(path: path + "__typename", underlying: JSONDecodingError.missingValue)
    }
    // The merged selection set is a list of fields from all sub‐selection sets of the original fields.
    let subFields = try collectSubfields(from: fields,
                                         forRuntimeType: runtimeType,
                                         variables: variables)
    // We execute the merged selection set on the object to complete the value. This is the recursive step in the GraphQL execution model.
    return try decode(groupedFields: subFields,
                      from: object,
                      path: path,
                      variables: variables)
  default:
    preconditionFailure()
  }
}

private func collectSubfields(from fields: [GraphQLField],
                              forRuntimeType runtimeType: String,
                              variables: GraphQLMap?) throws -> GroupedFields {
  var groupedFields = GroupedFields()
  for field in fields {
    if case let .object(subSelections) = field.type.namedType {
      try collectFields(from: subSelections,
                        forRuntimeType: runtimeType,
                        into: &groupedFields,
                        variables: variables)
    }
  }
  return groupedFields
}
