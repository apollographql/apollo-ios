// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Represents a comment on an Gist.
public final class GistComment: Object {
  override public class var __typename: StaticString { "GistComment" }

  public class var __implementedInterfaces: [Interface.Type]? { _implementedInterfaces }
  private static let _implementedInterfaces: [Interface.Type]? = [
    Comment.self,
    Deletable.self,
    Minimizable.self,
    Node.self,
    Updatable.self,
    UpdatableComment.self
  ]
}
