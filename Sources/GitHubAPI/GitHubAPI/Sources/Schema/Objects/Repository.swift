// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// A repository contains the content for a project.
public final class Repository: Object {
  override public class var __typename: StaticString { "Repository" }

  override public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    Node.self,
    PackageOwner.self,
    ProjectOwner.self,
    RepositoryInfo.self,
    Starrable.self,
    Subscribable.self,
    UniformResourceLocatable.self
  ]
}
