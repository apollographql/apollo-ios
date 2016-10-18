import XCTest
@testable import ApolloTests

XCTMain([
     testCase(GraphQLMapDecodingTests.allTests),
     testCase(GraphQLMapEncodingTests.allTests),
     testCase(ParseQueryResultDataTests.allTests),
     testCase(StarWarsServerTests.allTests),
])
