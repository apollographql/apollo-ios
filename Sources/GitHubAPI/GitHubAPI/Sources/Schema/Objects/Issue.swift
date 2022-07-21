// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// An Issue is a place to discuss ideas, enhancements, tasks, and bugs for a project.
public final class Issue: Object {
  override public class var __typename: StaticString { "Issue" }

  override public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    Assignable.self,
    Closable.self,
    Comment.self,
    Labelable.self,
    Lockable.self,
    Node.self,
    Reactable.self,
    RepositoryNode.self,
    Subscribable.self,
    UniformResourceLocatable.self,
    Updatable.self,
    UpdatableComment.self
  ]
}
