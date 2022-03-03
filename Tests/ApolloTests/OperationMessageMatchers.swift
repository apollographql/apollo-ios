import Foundation
import Nimble
import Apollo
@testable import ApolloWebSocket

public func equalMessage(payload: GraphQLMap? = nil, id: String? = nil, type: OperationMessage.Types) -> Predicate<String> {
  return Predicate.define { actualExpression in
    guard let actualValue = try actualExpression.evaluate() else {
      return PredicateResult(
        status: .fail,
        message: .fail("Message cannot be nil - type is a required parameter.")
      )
    }

    let expected = OperationMessage(payload: payload, id: id, type: type)
    guard actualValue == expected.rawMessage! else {
      return PredicateResult(
        status: .fail,
        message: .expectedActualValueTo("equal \(expected)"))
    }

    return PredicateResult(
      status: .matches,
      message: .expectedTo("be equal")
    )
  }
}
