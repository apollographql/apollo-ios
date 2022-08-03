// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Objects {
  /// A user is an individual's account on GitHub that owns repositories and can make new content.
  static let User = Object(
    typename: "User",
    implementedInterfaces: [
      Interfaces.Actor.self,
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