// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// A user is an individual's account on GitHub that owns repositories and can make new content.
public final class User: Object {
  override public class var __typename: StaticString { "User" }

  override public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    Actor.self,
    Node.self,
    PackageOwner.self,
    ProfileOwner.self,
    ProjectOwner.self,
    RepositoryOwner.self,
    Sponsorable.self,
    UniformResourceLocatable.self
  ]
}
