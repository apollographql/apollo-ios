import Foundation

extension String {
  enum ApolloStringError: Error {
    case expectedSuffixMissing(_ suffix: String)
  }
  
  func apollo_droppingSuffix(_ suffix: String) throws -> String {
    guard self.hasSuffix(suffix) else {
      throw ApolloStringError.expectedSuffixMissing(suffix)
    }
    
    return String(self.dropLast(suffix.count))
  }
}
