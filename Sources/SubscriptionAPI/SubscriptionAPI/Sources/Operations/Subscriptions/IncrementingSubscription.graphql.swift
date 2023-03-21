// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class IncrementingSubscription: GraphQLSubscription {
  public static let operationName: String = "Incrementing"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      subscription Incrementing {
        numberIncremented
      }
      """#
    ))

  public init() {}

  public struct Data: SubscriptionAPI.SelectionSet {
    public let __data: DataDict
    public init(_data: DataDict) { __data = _data }

    public static var __parentType: ApolloAPI.ParentType { SubscriptionAPI.Objects.Subscription }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("numberIncremented", Int?.self),
    ] }

    public var numberIncremented: Int? { __data["numberIncremented"] }
  }
}
