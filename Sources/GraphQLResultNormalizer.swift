final class GraphQLResultNormalizer: GraphQLResultReaderDelegate {
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
    path.append(field.cacheKey)
  }
  
  func didResolve(field: Field, info: GraphQLResolveInfo) {
    path.removeLast()
    
    let value = valueStack.removeLast()
    
    let dependentKey = [currentRecord.key, field.cacheKey].joined(separator: ".")
    dependentKeys.insert(dependentKey)
    
    currentRecord[field.cacheKey] = value
    
    if recordStack.isEmpty {
      records.merge(record: currentRecord)
    }
  }
  
  func didParse(value: JSONValue) {
    valueStack.append(value)
  }
  
  func didParseNull() {
    valueStack.append(NSNull())
  }
  
  func willParse(object: JSONObject) {
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
  
  func didParse(object: JSONObject) {
    path = pathStack.removeLast()
    
    valueStack.append(Reference(key: currentRecord.key))
    dependentKeys.insert(currentRecord.key)
    records.merge(record: currentRecord)
    
    currentRecord = recordStack.removeLast()
  }
  
  func willParse<Element>(array: [Element]) {
    valueStack.reserveCapacity(valueStack.count + array.count)
  }
  
  func willParseElement(at index: Int) {
    path.append(String(index))
  }
  
  func didParseElement(at index: Int) {
    path.removeLast()
  }
  
  func didParse<Element>(array: [Element]) {
    let parsedArray = Array(valueStack.suffix(array.count))
    valueStack.removeLast(array.count)
    valueStack.append(parsedArray)
  }
}
