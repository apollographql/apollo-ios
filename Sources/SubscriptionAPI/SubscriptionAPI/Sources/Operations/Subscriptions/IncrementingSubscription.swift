// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class IncrementingSubscription: GraphQLSubscription {
  public static let operationName: String = "Incrementing"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      subscription Incrementing {
        numberIncremented
      }
      """
    ))

  public init() {}

  public struct Data: SubscriptionAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(SubscriptionAPI.Subscription) }
    public static var selections: [Selection] { [
      .field("numberIncremented", Int?.self),
    ] }

    public var numberIncremented: Int? { __data["numberIncremented"] }
  }
}
