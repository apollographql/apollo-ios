// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// A review comment associated with a given repository pull request.
public final class PullRequestReviewComment: Object {
  override public class var __typename: StaticString { "PullRequestReviewComment" }

  override public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    Comment.self,
    Deletable.self,
    Minimizable.self,
    Node.self,
    Reactable.self,
    RepositoryNode.self,
    Updatable.self,
    UpdatableComment.self
  ]
}
