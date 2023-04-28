import Foundation
@testable import Apollo

#warning("TODO")
let sources: [any GraphQLExecutionSource.Type] = [
  SelectionSetModelExecutionSource.self,
  CacheDataExecutionSource.self,
  NetworkResponseExecutionSource.self
]
