public struct ClassroomPetDetails: API.SelectionSet, Fragment {
  public let data: ResponseDict
  public init(data: ResponseDict) { self.data = data }

  public static var __parentType: ParentType { .Union(API.ClassroomPet.self) }
  public static var selections: [Selection] { [
    .typeCase(AsAnimal.self),
    .typeCase(AsPet.self),
    .typeCase(AsWarmBlooded.self),
    .typeCase(AsCat.self),
    .typeCase(AsBird.self),
    .typeCase(AsPetRock.self),
  ] }


}