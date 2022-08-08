// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Objects {
  /// An account on GitHub, with one or more owners, that has repositories, members and teams.
  static let Organization = Object(
    typename: "Organization",
    implementedInterfaces: [
      Interfaces.Actor.self,
      Interfaces.MemberStatusable.self,
      Interfaces.Node.self,
      Interfaces.PackageOwner.self,
      Interfaces.ProfileOwner.self,
      Interfaces.ProjectOwner.self,
      Interfaces.RepositoryOwner.self,
      Interfaces.Sponsorable.self,
      Interfaces.UniformResourceLocatable.self
    ]
  )
}