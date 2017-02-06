func rootKey<Operation: GraphQLOperation>(forOperation operation: Operation) -> CacheKey {
  switch operation {
  case is GraphQLQuery:
    return "QUERY_ROOT"
  case is GraphQLMutation:
    return "MUTATION_ROOT"
  default:
    preconditionFailure("Unknown operation type")
  }
}

protocol ApolloStoreSubscriber: class {
  func store(_ store: ApolloStore, didChangeKeys changedKeys: Set<CacheKey>, context: UnsafeMutableRawPointer?)
}

/// The `ApolloStore` class acts as a local cache for normalized GraphQL results.
public final class ApolloStore {  
  private let queue: DispatchQueue
  private var records: RecordSet
  private var subscribers: [ApolloStoreSubscriber] = []
  
  init(records: RecordSet = RecordSet()) {
    self.records = records
    queue = DispatchQueue(label: "com.apollographql.ApolloStore", attributes: .concurrent)
  }
  
  func publish(records: RecordSet, context: UnsafeMutableRawPointer?) {
    queue.async(flags: .barrier) {
      let changedKeys = self.records.merge(records: records)
      
      for subscriber in self.subscribers {
        subscriber.store(self, didChangeKeys: changedKeys, context: context)
      }
    }
  }
  
  func subscribe(_ subscriber: ApolloStoreSubscriber) {
    queue.async(flags: .barrier) {
      self.subscribers.append(subscriber)
    }
  }
  
  func unsubscribe(_ subscriber: ApolloStoreSubscriber) {
    queue.async(flags: .barrier) {
      self.subscribers = self.subscribers.filter({ $0 !== subscriber })
    }
  }
  
  func load<Query: GraphQLQuery>(query: Query, cacheKeyForObject: CacheKeyForObject?, resultHandler: @escaping OperationResultHandler<Query>) {
    queue.async {
      do {
        let rootKey = Apollo.rootKey(forOperation: query)
        let rootObject = self.records[rootKey]?.fields
        
        let reader = GraphQLResultReader(variables: query.variables) { field, object, info in
          let value = (object ?? rootObject)?[field.cacheKey]
          return self.complete(value: value)
        }
        
        let normalizer = GraphQLResultNormalizer(rootKey: rootKey)
        normalizer.cacheKeyForObject = cacheKeyForObject
        
        reader.delegate = normalizer
        
        let data = try Query.Data(reader: reader)
        
        let dependentKeys = normalizer.dependentKeys
        
        resultHandler(GraphQLResult(data: data, errors: nil, dependentKeys: dependentKeys), nil)
      } catch {
        resultHandler(nil, error)
      }
    }
  }
  
  private func complete(value: JSONValue?) -> JSONValue? {
    if let reference = value as? Reference {
      return self.records[reference.key]?.fields
    } else if let array = value as? Array<JSONValue> {
      return array.map(complete)
    } else {
      return value
    }
  }
}
