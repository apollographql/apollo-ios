<<<<<<< HEAD
import ApolloAPI

=======
>>>>>>> ab7ba884 (Generation of Operation Definition 7 Clean up Swift Scripts)
public final class Bird: Object {
  override public class var __typename: String { "Bird" }

  override public class var __metadata: Metadata { _metadata }
  private static let _metadata: Metadata = Metadata(implements: [
    Animal.self,
    Pet.self,
    WarmBlooded.self
  ])
}