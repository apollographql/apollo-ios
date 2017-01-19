public final class ApolloStore {
  private var records: RecordSet
  
  private var queryRoot: Record {
    return self.records["QUERY_ROOT"]!
  }
  
  init(records: RecordSet = RecordSet()) {
    self.records = records
  }
  
  func publish(changedRecords: RecordSet) {
    records.merge(recordSet: changedRecords)
  }
  
  func lookup(key: Key) -> Record? {
    return records[key]
  }
  
  public func load<Query: GraphQLQuery>(query: Query) throws -> Query.Data {
    let reader = GraphQLResultReader(variables: query.variables) { [unowned self] field, object, info in
      let value = (object ?? self.queryRoot.fields)[field.cacheKey]
      return self.complete(value: value)
    }
    
    return try Query.Data(reader: reader)
  }
  
  private func complete(value: JSONValue?) -> JSONValue? {
    if let reference = value as? Reference {
      return self.records[reference.key]?.fields
    } else if let array = value as? Array<Any> {
      return array.map(complete)
    } else {
      return value
    }
  }
}
