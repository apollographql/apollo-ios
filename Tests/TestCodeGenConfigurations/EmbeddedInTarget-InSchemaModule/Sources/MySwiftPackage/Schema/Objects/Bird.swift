// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension MyGraphQLSchema {
  final class Bird: Object {
    override public class var __typename: StaticString { "Bird" }

    override public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
    private static let _implementedInterfaces: [Interface.Type]? = [
      Animal.self,
      Pet.self,
      WarmBlooded.self
    ]
  }

}