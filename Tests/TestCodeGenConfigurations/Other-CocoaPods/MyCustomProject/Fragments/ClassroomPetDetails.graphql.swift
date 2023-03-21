// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public struct ClassroomPetDetails: MyCustomProject.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment ClassroomPetDetails on ClassroomPet {
      __typename
      ... on Animal {
        species
      }
      ... on Pet {
        humanName
      }
      ... on WarmBlooded {
        laysEggs
      }
      ... on Cat {
        bodyTemperature
        isJellicle
      }
      ... on Bird {
        wingspan
      }
      ... on PetRock {
        favoriteToy
      }
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: Apollo.ParentType { MyCustomProject.Unions.ClassroomPet }
  public static var __selections: [Apollo.Selection] { [
    .inlineFragment(AsAnimal.self),
    .inlineFragment(AsPet.self),
    .inlineFragment(AsWarmBlooded.self),
    .inlineFragment(AsCat.self),
    .inlineFragment(AsBird.self),
    .inlineFragment(AsPetRock.self),
  ] }

  public var asAnimal: AsAnimal? { _asInlineFragment() }
  public var asPet: AsPet? { _asInlineFragment() }
  public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment() }
  public var asCat: AsCat? { _asInlineFragment() }
  public var asBird: AsBird? { _asInlineFragment() }
  public var asPetRock: AsPetRock? { _asInlineFragment() }

  /// AsAnimal
  ///
  /// Parent Type: `Animal`
  public struct AsAnimal: MyCustomProject.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = ClassroomPetDetails
    public static var __parentType: Apollo.ParentType { MyCustomProject.Interfaces.Animal }
    public static var __selections: [Apollo.Selection] { [
      .field("species", String.self),
    ] }

    public var species: String { __data["species"] }
  }

  /// AsPet
  ///
  /// Parent Type: `Pet`
  public struct AsPet: MyCustomProject.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = ClassroomPetDetails
    public static var __parentType: Apollo.ParentType { MyCustomProject.Interfaces.Pet }
    public static var __selections: [Apollo.Selection] { [
      .field("humanName", String?.self),
    ] }

    public var humanName: String? { __data["humanName"] }
  }

  /// AsWarmBlooded
  ///
  /// Parent Type: `WarmBlooded`
  public struct AsWarmBlooded: MyCustomProject.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = ClassroomPetDetails
    public static var __parentType: Apollo.ParentType { MyCustomProject.Interfaces.WarmBlooded }
    public static var __selections: [Apollo.Selection] { [
      .field("laysEggs", Bool.self),
    ] }

    public var laysEggs: Bool { __data["laysEggs"] }
    public var species: String { __data["species"] }
  }

  /// AsCat
  ///
  /// Parent Type: `Cat`
  public struct AsCat: MyCustomProject.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = ClassroomPetDetails
    public static var __parentType: Apollo.ParentType { MyCustomProject.Objects.Cat }
    public static var __selections: [Apollo.Selection] { [
      .field("bodyTemperature", Int.self),
      .field("isJellicle", Bool.self),
    ] }

    public var bodyTemperature: Int { __data["bodyTemperature"] }
    public var isJellicle: Bool { __data["isJellicle"] }
    public var species: String { __data["species"] }
    public var humanName: String? { __data["humanName"] }
    public var laysEggs: Bool { __data["laysEggs"] }
  }

  /// AsBird
  ///
  /// Parent Type: `Bird`
  public struct AsBird: MyCustomProject.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = ClassroomPetDetails
    public static var __parentType: Apollo.ParentType { MyCustomProject.Objects.Bird }
    public static var __selections: [Apollo.Selection] { [
      .field("wingspan", Double.self),
    ] }

    public var wingspan: Double { __data["wingspan"] }
    public var species: String { __data["species"] }
    public var humanName: String? { __data["humanName"] }
    public var laysEggs: Bool { __data["laysEggs"] }
  }

  /// AsPetRock
  ///
  /// Parent Type: `PetRock`
  public struct AsPetRock: MyCustomProject.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = ClassroomPetDetails
    public static var __parentType: Apollo.ParentType { MyCustomProject.Objects.PetRock }
    public static var __selections: [Apollo.Selection] { [
      .field("favoriteToy", String.self),
    ] }

    public var favoriteToy: String { __data["favoriteToy"] }
    public var humanName: String? { __data["humanName"] }
  }
}
