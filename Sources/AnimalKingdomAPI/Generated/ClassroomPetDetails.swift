import ApolloAPI

public struct ClassroomPetDetails: AnimalKingdomAPI.SelectionSet, Fragment {
  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Union(AnimalKingdomAPI.ClassroomPet.self) }
  public static var selections: [Selection] { [
    .typeCase(AsAnimal.self),
    .typeCase(AsPet.self),
    .typeCase(AsWarmBlooded.self),
    .typeCase(AsCat.self),
    .typeCase(AsBird.self),
    .typeCase(AsPetRock.self),
  ] }


  public var asAnimal: AsAnimal? { _asType() }
  public var asPet: AsPet? { _asType() }
  public var asWarmBlooded: AsWarmBlooded? { _asType() }
  public var asCat: AsCat? { _asType() }
  public var asBird: AsBird? { _asType() }
  public var asPetRock: AsPetRock? { _asType() }

}