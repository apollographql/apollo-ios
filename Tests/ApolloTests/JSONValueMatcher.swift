import Nimble
import Apollo
import ApolloAPI

public func equalJSONValue(_ expectedValue: Any?) -> Predicate<Any> {
  return Predicate { actual in
    let msg = ExpectationMessage.expectedActualValueTo("equal <\(stringify(expectedValue))>")
    if let actualValue = try actual.evaluate(), let expectedValue = expectedValue {
        return PredicateResult(
          bool: JSONValueMatcher.equals(actualValue, expectedValue),
          message: msg
        )
    } else {
      return PredicateResult(
        status: .fail,
        message: msg.appendedBeNilHint()
      )
    }
  }
}

public func equalJSONValue(_ expectedValue: JSONEncodable?) -> Predicate<JSONEncodable> {
  return Predicate { actual in
    let msg = ExpectationMessage.expectedActualValueTo("equal <\(stringify(expectedValue))>")
    if let actualValue = try actual.evaluate(), let expectedValue = expectedValue {
        return PredicateResult(
          bool: JSONValueMatcher.equals(actualValue.jsonValue, expectedValue.jsonValue),
          message: msg
        )
    } else {
      return PredicateResult(
        status: .fail,
        message: msg.appendedBeNilHint()
      )
    }
  }
}

public func equal(_ expectedValue: GraphQLMap?) -> Predicate<GraphQLMap> {
  return Predicate { actual in
    let msg = ExpectationMessage.expectedActualValueTo("equal <\(stringify(expectedValue))>")
    if let actualValue = try actual.evaluate(), let expectedValue = expectedValue {
        return PredicateResult(
          bool: JSONValueMatcher.equals(actualValue.jsonValue, expectedValue.jsonValue),
          message: msg
        )
    } else {
      return PredicateResult(
        status: .fail,
        message: msg.appendedBeNilHint()
      )
    }
  }
}
