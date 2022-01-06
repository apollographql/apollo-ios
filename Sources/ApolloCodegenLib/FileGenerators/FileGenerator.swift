import Foundation
import ApolloUtils

/// The methods to conform to when building a code generation Swift file generator.
protocol FileGenerator {
  associatedtype graphQLType

  var objectType: GraphQLObjectType { get }
  var filePath: String { get }

  func generateFile() throws
}
