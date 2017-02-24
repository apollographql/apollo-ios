final class GraphQLResultNormalizer: GraphQLExecutorDelegate {
  var records: RecordSet
  var dependentKeys: Set<CacheKey> = Set()
  
  var cacheKeyForObject: CacheKeyForObject?
  
  private var recordStack: [Record]
  private var currentRecord: Record
  
  typealias Path = [String]
  private var pathStack: [Path] = []
  private var path: Path = []
  
  private var valueStack: [JSONValue] = []
  
  init(rootKey: CacheKey) {
    records = RecordSet()
    
    recordStack = []
    currentRecord = Record(key: rootKey)
  }
  
  func willResolve(field: Field, info: GraphQLResolveInfo) {
    path.append(try! field.cacheKey(with: info.variables))
  }
  
  func didResolve(field: Field, info: GraphQLResolveInfo) {
    let cacheKey = try! field.cacheKey(with: info.variables)
    
    path.removeLast()
    
    let value = valueStack.removeLast()
    
    let dependentKey = [currentRecord.key, cacheKey].joined(separator: ".")
    dependentKeys.insert(dependentKey)
    
    currentRecord[cacheKey] = value
    
    if recordStack.isEmpty {
      records.merge(record: currentRecord)
    }
  }
  
  func didComplete(scalar: JSONValue) {
    valueStack.append(scalar)
  }
  
  func didCompleteValueWithNull() {
    valueStack.append(NSNull())
  }
  
  func willComplete(object: JSONObject) {
    pathStack.append(path)
    
    let cacheKey: CacheKey
    if let value = cacheKeyForObject?(object) {
      cacheKey = String(describing: value)
      path = [cacheKey]
    } else {
      cacheKey = path.joined(separator: ".")
    }
    
    recordStack.append(currentRecord)
    currentRecord = Record(key: cacheKey)
  }
  
  func didComplete(object: JSONObject) {
    path = pathStack.removeLast()
    
    valueStack.append(Reference(key: currentRecord.key))
    dependentKeys.insert(currentRecord.key)
    records.merge(record: currentRecord)
    
    currentRecord = recordStack.removeLast()
  }
  
  func willComplete<Element>(array: [Element]) {
    valueStack.reserveCapacity(valueStack.count + array.count)
  }
  
  func willCompleteElement(at index: Int) {
    path.append(String(index))
  }
  
  func didCompleteElement(at index: Int) {
    path.removeLast()
  }
  
  func didComplete<Element>(array: [Element]) {
    let CompletedArray = Array(valueStack.suffix(array.count))
    valueStack.removeLast(array.count)
    valueStack.append(CompletedArray)
  }
}
