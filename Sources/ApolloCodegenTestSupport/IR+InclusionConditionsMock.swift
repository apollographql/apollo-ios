@testable import ApolloCodegenLib
import OrderedCollections

extension IR.InclusionConditions {

  public static func mock(
    _ conditions: OrderedSet<IR.InclusionCondition>
  ) -> IR.InclusionConditions? {
    let result = IR.InclusionConditions.allOf(conditions)
    return result.conditions
  }

}

extension IR.InclusionCondition: ExpressibleByStringLiteral {

  public init(stringLiteral: String) {
    self.init(stringLiteral, isInverted: false)
  }

  public static prefix func !(value: IR.InclusionCondition) -> IR.InclusionCondition {
    value.inverted()
  }

  public static func &&(_ lhs: Self, rhs: Self) -> IR.InclusionConditions.Result {
    IR.InclusionConditions.allOf([lhs, rhs])
  }

}
