@testable import ApolloCodegenLib

public class MockFragmentDefinition: CompilationResult.FragmentDefinition {
  public static func mockDefinition(name: String) -> String {
    return """
    fragment \(name) on Person {
      name
    }
    """
  }

  public static func mock(_ name: String = "NameFragment") -> Self {
    let mock = Self.mock()
    mock.source = Self.mockDefinition(name: name)
    return mock
  }
}
