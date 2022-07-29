// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// An account on GitHub, with one or more owners, that has repositories, members and teams.
public final class Organization: Object {
  override public class var __typename: StaticString { "Organization" }

  public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    Actor.self,
    MemberStatusable.self,
    Node.self,
    PackageOwner.self,
    ProfileOwner.self,
    ProjectOwner.self,
    RepositoryOwner.self,
    Sponsorable.self,
    UniformResourceLocatable.self
  ]
}
