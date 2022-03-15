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
