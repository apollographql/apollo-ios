/// A (usually code generated) type that can be initialized with an array of values that correspond to the order of the selections in a particular selection set.
public protocol GraphQLMappable {
  init(values: [Any?])
}

enum ResultMapping {
  case none
  case value(index: Int, indexInGroup: Int)
  case mappable(GraphQLMappable.Type, valueMappings: [ResultMapping])
}

final class GraphQLResultMapper<Mappable: GraphQLMappable>: GraphQLResultAccumulator {
  func accept(scalar: JSONValue, info: GraphQLResolveInfo) throws -> [Any?] {
    return try info.fields.map { field in
      guard case .scalar(let decodable) = field.type.namedType else { preconditionFailure() }
      // This will convert a JSON value to the expected value type, which could be a custom scalar or an enum.
      return try decodable.init(jsonValue: scalar)
    }
  }
  
  func acceptNullValue(info: GraphQLResolveInfo) -> [Any?] {
    return Array(repeating: nil, count: info.fields.count)
  }
  
  func accept(list: [[Any?]], info: GraphQLResolveInfo) -> [Any?] {
    return unzip(list, count: info.fields.count)
  }
  
  func accept(fieldEntry: [Any?], info: GraphQLResolveInfo) -> [Any?] {
    return fieldEntry
  }
  
  func accept(fieldEntries: [[Any?]], info: GraphQLResolveInfo) throws -> [Any?] {
    // Flatten values when we're at the root
    if info.fields.isEmpty {
      return fieldEntries.map { $0[0] }
    }
    
    return info.fields.map { field in
      guard case .object(let mappable) = field.type.namedType else { preconditionFailure() }
      
      let values = extractValues(from: fieldEntries, with: info.resultMappings)
      return mappable.init(values: values)
    }
  }
  
  private func extractValues(from fieldEntries: [[Any?]], with mappings: [ResultMapping]) -> [Any?] {
    return mappings.map { mapping in
      switch mapping {
      case .none:
        return nil
      case .value(let index, let indexInGroup):
        return fieldEntries[index][indexInGroup]
      case .mappable(let mappable, let valueMappings):
        let values = extractValues(from: fieldEntries, with: valueMappings)
        return mappable.init(values: values)
      }
    }
  }
  
  func finish(rootValue: [Any?], info: GraphQLResolveInfo) -> Mappable {
    return Mappable.init(values: rootValue)
  }
}
