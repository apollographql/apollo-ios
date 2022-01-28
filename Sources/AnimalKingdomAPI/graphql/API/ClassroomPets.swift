public struct Data: API.SelectionSet {
  public let data: ResponseDict
  public init(data: ResponseDict) { self.data = data }

  public static var __parentType: ParentType { .Object(API.Query.self) }
  public static var selections: [Selection] { [
    .field("classroomPets", [ClassroomPet].self),
  ] }

  public var classroomPets: [ClassroomPet] { data["classroomPets"] }

  public struct ClassroomPet: API.SelectionSet {
    public let data: ResponseDict
    public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Union(API.ClassroomPet.self) }
    public static var selections: [Selection] { [
      .fragment(ClassroomPetDetails.self),
    ] }

  }
}
