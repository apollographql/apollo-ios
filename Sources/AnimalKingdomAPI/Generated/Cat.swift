<<<<<<< HEAD
<<<<<<< HEAD
import ApolloAPI

=======
>>>>>>> ab7ba884 (Generation of Operation Definition 7 Clean up Swift Scripts)
=======
import ApolloAPI

>>>>>>> e84b84b7 (Added import ApolloAPI to templates)
public final class Cat: Object {
  override public class var __typename: String { "Cat" }

  override public class var __metadata: Metadata { _metadata }
  private static let _metadata: Metadata = Metadata(implements: [
    Animal.self,
    Pet.self,
    WarmBlooded.self
  ])
}