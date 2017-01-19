public typealias CacheKeyForObject = (JSONObject) -> JSONValue?

final class GraphQLResultNormalizer: GraphQLResultReaderDelegate {
  var records: RecordSet
  var cacheKeyForObject: CacheKeyForObject?
  
  private var recordStack: [Record] = []
  private var currentRecord: Record?
  
  typealias Path = [String]
  private var pathStack: [Path] = []
  private var path: Path = []
  
  private var valueStack: [JSONValue?] = []
  
  init(records: RecordSet = RecordSet()) {
    self.records = records
  }
  
  func willResolve(field: Field, info: GraphQLResolveInfo) {
    path.append(field.cacheKey)
  }
  
  func didResolve(field: Field, info: GraphQLResolveInfo) {
    path.removeLast()
    
    let value = valueStack.removeLast()
    
    if currentRecord != nil {
      currentRecord![field.cacheKey] = value
    } else {
      records["QUERY_ROOT", field.cacheKey] = value
    }
  }
  
  func didParse(value: JSONValue) {
    valueStack.append(value)
  }
  
  func didParseNull() {
    valueStack.append(nil)
  }
  
  func willParse(object: JSONObject) {
    if let parentRecord = currentRecord {
      recordStack.append(parentRecord)
    }
    
    pathStack.append(path)
    
    let cacheKey: Key
    if let value = cacheKeyForObject?(object) {
      cacheKey = String(describing: value)
      path = [cacheKey]
    } else {
      cacheKey = path.joined(separator: ".")
    }
    
    currentRecord = Record(key: cacheKey)
  }
  
  func didParse(object: JSONObject) {
    guard let record = currentRecord else { preconditionFailure() }
    
    records.merge(record: record)
    
    valueStack.append(Reference(key: record.key))
    
    path = pathStack.removeLast()
    currentRecord = recordStack.popLast()
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
