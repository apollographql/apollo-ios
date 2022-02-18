// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class IncrementingSubscription: GraphQLSubscription {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    subscription Incrementing {
      numberIncremented
    }
    """

  public let operationName: String = "Incrementing"

  public let operationIdentifier: String? = "fe12b5f0dfc7fefa513cc8aecef043b45daf2d776fd000d3a7703f9798ecf233"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Subscription"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("numberIncremented", type: .scalar(Int.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(numberIncremented: Int? = nil) {
      self.init(unsafeResultMap: ["__typename": "Subscription", "numberIncremented": numberIncremented])
    }

    public var numberIncremented: Int? {
      get {
        return resultMap["numberIncremented"] as? Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "numberIncremented")
      }
    }
  }
}
