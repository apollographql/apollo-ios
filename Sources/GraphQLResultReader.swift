public typealias GraphQLResolver = (_ field: Field, _ object: JSONObject?, _ info: GraphQLResolveInfo) -> JSONValue?

public final class GraphQLResolveInfo {
  var path: [String] = []
  let variables: GraphQLMap?
  
  init(variables: GraphQLMap?) {
    self.variables = variables
  }
}

protocol GraphQLResultReaderDelegate: class {
  func willResolve(field: Field, info: GraphQLResolveInfo)
  func didResolve(field: Field, info: GraphQLResolveInfo)
  func didParse(value: JSONValue)
  func didParseNull()
  func willParse(object: JSONObject)
  func didParse(object: JSONObject)
  func willParse<Element>(array: [Element])
  func willParseElement(at index: Int)
  func didParseElement(at index: Int)
  func didParse<Element>(array: [Element])
}

public final class GraphQLResultReader {
  let resolver: GraphQLResolver
  var delegate: GraphQLResultReaderDelegate?
  
  private var objectStack: [JSONObject] = []
  
  private var currentObject: JSONObject? {
    return objectStack.last
  }
  
  private var currentObjectType: String? {
    return currentObject?["__typename"] as? String
  }
  
  private var resolveInfo: GraphQLResolveInfo
  
  init(variables: GraphQLMap? = [:], resolver: @escaping GraphQLResolver) {
    self.resolver = resolver
    resolveInfo = GraphQLResolveInfo(variables: variables)
  }
  
  /// Init a GraphQLResultReader using a JSONObject that has come from an external source
  public convenience init(rootObject: JSONObject) {
    self.init() { field, object, info in
      return (object ?? rootObject)[field.responseName]
    }
  }
  
  // MARK: - Execution
  
  typealias Result = Any?
  typealias ResultMap = [String: [Result]]
  typealias ResultExtractor = (ResultMap) -> Result
  
  func execute(selectionSet: [Selection]) throws -> [Result] {
    var groupedFieldSet: [String: [Field]] = [:]
    let (_, resultExtractors) = collectFields(selectionSet: selectionSet, groupedFieldSet: &groupedFieldSet)
    
    var resultMap: ResultMap = [:]
    
    for (responseKey, fields) in groupedFieldSet {
      let responseValue: [Result] = try execute(fields: fields)
      resultMap[responseKey] = responseValue
    }
    
    return resultExtractors.map { $0?(resultMap) }
  }
  
  private func collectFields(selectionSet: [Selection], groupedFieldSet: inout [String: [Field]]) -> ([String: [Field]], [ResultExtractor?]) {
    var resultExtractors: [ResultExtractor?] = []
    resultExtractors.reserveCapacity(selectionSet.count)
    
    for selection in selectionSet {
      switch selection {
      case let field as Field:
        let responseKey = field.responseName
        var index: Int
        if var groupForResponseKey = groupedFieldSet[responseKey] {
          index = groupForResponseKey.count
          groupForResponseKey.append(field)
          groupedFieldSet[responseKey] = groupForResponseKey
        } else {
          index = 0
          groupedFieldSet[responseKey] = [field]
        }
        resultExtractors.append({ $0[responseKey]?[index] })
      case let fragmentSpread as FragmentSpread:
        let fragment = fragmentSpread.fragment
        
        if let currentObjectType = currentObjectType, fragment.possibleTypes.contains(currentObjectType) {
          let fragmentSelectionSet = fragment.selectionSet
          
          let (_, fragmentResultExtractors) = collectFields(selectionSet: fragmentSelectionSet, groupedFieldSet: &groupedFieldSet)
          
          resultExtractors.append({ resultMap in
            let values = fragmentResultExtractors.map { $0?(resultMap) }
            return fragment.init(values: values)
          })
        } else {
          resultExtractors.append(nil)
        }
      default:
        preconditionFailure()
      }
    }
    
    return (groupedFieldSet, resultExtractors)
  }

  private func execute(fields: [Field]) throws -> [Result] {
    let firstField = fields[0]
    
    return try resolve(field: firstField) { result in
      try completeValues(result: result, returnType: firstField.type, fields: fields)
    }
  }
  
  private func resolve<T>(field: Field, _ body: (JSONValue) throws -> T) throws -> T {
    resolveInfo.path.append(field.responseName)
    delegate?.willResolve(field: field, info: resolveInfo)
    
    do {
      guard let result = resolver(field, currentObject, resolveInfo) else {
        throw JSONDecodingError.missingValue
      }
      
      let value = try body(result)
      
      resolveInfo.path.removeLast()
      delegate?.didResolve(field: field, info: resolveInfo)
      
      return value
    } catch let error as JSONDecodingError {
      throw GraphQLResultError(path: resolveInfo.path, underlying: error)
    }
  }
  
  private func completeValues(result: JSONValue, returnType: GraphQLOutputType, fields: [Field]) throws -> [Result] {
    if case .nonNull(let innerType) = returnType {
      let completedResult = try completeValues(result: result, returnType: innerType, fields: fields)
      if completedResult[0] == nil {
        throw JSONDecodingError.nullValue
      }
      return completedResult
    }
    
    if result is NSNull {
      delegate?.didParseNull()
      return Array(repeating: nil, count: fields.count)
    }
    
    switch returnType {
    case .list(let innerType):
      guard let array = result as? [JSONValue] else { throw JSONDecodingError.wrongType }
      
      delegate?.willParse(array: array)
      
      var values: [[Any?]] = Array(repeating: [], count: fields.count)
      
      for (index, element) in array.enumerated() {
        delegate?.willParseElement(at: index)
        
        let results = try completeValues(result: element, returnType: innerType, fields: fields)
        
        for (index, result) in results.enumerated() {
          values[index].append(result)
        }
        
        delegate?.didParseElement(at: index)
      }
      
      delegate?.didParse(array: array)
      
      return values
    case .object:
      guard let object = result as? JSONObject else { throw JSONDecodingError.wrongType }
      
      objectStack.append(object)
      delegate?.willParse(object: object)
      
      defer {
        delegate?.didParse(object: object)
        objectStack.removeLast()
      }
      
      let selectionSet = mergeSelectionSets(for: fields)
      let selectionValues: [Result] = try execute(selectionSet: selectionSet)
      
      var startIndex = selectionValues.startIndex
      
      return fields.map { field in
        guard case .object(let mappable) = field.type.namedType else { preconditionFailure() }
        
        let endIndex = startIndex.advanced(by: field.selectionSet!.count)
        let values = selectionValues[startIndex..<endIndex]
        startIndex = endIndex
        
        return mappable.init(values: Array(values))
      }
    case .scalar:
      delegate?.didParse(value: result)
      
      return try fields.map { field in
        guard case .scalar(let decodable) = field.type.namedType else { preconditionFailure() }
        return try decodable.init(jsonValue: result)
      }
    default:
      preconditionFailure()
    }
  }
  
  private func mergeSelectionSets(for fields: [Field]) -> [Selection] {
    var selectionSet: [Selection] = []
    for field in fields {
      if let fieldSelectionSet = field.selectionSet {
        selectionSet.append(contentsOf: fieldSelectionSet)
      }
    }
    return selectionSet
  }
}

public struct GraphQLResultError: Error, LocalizedError {
  let path: [String]
  let underlying: Error
  
  public var pathDescription: String {
    return path.joined(separator: ".")
  }
  
  public var errorDescription: String? {
    return "Error while reading path \"\(pathDescription)\": \(underlying)"
  }
}
