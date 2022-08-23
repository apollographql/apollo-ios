// @generated
// This file was automatically generated and can be edited to
// configure cache key resolution for objects in your schema.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

import ApolloAPI

public extension MyGraphQLSchema.Schema {
  static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {    
    try? CacheKeyInfo(jsonValue: object["id"])
  }
}
