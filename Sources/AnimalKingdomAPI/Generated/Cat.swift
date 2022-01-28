public final class Cat: Object {
  override public class var __typename: String { "Cat" }

  override public class var __metadata: Metadata { _metadata }
  private static let _metadata: Metadata = Metadata(implements: [
    Animal.self,
    Pet.self,
    WarmBlooded.self
  ])
}