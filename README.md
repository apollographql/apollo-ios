# Apollo iOS client

This is an early prototype of Apollo client for iOS, written in Swift.

Currently, the focus of this prototype is to validate some ideas about the mapping of GraphQL query results to typed structures. It contains tests for a variety of GraphQL queries, and handwritten query classes with nested types that define the mapping. These query classes will eventually be code generated from a GraphQL schema and query documents.

The project is being developed using the most recent versions of Xcode 8 beta and Swift 3. Some of the tests run against [an example GraphQL server](`https://github.com/jahewson/graphql-starwars`) using the Star Wars data bundled with Facebook's reference implementation, [GraphQL.js](https://github.com/graphql/graphql-js).
