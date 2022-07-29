// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// A review object for a given pull request.
public final class PullRequestReview: Object {
  override public class var __typename: StaticString { "PullRequestReview" }

  public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    Comment.self,
    Deletable.self,
    Node.self,
    Reactable.self,
    RepositoryNode.self,
    Updatable.self,
    UpdatableComment.self
  ]
}
