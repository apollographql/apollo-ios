@testable import ApolloCodegenLib

public class MockOperationDefinition: CompilationResult.OperationDefinition {

  public static func mock(usingFragments: [MockFragmentDefinition]) -> Self {
    let mock = Self.mock()
#warning("TODO: Implement - How does code gen engine compute the used fragments?")
    return mock
  }

}
