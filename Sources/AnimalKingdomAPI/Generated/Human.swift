public final class Human: Object {
  override public class var __typename: String { "Human" }

  override public class var __metadata: Metadata { _metadata }
  private static let _metadata: Metadata = Metadata(implements: [
    Animal.self,
    WarmBlooded.self
  ])
}