public final class ApolloStore {
  private let queue: DispatchQueue
  
  private var records: RecordSet
  private var queryRoot: Record? {
    return self.records["QUERY_ROOT"]
  }
  
  init(records: RecordSet = RecordSet()) {
    queue = DispatchQueue(label: "com.apollographql.ApolloStore", qos: .default, attributes: .concurrent)
    self.records = records
  }
  
  func publish(changedRecords: RecordSet) {
    queue.async(flags: .barrier) {
      self.records.merge(recordSet: changedRecords)
    }
  }
  
  func load<Query: GraphQLQuery>(query: Query) throws -> Query.Data {
    return try queue.sync {
      let reader = GraphQLResultReader(variables: query.variables) { [unowned self] field, object, info in
        let value = (object ?? self.queryRoot?.fields)?[field.cacheKey]
        return self.complete(value: value)
      }
      
      return try Query.Data(reader: reader)
    }
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
