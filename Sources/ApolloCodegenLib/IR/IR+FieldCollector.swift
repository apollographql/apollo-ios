import OrderedCollections

extension IR {
  class FieldCollector {

    var collectedFields: [GraphQLCompositeType: OrderedDictionary<String, GraphQLField>] = [:]

    func add<T: Sequence>(
      fields: T,
      to type: GraphQLCompositeType
    ) where T.Element == GraphQLField {
      
    }
  }

}
