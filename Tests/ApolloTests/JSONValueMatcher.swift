import Nimble
import Apollo
import ApolloAPI

public func equalJSONValue(_ expectedValue: JSONEncodable?) -> Predicate<JSONEncodable> {
  return Predicate { actual in
    let msg = ExpectationMessage.expectedActualValueTo("equal <\(stringify(expectedValue))>")
    if let actualValue = try actual.evaluate(), let expectedValue = expectedValue {
        return PredicateResult(
          bool: actualValue.jsonValue == expectedValue.jsonValue,
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

extension AnyHashable: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (AnyHashable, AnyHashable)...) {
    self.init(Dictionary(elements))
  }
}

extension AnyHashable: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: AnyHashable...) {
    self.init(elements)
  }
}
