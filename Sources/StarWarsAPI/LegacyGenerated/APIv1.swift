// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import ApolloAPI
import Foundation

public protocol SelectionSet: ApolloAPI.SelectionSet & RootSelectionSet
where Schema == StarWarsAPISchema {}

public protocol TypeCase: ApolloAPI.TypeCase
where Schema == StarWarsAPISchema {}

public enum StarWarsAPISchema: SchemaConfiguration {
  public static func objectType(forTypename __typename: String) -> Object.Type? {
    switch __typename {
    case "Droid": return Droid.self
    case "Human": return Human.self
    case "FriendsConnection": return FriendsConnection.self
    case "Height": return Height.self
    case "Human": return Human.self
    case "PetRock": return PetRock.self
    case "Query": return Query.self
    case "Rat": return Rat.self
    default: return nil
    }
  }
}

// MARK: - Schema Objects

public final class Query: Object {
  override public class var __typename: String { "Query" }
}

public final class Character: Interface {
  @Field("id") var id: GraphQLID?
  @Field("name") var name: String?
}

public final class Human: Object {
  override public class var __typename: String { "Human" }

  override public class var __metadata: Metadata { _metadata }
  private static let _metadata: Metadata = Metadata(
    implements: [Character.self]
  )
}

public final class Droid: Object {
  override public class var __typename: String { "Droid" }

  override public class var __metadata: Metadata { _metadata }
  private static let _metadata: Metadata = Metadata(
    implements: [Character.self]
  )
}

public final class FriendsConnection: Object {
  override public class var __typename: String { "FriendsConnection" }
}

public final class FriendsEdge: Object {
  override public class var __typename: String { "FriendsEdge" }
}

public final class PageInfo: Object {
  override public class var __typename: String { "PageInfo" }
}

public final class Review: Object {
  override public class var __typename: String { "Review" }
}

public final class Starship: Object {
  override public class var __typename: String { "Starship" }
}

public enum SearchResult: UnionType, Equatable {
  case Human(Human)
  case Droid(Droid)
  case Starship(Starship)

  public init?(_ object: Object) {
    switch object {
    case let ent as Human: self = .Human(ent)
    case let ent as Droid: self = .Droid(ent)
    case let ent as Starship: self = .Starship(ent)
    default: return nil
    }
  }

  public var object: Object {
    switch self {
    case let .Human(object as Object),
         let .Droid(object as Object),
         let .Starship(object as Object):
      return object
    }
  }

  static public let possibleTypes: [Object.Type] =
    [StarWarsAPI.Human.self, StarWarsAPI.Droid.self, StarWarsAPI.Starship.self]
}

/// The episodes in the Star Wars trilogy
public enum Episode: String, EnumType {
  /// Star Wars Episode IV: A New Hope, released in 1977.
  case NEWHOPE
  /// Star Wars Episode V: The Empire Strikes Back, released in 1980.
  case EMPIRE
  /// Star Wars Episode VI: Return of the Jedi, released in 1983.
  case JEDI
}

/// Units of height
public enum LengthUnit: String, EnumType {
  /// The standard unit around the world
  case METER
  /// Primarily used in the United States
  case FOOT
}

/// The input object sent when someone is creating a new review
public struct ReviewInput: InputObject {
  public private(set) var dict: InputDict

  /// - Parameters:
  ///   - stars: 0-5 stars
  ///   - commentary: Comment about the movie, optional
  ///   - favoriteColor: Favorite color, optional
  public init(stars: Int, commentary: GraphQLNullable<String> = .none, favoriteColor: GraphQLNullable<ColorInput> = .none) {
    dict = InputDict(["stars": stars, "commentary": commentary, "favorite_color": favoriteColor])
  }

  /// 0-5 stars
  public var stars: Int {
    get { dict["stars"] }
    set { dict["stars"] = newValue }
  }

  /// Comment about the movie, optional
  public var commentary: GraphQLNullable<String> {
    get { dict["commentary"] }
    set { dict["commentary"] = newValue }
  }
  /// Favorite color, optional
  public var favoriteColor: GraphQLNullable<ColorInput> {
    get { dict["favoriteColor"] }
    set { dict["favoriteColor"] = newValue }
  }
}

/// The input object sent when passing in a color
public struct ColorInput: InputObject {
  public private(set) var dict: InputDict

  /// - Parameters:
  ///   - red
  ///   - green
  ///   - blue
  public init(red: Int, green: Int, blue: Int) {
    dict = InputDict(["red": red, "green": green, "blue": blue])
  }

  public var red: Int {
    get { dict["red"] }
    set { dict["red"] = newValue }
  }

  public var green: Int {
    get { dict["green"] }
    set { dict["green"] = newValue }
  }

  public var blue: Int {
    get { dict["blue"] }
    set { dict["blue"] = newValue }
  }
}

/// ```
/// mutation CreateReviewForEpisode($episode: Episode!, $review: ReviewInput!) {
///   createReview(episode: $episode, review: $review) {
///     __typename
///     stars
///     commentary
///   }
/// }
/// ```
public final class CreateReviewForEpisodeMutation: GraphQLMutation {

  public let operationName: String = "CreateReviewForEpisode"

  public let operationIdentifier: String? = "9bbf5b4074d0635fb19d17c621b7b04ebfb1920d468a94266819e149841e7d5d"

  public var episode: Episode
  public var review: ReviewInput

  public init(episode: Episode, review: ReviewInput) {
    self.episode = episode
    self.review = review
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode, "review": review].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(Mutation.self) }
    public static var selections: [Selection] { [
        .field("createReview", arguments: ["episode": .variable("episode"), "review": .variable("review")], .object(CreateReview.selections)),
      ]
    }

    public init(createReview: CreateReview? = nil) {
      self.init(json: ["__typename": "Mutation", "createReview": createReview.flatMap { (value: CreateReview) -> ResultMap in value.resultMap }])
    }

    public var createReview: CreateReview? { data["createReview"] }

    public struct CreateReview: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

      public static var __parentType: ParentType { .Object(Review.self) }
      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("stars", Int.self),
          .field("commentary", String?.self),
        ]
      }

      public init(stars: Int, commentary: String? = nil) {
        self.init(json: ["__typename": "Review", "stars": stars, "commentary": commentary])
      }

      public var __typename: String { data["__typename"] }

      /// The number of stars this review gave, 1-5
      public var stars: Int { data["stars"] }

      /// Comment about the movie
      public var commentary: String? { data["commentary"] }        
    }
  }
}

/// ```
/// mutation CreateAwesomeReview {
///   createReview(episode: JEDI, review: {stars: 10, commentary: "This is awesome!"}) {
///     __typename
///     stars
///     commentary
///   }
/// }
/// ```
public final class CreateAwesomeReviewMutation: GraphQLMutation {

  public let operationName: String = "CreateAwesomeReview"

  public let operationIdentifier: String? = "4a1250de93ebcb5cad5870acf15001112bf27bb963e8709555b5ff67a1405374"

  public init() {
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static var __parentType: ParentType { .Object(Mutation.self) }

    public static var selections: [Selection] { [
        .field("createReview", CreateReview?.self, arguments: ["episode": "JEDI", "review": ["stars": 10, "commentary": "This is awesome!"]]),
      ]
    }

    public init(createReview: CreateReview? = nil) {
      self.init(json: ["__typename": "Mutation", "createReview": createReview.flatMap { (value: CreateReview) -> ResultMap in value.resultMap }])
    }

    public var createReview: CreateReview? { data["createReview"] }

    public struct CreateReview: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static var __parentType: ParentType { .Object(Review.self) }

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("stars", Int.self),
          .field("commentary", String?.self),
        ]
      }

      public init(stars: Int, commentary: String? = nil) {
        self.init(json: ["__typename": "Review", "stars": stars, "commentary": commentary])
      }

      public var __typename: String { data["__typename"] }

      /// The number of stars this review gave, 1-5
      public var stars: Int { data["stars"] }

      /// Comment about the movie
      public var commentary: String? { data["commentary"] }        
    }
  }
}

/// ```
/// mutation CreateReviewWithNullField {
///   createReview(episode: JEDI, review: {stars: 10, commentary: null}) {
///     __typename
///     stars
///     commentary
///   }
/// }
/// ```
public final class CreateReviewWithNullFieldMutation: GraphQLMutation {

  public let operationName: String = "CreateReviewWithNullField"

  public let operationIdentifier: String? = "a9600d176cd7e4671b8689f1d01fe79ea896932bfafb8a925af673f0e4111828"

  public init() {
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static var __parentType: ParentType { .Object(Mutation.self) }

    public static var selections: [Selection] { [
        .field("createReview", CreateReview?.self, arguments: ["episode": "JEDI", "review": ["stars": 10, "commentary": nil]]),
      ]
    }

    public init(createReview: CreateReview? = nil) {
      self.init(json: ["__typename": "Mutation", "createReview": createReview.flatMap { (value: CreateReview) -> ResultMap in value.resultMap }])
    }

    public var createReview: CreateReview? { data["createReview"] }

    public struct CreateReview: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static var __parentType: ParentType { .Object(Review.self) }

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("stars", Int.self),
          .field("commentary", String?.self),
        ]
      }

      public init(stars: Int, commentary: String? = nil) {
        self.init(json: ["__typename": "Review", "stars": stars, "commentary": commentary])
      }

      public var __typename: String { data["__typename"] }

      /// The number of stars this review gave, 1-5
      public var stars: Int { data["stars"] }

      /// Comment about the movie
      public var commentary: String? { data["commentary"] } 
    }
  }
}

/// ```
/// query HeroAndFriendsNames($episode: Episode) {
///   hero(episode: $episode) {
///     __typename
///     name
///     friends {
///       __typename
///       name
///     }
///   }
/// }
/// ```
public final class HeroAndFriendsNamesQuery: GraphQLQuery {

  public let operationName: String = "HeroAndFriendsNames"

  public let operationIdentifier: String? = "fe3f21394eb861aa515c4d582e645469045793c9cbbeca4b5d4ce4d7dd617556"

  public var episode: Episode? // TODO: Use dynamicMemberLookup subscripts for these?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct ResponseData: SelectionSet {
    let data: ResponseDict

    public static var selections: [Selection] { [
        .field("hero", arguments: ["episode": .variable("episode")], .object(Hero.self)),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
          .field("friends", [Friend?]?.self),
        ]
      }

      public static func makeHuman(name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String { data["name"] }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? { data["friend"] }

      public struct Friend: SelectionSet {
        public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        public static let possibleTypes: [String] = ["Human", "Droid"]

        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
          ]
        }

        public static func makeHuman(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
        }

        public static func makeDroid(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
        }

        public var __typename: String { data["__typename"] }

        /// The name of the character
        public var name: String { data["name"] }
      }
    }
  }
}

public final class HeroAndFriendsNamesWithIDsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroAndFriendsNamesWithIDs($episode: Episode) {
      hero(episode: $episode) {
        __typename
        id
        name
        friends {
          __typename
          id
          name
        }
      }
    }
    """

  public let operationName: String = "HeroAndFriendsNamesWithIDs"

  public let operationIdentifier: String? = "8e4ca76c63660898cfd5a3845e3709027750b5f0151c7f9be65759b869c5486d"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(Query.self) }
    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("id", ID.self),
          .field("name", String.self),
          .field("friends", [Friend?]?.self),
        ]
      }

      public static func makeHuman(id: GraphQLID, name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "id": id, "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(id: GraphQLID, name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "id": id, "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String { data["__typename"] }

      /// The ID of the character
      public var id: GraphQLID { data["id"] }

      /// The name of the character
      public var name: String { data["name"] }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? { data["friends"] }

      public struct Friend: SelectionSet {
        public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        public static let possibleTypes: [String] = ["Human", "Droid"]

        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("id", ID.self),
            .field("name", String.self),
          ]
        }

        public static func makeHuman(id: GraphQLID, name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "id": id, "name": name])
        }

        public static func makeDroid(id: GraphQLID, name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "id": id, "name": name])
        }

        public var __typename: String { data["__typename"] }

        /// The ID of the character
        public var id: GraphQLID { data["id"] }

        /// The name of the character
        public var name: String { data["name"] }
      }
    }
  }
}

public final class HeroAndFriendsIDsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroAndFriendsIDs($episode: Episode) {
      hero(episode: $episode) {
        __typename
        id
        name
        friends {
          __typename
          id
        }
      }
    }
    """

  public let operationName: String = "HeroAndFriendsIDs"

  public let operationIdentifier: String? = "117d0f6831d8f4abe5b61ed1dbb8071b0825e19649916c0fe0906a6f578bb088"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static var __parentType: ParentType { .Object(Query.self) }

    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("id", ID.self),
          .field("name", String.self),
          .field("friends", [Friend?]?),
        ]
      }

      public static func makeHuman(id: GraphQLID, name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "id": id, "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(id: GraphQLID, name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "id": id, "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String { data["__typename"] }

      /// The ID of the character
      public var id: GraphQLID { data["id"] }

      /// The name of the character
      public var name: String { data["name"] }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? { data["friends"] }

      public struct Friend: SelectionSet {
        public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        public static let possibleTypes: [String] = ["Human", "Droid"]

        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("id", ID.self),
          ]
        }

        public static func makeHuman(id: GraphQLID) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "id": id])
        }

        public static func makeDroid(id: GraphQLID) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "id": id])
        }

        public var __typename: String { data["__typename"] }

        /// The ID of the character
        public var id: GraphQLID { data["id"] }
      }
    }
  }
}

public final class HeroAndFriendsNamesWithIdForParentOnlyQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroAndFriendsNamesWithIDForParentOnly($episode: Episode) {
      hero(episode: $episode) {
        __typename
        id
        name
        friends {
          __typename
          name
        }
      }
    }
    """

  public let operationName: String = "HeroAndFriendsNamesWithIDForParentOnly"

  public let operationIdentifier: String? = "f091468a629f3b757c03a1b7710c6ede8b5c8f10df7ba3238f2bbcd71c56f90f"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(Query.self) }
    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

      public static let possibleTypes: [String] = ["Human", "Droid"]
      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("id", ID.self),
          .field("name", String.self),
          .field("friends", [Friend?]?.self),
        ]
      }

      public static func makeHuman(id: GraphQLID, name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "id": id, "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(id: GraphQLID, name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "id": id, "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String { data["__typename"] }

      /// The ID of the character
      public var id: GraphQLID { data["id"] }

      /// The name of the character
      public var name: String { data["name"] }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? { data["friends"] }

      public struct Friend: SelectionSet {
        public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

        public static let possibleTypes: [String] = ["Human", "Droid"]
        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
          ]
        }

        public static func makeHuman(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
        }

        public static func makeDroid(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
        }

        public var __typename: String { data["__typename"] }

        /// The name of the character
        public var name: String { data["name"] }

      }
    }
  }
}

public final class HeroAndFriendsNamesWithFragmentQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroAndFriendsNamesWithFragment($episode: Episode) {
      hero(episode: $episode) {
        __typename
        name
        ...FriendsNames
      }
    }
    """

  public let operationName: String = "HeroAndFriendsNamesWithFragment"

  public let operationIdentifier: String? = "1d3ad903dad146ff9d7aa09813fc01becd017489bfc1af8ffd178498730a5a26"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + FriendsNames.fragmentDefinition)
    return document
  }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static var __parentType: ParentType { .Object(Query.self) }

    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

      public static let possibleTypes: [String] = ["Human", "Droid"]
      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
          .field("__typename", String.self),
          .field("friends", [Friend?]?.self),
        ]
      }

      public static func makeHuman(name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String { data["name"] }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? { data["friends"] }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public var friendsNames: FriendsNames {
          get {
            return FriendsNames(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct Friend: SelectionSet {
        public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

        public static let possibleTypes: [String] = ["Human", "Droid"]
        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
          ]
        }

        public static func makeHuman(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
        }

        public static func makeDroid(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
        }

        public var __typename: String { data["__typename"] }

        /// The name of the character
        public var name: String { data["name"] }
      }
    }
  }
}

public final class HeroAndFriendsNamesWithFragmentTwiceQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroAndFriendsNamesWithFragmentTwice($episode: Episode) {
      hero(episode: $episode) {
        __typename
        friends {
          __typename
          ...CharacterName
        }
        ... on Droid {
          friends {
            __typename
            ...CharacterName
          }
        }
      }
    }
    """

  public let operationName: String = "HeroAndFriendsNamesWithFragmentTwice"

  public let operationIdentifier: String? = "e02ef22e116ad1ca35f0298ed3badb60eeb986203f0088575a5f137768c322fc"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + CharacterName.fragmentDefinition)
    return document
  }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(Query.self) }
    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

      public static let possibleTypes: [String] = ["Human", "Droid"]
      public static var selections: [Selection] { [
          GraphQLTypeCase(
            variants: ["Droid": AsDroid.selections,
                       Pet.self: AsPet.selections,
                       "Dog": AsPet.selections],
            default: [
              .field("__typename", String.self),
              .field("friends", [Friend?]?.self),
            ]
          )
        ]
      }

      public static func makeHuman(friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(friends: [AsDroid.Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "friends": friends.flatMap { (value: [AsDroid.Friend?]) -> [ResultMap?] in value.map { (value: AsDroid.Friend?) -> ResultMap? in value.flatMap { (value: AsDroid.Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String { data["__typename"] }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? { data["friends"] }

      public struct Friend: SelectionSet {
        public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        
        public static let possibleTypes: [String] = ["Human", "Droid"]
        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("__typename", String.self),
            .field("name", String.self),
          ]
        }

        public static func makeHuman(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
        }

        public static func makeDroid(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
        }

        public var __typename: String { data["__typename"] }

        /// The name of the character
        public var name: String { data["name"] }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public var characterName: CharacterName {
            get {
              return CharacterName(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public var asDroid: AsDroid? {
        get {
          if !AsDroid.possibleTypes.contains(__typename) { return nil }
          return AsDroid(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsDroid: SelectionSet {
        public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

        public static var __parentType: ParentType { .Object(Droid.self) }
        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("friends", [Friend?]?.self),            
          ]
        }

        public init(friends: [Friend?]? = nil) {
          self.init(json: ["__typename": "Droid", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String { data["__typename"] }

        /// This droid's friends, or an empty list if they have none
        public var friends: [Friend?]? { data["friends"] }

        public struct Friend: SelectionSet {
          public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

          public static let possibleTypes: [String] = ["Human", "Droid"]
          public static var selections: [Selection] { [
              .field("__typename", String.self),
              .field("__typename", String.self),
              .field("name", String.self),
              .field("__typename", String.self),
            ]
          }

          public static func makeHuman(name: String) -> Friend {
            return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
          }

          public static func makeDroid(name: String) -> Friend {
            return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
          }

          public var __typename: String { data["__typename"] }

          /// The name of the character
          public var name: String { data["name"] }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public var characterName: CharacterName {
              get {
                return CharacterName(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }
      }
    }
  }
}

public final class HeroAppearsInQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroAppearsIn {
      hero {
        __typename
        appearsIn
      }
    }
    """

  public let operationName: String = "HeroAppearsIn"

  public let operationIdentifier: String? = "22d772c0fc813281705e8f0a55fc70e71eeff6e98f3f9ef96cf67fb896914522"

  public init() {
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    
    public static var __parentType: ParentType { .Object(Query.self) }
    public static var selections: [Selection] { [
        .field("hero", Hero?.self),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

      public static let possibleTypes: [String] = ["Human", "Droid"]
      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("appearsIn", .nonNull(.list(.scalar(Episode.self)))),
        ]
      }

      public static func makeHuman(appearsIn: [Episode?]) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "appearsIn": appearsIn])
      }

      public static func makeDroid(appearsIn: [Episode?]) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "appearsIn": appearsIn])
      }

      public var __typename: String { data["__typename"] }

      /// The movies this character appears in
      public var appearsIn: [Episode?] { data["appearsIn"] }
    }
  }
}

public final class HeroAppearsInWithFragmentQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroAppearsInWithFragment($episode: Episode) {
      hero(episode: $episode) {
        __typename
        ...CharacterAppearsIn
      }
    }
    """

  public let operationName: String = "HeroAppearsInWithFragment"

  public let operationIdentifier: String? = "1756158bd7736d58db45a48d74a724fa1b6fdac735376df8afac8318ba5431fb"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + CharacterAppearsIn.fragmentDefinition)
    return document
  }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    
    public static var __parentType: ParentType { .Object(Query.self) }
    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

      public static let possibleTypes: [String] = ["Human", "Droid"]
      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("__typename", String.self),
          .field("appearsIn", [Episode?].self),
        ]
      }

      public static func makeHuman(appearsIn: [Episode?]) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "appearsIn": appearsIn])
      }

      public static func makeDroid(appearsIn: [Episode?]) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "appearsIn": appearsIn])
      }

      public var __typename: String { data["__typename"] }

      /// The movies this character appears in
      public var appearsIn: [Episode?] { data["appearsIn"] }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public var characterAppearsIn: CharacterAppearsIn {
          get {
            return CharacterAppearsIn(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public final class HeroNameConditionalExclusionQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroNameConditionalExclusion($skipName: Boolean!) {
      hero {
        __typename
        name @skip(if: $skipName)
      }
    }
    """

  public let operationName: String = "HeroNameConditionalExclusion"

  public let operationIdentifier: String? = "3dd42259adf2d0598e89e0279bee2c128a7913f02b1da6aa43f3b5def6a8a1f8"

  public var skipName: Bool

  public init(skipName: Bool) {
    self.skipName = skipName
  }

  public var variables: [String: InputValue]? {
    return ["skipName": skipName].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(Query.self) }
    public static var selections: [Selection] { [
        .field("hero", Hero?.self),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

      public static let possibleTypes: [String] = ["Human", "Droid"]
      public static var selections: [Selection] { [
          .field("__typename", String.self),
          GraphQLBooleanCondition(variableName: "skipName", inverted: true, selections: [
            .field("name", String.self),
          ]),
        ]
      }

      public static func makeHuman(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String? { data["name"] }
    }
  }
}

public final class HeroNameConditionalInclusionQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroNameConditionalInclusion($includeName: Boolean!) {
      hero {
        __typename
        name @include(if: $includeName)
      }
    }
    """

  public let operationName: String = "HeroNameConditionalInclusion"

  public let operationIdentifier: String? = "338081aea3acc83d04af0741ecf0da1ec2ee8e6468a88383476b681015905ef8"

  public var includeName: Bool

  public init(includeName: Bool) {
    self.includeName = includeName
  }

  public var variables: [String: InputValue]? {
    return ["includeName": includeName].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(Query.self) }
    public static var selections: [Selection] { [
        .field("hero", Hero?.self),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

      public static let possibleTypes: [String] = ["Human", "Droid"]
      public static var selections: [Selection] { [
          .field("__typename", String.self),
          GraphQLBooleanCondition(variableName: "includeName", inverted: false, selections: [
            .field("name", String.self),
          ]),
        ]
      }

      public static func makeHuman(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String? { data["name"] }
    }
  }
}

public final class HeroNameConditionalBothQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroNameConditionalBoth($skipName: Boolean!, $includeName: Boolean!) {
      hero {
        __typename
        name @skip(if: $skipName) @include(if: $includeName)
      }
    }
    """

  public let operationName: String = "HeroNameConditionalBoth"

  public let operationIdentifier: String? = "66f4dc124b6374b1912b22a2a208e34a4b1997349402a372b95bcfafc7884064"

  public var skipName: Bool
  public var includeName: Bool

  public init(skipName: Bool, includeName: Bool) {
    self.skipName = skipName
    self.includeName = includeName
  }

  public var variables: [String: InputValue]? {
    return ["skipName": skipName, "includeName": includeName].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(Query.self) }
    public static var selections: [Selection] { [
        .field("hero", Hero?.self),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

      public static let possibleTypes: [String] = ["Human", "Droid"]
      public static var selections: [Selection] { [
          .field("__typename", String.self),
          GraphQLBooleanCondition(variableName: "includeName", inverted: false, selections: [
            GraphQLBooleanCondition(variableName: "skipName", inverted: true, selections: [
              .field("name", String.self),
            ]),
          ]),
        ]
      }

      public static func makeHuman(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String? { data["name"] }
    }
  }
}

public final class HeroNameConditionalBothSeparateQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroNameConditionalBothSeparate($skipName: Boolean!, $includeName: Boolean!) {
      hero {
        __typename
        name @skip(if: $skipName)
        name @include(if: $includeName)
      }
    }
    """

  public let operationName: String = "HeroNameConditionalBothSeparate"

  public let operationIdentifier: String? = "d0f9e9205cdc09320035662f528a177654d3275b0bf94cf0e259a65fde33e7e5"

  public var skipName: Bool
  public var includeName: Bool

  public init(skipName: Bool, includeName: Bool) {
    self.skipName = skipName
    self.includeName = includeName
  }

  public var variables: [String: InputValue]? {
    return ["skipName": skipName, "includeName": includeName].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    
    public static var __parentType: ParentType { .Object(Query.self) }
    public static var selections: [Selection] { [
        .field("hero", Hero?.self),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

      public static let possibleTypes: [String] = ["Human", "Droid"]
      public static var selections: [Selection] { [
          .field("__typename", String.self),
          GraphQLBooleanCondition(variableName: "skipName", inverted: true, selections: [
            .field("name", String.self),
          ]),
          GraphQLBooleanCondition(variableName: "includeName", inverted: false, selections: [
            .field("name", String.self),
          ]),
        ]
      }

      public static func makeHuman(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String? { data["name"] }
    }
  }
}

public final class HeroDetailsInlineConditionalInclusionQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroDetailsInlineConditionalInclusion($includeDetails: Boolean!) {
      hero {
        __typename
        ... @include(if: $includeDetails) {
          name
          appearsIn
        }
      }
    }
    """

  public let operationName: String = "HeroDetailsInlineConditionalInclusion"

  public let operationIdentifier: String? = "fcd9d7acb4e7c97e3ae5ad3cbf4e83556626149de589f0c2fce2f8ede31b0d90"

  public var includeDetails: Bool

  public init(includeDetails: Bool) {
    self.includeDetails = includeDetails
  }

  public var variables: [String: InputValue]? {
    return ["includeDetails": includeDetails].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    
    public static var __parentType: ParentType { .Object(Query.self) }
    public static var selections: [Selection] { [
        .field("hero", Hero?.self),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      
      public static let possibleTypes: [String] = ["Human", "Droid"]
      public static var selections: [Selection] { [
          .field("__typename", String.self),
          GraphQLBooleanCondition(variableName: "includeDetails", inverted: false, selections: [
            .field("name", String.self),
            .field("appearsIn", .nonNull(.list(.scalar(Episode.self)))),
          ]),
        ]
      }

      public static func makeHuman(name: String? = nil, appearsIn: [Episode?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "appearsIn": appearsIn])
      }

      public static func makeDroid(name: String? = nil, appearsIn: [Episode?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String? { data["name"] }

      /// The movies this character appears in
      public var appearsIn: [Episode?]? { data["appearsIn"] }        
    }
  }
}

public final class HeroDetailsFragmentConditionalInclusionQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroDetailsFragmentConditionalInclusion($includeDetails: Boolean!) {
      hero {
        __typename
        ...HeroDetails @include(if: $includeDetails)
      }
    }
    """

  public let operationName: String = "HeroDetailsFragmentConditionalInclusion"

  public let operationIdentifier: String? = "b31aec7d977249e185922e4cc90318fd2c7197631470904bf937b0626de54b4f"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + HeroDetails.fragmentDefinition)
    return document
  }

  public var includeDetails: Bool

  public init(includeDetails: Bool) {
    self.includeDetails = includeDetails
  }

  public var variables: [String: InputValue]? {
    return ["includeDetails": includeDetails].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    
    public static var __parentType: ParentType { .Object(Query.self) }
    public static var selections: [Selection] { [
        .field("hero", Hero?.self),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }

      public static let possibleTypes: [String] = ["Human", "Droid"]
      public static var selections: [Selection] { [
          GraphQLTypeCase(
            variants: ["Human": AsHuman.selections, "Droid": AsDroid.selections],
            default: [
              .field("__typename", String.self),
              GraphQLBooleanCondition(variableName: "includeDetails", inverted: false, selections: [
                .field("__typename", String.self),
                .field("name", String.self),
              ]),
            ]
          )
        ]
      }

      public static func makeHuman(name: String? = nil, height: Double? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
      }

      public static func makeDroid(name: String? = nil, primaryFunction: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String? { data["name"] }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public var heroDetails: HeroDetails {
          get {
            return HeroDetails(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public var asHuman: AsHuman? {
        get {
          if !AsHuman.possibleTypes.contains(__typename) { return nil }
          return AsHuman(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsHuman: SelectionSet {
        public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        
        public static var __parentType: ParentType { .Object(Human.self) }
        public static var selections: [Selection] { [
            .field("__typename", String.self),
            GraphQLBooleanCondition(variableName: "includeDetails", inverted: false, selections: [
              .field("__typename", String.self),
              .field("name", String.self),
            ]),
            GraphQLBooleanCondition(variableName: "includeDetails", inverted: false, selections: [
              .field("__typename", String.self),
              .field("name", String.self),
              .field("__typename", String.self),
              .field("name", String.self),
              .field("height", .scalar(Double.self)),
            ]),
          ]
        }

        public init(name: String? = nil, height: Double? = nil) {
          self.init(json: ["__typename": "Human", "name": name, "height": height])
        }

        public var __typename: String { data["__typename"] }

        /// What this human calls themselves
        public var name: String? { data["name"] }

        /// Height in the preferred unit, default is meters
        public var height: Double? { data["height"] }          

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public var heroDetails: HeroDetails {
            get {
              return HeroDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public var asDroid: AsDroid? {
        get {
          if !AsDroid.possibleTypes.contains(__typename) { return nil }
          return AsDroid(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsDroid: SelectionSet {
        public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        
        public static var __parentType: ParentType { .Object(Droid.self) }
        public static var selections: [Selection] { [
            .field("__typename", String.self),
            GraphQLBooleanCondition(variableName: "includeDetails", inverted: false, selections: [
              .field("__typename", String.self),
              .field("name", String.self),
            ]),
            GraphQLBooleanCondition(variableName: "includeDetails", inverted: false, selections: [
              .field("__typename", String.self),
              .field("name", String.self),
              .field("__typename", String.self),
              .field("name", String.self),
              .field("primaryFunction", String?.self),
            ]),
          ]
        }

        public init(name: String? = nil, primaryFunction: String? = nil) {
          self.init(json: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
        }

        public var __typename: String { data["__typename"] }

        /// What others call this droid
        public var name: String? { data["name"] }

        /// This droid's primary function
        public var primaryFunction: String? { data["primaryFunction"] }          

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public var heroDetails: HeroDetails {
            get {
              return HeroDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }
  }
}

public final class HeroNameTypeSpecificConditionalInclusionQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroNameTypeSpecificConditionalInclusion($episode: Episode, $includeName: Boolean!) {
      hero(episode: $episode) {
        __typename
        name @include(if: $includeName)
        ... on Droid {
          name
        }
      }
    }
    """

  public let operationName: String = "HeroNameTypeSpecificConditionalInclusion"

  public let operationIdentifier: String? = "4d465fbc6e3731d011025048502f16278307d73300ea9329a709d7e2b6815e40"

  public var episode: Episode?
  public var includeName: Bool

  public init(episode: Episode? = nil, includeName: Bool) {
    self.episode = episode
    self.includeName = includeName
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode, "includeName": includeName].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    
    public static var __parentType: ParentType { .Object(Query.self) }
    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      
      public static let possibleTypes: [String] = ["Human", "Droid"]
      public static var selections: [Selection] { [
          GraphQLTypeCase(
            variants: ["Droid": AsDroid.selections],
            default: [
              .field("__typename", String.self),
              GraphQLBooleanCondition(variableName: "includeName", inverted: false, selections: [
                .field("name", String.self),
              ]),
            ]
          )
        ]
      }

      public static func makeHuman(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String? { data["name"] }

      public var asDroid: AsDroid? {
        get {
          if !AsDroid.possibleTypes.contains(__typename) { return nil }
          return AsDroid(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsDroid: SelectionSet {
        public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        
        public static var __parentType: ParentType { .Object(Droid.self) }
        public static var selections: [Selection] { [
            .field("__typename", String.self),
            GraphQLBooleanCondition(variableName: "includeName", inverted: false, selections: [
              .field("name", String.self),
            ]),
            .field("name", String.self),
          ]
        }

        public init(name: String) {
          self.init(json: ["__typename": "Droid", "name": name])
        }

        public var __typename: String { data["__typename"] }

        /// What others call this droid
        public var name: String { data["name"] }
      }
    }
  }
}

public final class HeroFriendsDetailsConditionalInclusionQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroFriendsDetailsConditionalInclusion($includeFriendsDetails: Boolean!) {
      hero {
        __typename
        friends @include(if: $includeFriendsDetails) {
          __typename
          name
          ... on Droid {
            primaryFunction
          }
        }
      }
    }
    """

  public let operationName: String = "HeroFriendsDetailsConditionalInclusion"

  public let operationIdentifier: String? = "9bdfeee789c1d22123402a9c3e3edefeb66799b3436289751be8f47905e3babd"

  public var includeFriendsDetails: Bool

  public init(includeFriendsDetails: Bool) {
    self.includeFriendsDetails = includeFriendsDetails
  }

  public var variables: [String: InputValue]? {
    return ["includeFriendsDetails": includeFriendsDetails].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    
    public static var __parentType: ParentType { .Object(Query.self) }
    public static var selections: [Selection] { [
        .field("hero", Hero?.self),
      ] }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      
      public static let possibleTypes: [String] = ["Human", "Droid"]
      public static var selections: [Selection] { [
          .field("__typename", String.self),
          GraphQLBooleanCondition(variableName: "includeFriendsDetails", inverted: false, selections: [
            .field("friends", [Friend?]?.self),
          ]),
        ]
      }

      public static func makeHuman(friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String { data["__typename"] }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? { data["friends"] }

      public struct Friend: SelectionSet {
        public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        
        public static let possibleTypes: [String] = ["Human", "Droid"]
        public static var selections: [Selection] { [
            GraphQLTypeCase(
              variants: ["Droid": AsDroid.selections],
              default: [
                .field("__typename", String.self),
                .field("name", String.self),
              ]
            )
          ]
        }

        public static func makeHuman(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
        }

        public static func makeDroid(name: String, primaryFunction: String? = nil) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
        }

        public var __typename: String { data["__typename"] }

        /// The name of the character
        public var name: String { data["name"] }

        public var asDroid: AsDroid? {
          get {
            if !AsDroid.possibleTypes.contains(__typename) { return nil }
            return AsDroid(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsDroid: TypeCase {
          public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
          
          public static var __parentType: ParentType { .Object(Droid.self) }
          public static var selections: [Selection] { [
              .field("__typename", String.self),
              .field("name", String.self),
              .field("primaryFunction", String?.self),
            ]
          }

          public init(name: String, primaryFunction: String? = nil) {
            self.init(json: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
          }

          public var __typename: String { data["__typename"] }

          /// What others call this droid
          public var name: String { data["name"] }

          /// This droid's primary function
          public var primaryFunction: String? { data["primaryFunction"] }            
        }
      }
    }
  }
}

public final class HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroFriendsDetailsUnconditionalAndConditionalInclusion($includeFriendsDetails: Boolean!) {
      hero {
        __typename
        friends {
          __typename
          name
        }
        friends @include(if: $includeFriendsDetails) {
          __typename
          name
          ... on Droid {
            primaryFunction
          }
        }
      }
    }
    """

  public let operationName: String = "HeroFriendsDetailsUnconditionalAndConditionalInclusion"

  public let operationIdentifier: String? = "501fcb710e5ffeeab2c65b7935fbded394ffea92e7b5dd904d05d5deab6f39c6"

  public var includeFriendsDetails: Bool

  public init(includeFriendsDetails: Bool) {
    self.includeFriendsDetails = includeFriendsDetails
  }

  public var variables: [String: InputValue]? {
    return ["includeFriendsDetails": includeFriendsDetails].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    
    public static var __parentType: ParentType { .Object(Query.self) }
    public static var selections: [Selection] { [
        .field("hero", Hero?.self),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      
      public static let possibleTypes: [String] = ["Human", "Droid"]
      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("friends", [Friend?]?.self),
          GraphQLBooleanCondition(variableName: "includeFriendsDetails", inverted: false, selections: [
            .field("friends", [Friend?]?.self),
          ]),
        ]
      }

      public static func makeHuman(friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String { data["__typename"] }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? { data["friends"] }

      public struct Friend: SelectionSet {
        public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        
        public static let possibleTypes: [String] = ["Human", "Droid"]
        public static var selections: [Selection] { [
            GraphQLTypeCase(
              variants: ["Droid": AsDroid.selections],
              default: [
                .field("__typename", String.self),
                .field("name", String.self),
                GraphQLBooleanCondition(variableName: "includeFriendsDetails", inverted: false, selections: [
                  .field("__typename", String.self),
                  .field("name", String.self),
                ]),
              ]
            )
          ]
        }

        public static func makeHuman(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
        }

        public static func makeDroid(name: String, primaryFunction: String? = nil) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
        }

        public var __typename: String { data["__typename"] }

        /// The name of the character
        public var name: String { data["name"] }

        public var asDroid: AsDroid? {
          get {
            if !AsDroid.possibleTypes.contains(__typename) { return nil }
            return AsDroid(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsDroid: TypeCase {
          public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
          
          public static var __parentType: ParentType { .Object(Droid.self) }
          public static var selections: [Selection] { [
              .field("__typename", String.self),
              .field("name", String.self),
              GraphQLBooleanCondition(variableName: "includeFriendsDetails", inverted: false, selections: [
                .field("__typename", String.self),
                .field("name", String.self),
              ]),
              GraphQLBooleanCondition(variableName: "includeFriendsDetails", inverted: false, selections: [
                .field("__typename", String.self),
                .field("name", String.self),
                .field("primaryFunction", String?.self),
              ]),
            ]
          }

          public init(name: String, primaryFunction: String? = nil) {
            self.init(json: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
          }

          public var __typename: String { data["__typename"] }

          /// What others call this droid
          public var name: String { data["name"] }

          /// This droid's primary function
          public var primaryFunction: String? { data["primaryFunction"] }            
        }
      }
    }
  }
}

public final class HeroDetailsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroDetails($episode: Episode) {
      hero(episode: $episode) {
        __typename
        name
        ... on Human {
          height
        }
        ... on Droid {
          primaryFunction
        }
      }
    }
    """

  public let operationName: String = "HeroDetails"

  public let operationIdentifier: String? = "2b67111fd3a1c6b2ac7d1ef7764e5cefa41d3f4218e1d60cb67c22feafbd43ec"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables().toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    
    public static var __parentType: ParentType { .Object(Query.self) }
    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      
      public static let possibleTypes: [String] = ["Human", "Droid"]
      public static var selections: [Selection] { [
          GraphQLTypeCase(
            variants: ["Human": AsHuman.selections, "Droid": AsDroid.selections],
            default: [
              .field("__typename", String.self),
              .field("name", String.self),
            ]
          )
        ]
      }

      public static func makeHuman(name: String, height: Double? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
      }

      public static func makeDroid(name: String, primaryFunction: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String { data["name"] }

      public var asHuman: AsHuman? {
        get {
          if !AsHuman.possibleTypes.contains(__typename) { return nil }
          return AsHuman(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsHuman: SelectionSet {
        public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        
        public static var __parentType: ParentType { .Object(Human.self) }
        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
            .field("height", .scalar(Double.self)),
          ]
        }

        public init(name: String, height: Double? = nil) {
          self.init(json: ["__typename": "Human", "name": name, "height": height])
        }

        public var __typename: String { data["__typename"] }

        /// What this human calls themselves
        public var name: String { data["name"] }

        /// Height in the preferred unit, default is meters
        public var height: Double? { data["height"] }          
      }

      public var asDroid: AsDroid? {
        get {
          if !AsDroid.possibleTypes.contains(__typename) { return nil }
          return AsDroid(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsDroid: SelectionSet {
        public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        
        public static var __parentType: ParentType { .Object(Droid.self) }
        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
            .field("primaryFunction", String?.self),
          ]
        }

        public init(name: String, primaryFunction: String? = nil) {
          self.init(json: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
        }

        public var __typename: String { data["__typename"] }

        /// What others call this droid
        public var name: String { data["name"] }

        /// This droid's primary function
        public var primaryFunction: String? { data["primaryFunction"] }          
      }
    }
  }
}

public final class HeroDetailsWithFragmentQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroDetailsWithFragment($episode: Episode) {
      hero(episode: $episode) {
        __typename
        ...HeroDetails
      }
    }
    """

  public let operationName: String = "HeroDetailsWithFragment"

  public let operationIdentifier: String? = "d20fa2f460058b8eec3d227f2f6088a708cf35dfa2b5ebf1414e34f9674ecfce"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + HeroDetails.fragmentDefinition)
    return document
  }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
    public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    
    public static var __parentType: ParentType { .Object(Query.self) }
    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
      public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      
      public static let possibleTypes: [String] = ["Human", "Droid"]
      public static var selections: [Selection] { [
          GraphQLTypeCase(
            variants: ["Human": AsHuman.selections, "Droid": AsDroid.selections],
            default: [
              .field("__typename", String.self),
              .field("__typename", String.self),
              .field("name", String.self),
            ]
          )
        ]
      }

      public static func makeHuman(name: String, height: Double? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
      }

      public static func makeDroid(name: String, primaryFunction: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String { data["name"] }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public var heroDetails: HeroDetails {
          get {
            return HeroDetails(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public var asHuman: AsHuman? {
        get {
          if !AsHuman.possibleTypes.contains(__typename) { return nil }
          return AsHuman(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsHuman: TypeCase {
        public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        
        public static var __parentType: ParentType { .Object(Human.self) }
        public static var selections: [Selection] { [
            .field("__typename", String.self),            
            .field("name", String.self),            
            .field("height", .scalar(Double.self)),
          ]
        }

        public init(name: String, height: Double? = nil) {
          self.init(json: ["__typename": "Human", "name": name, "height": height])
        }

        public var __typename: String { data["__typename"] }

        /// What this human calls themselves
        public var name: String { data["name"] }

        /// Height in the preferred unit, default is meters
        public var height: Double? { data["height"] }          

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public var heroDetails: HeroDetails {
            get {
              return HeroDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public var asDroid: AsDroid? {
        get {
          if !AsDroid.possibleTypes.contains(__typename) { return nil }
          return AsDroid(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsDroid: TypeCase {
        public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        
        public static var __parentType: ParentType { .Object(Droid.self) }
        public static var selections: [Selection] { [
            .field("__typename", String.self),            
            .field("name", String.self),
            .field("primaryFunction", String?.self),
          ]
        }

        public init(name: String, primaryFunction: String? = nil) {
          self.init(json: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
        }

        public var __typename: String { data["__typename"] }

        /// What others call this droid
        public var name: String { data["name"] }

        /// This droid's primary function
        public var primaryFunction: String? {
          get {
            return resultMap["primaryFunction"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "primaryFunction")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public var heroDetails: HeroDetails {
            get {
              return HeroDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }
  }
}

public final class DroidDetailsWithFragmentQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query DroidDetailsWithFragment($episode: Episode) {
      hero(episode: $episode) {
        __typename
        ...DroidDetails
      }
    }
    """

  public let operationName: String = "DroidDetailsWithFragment"

  public let operationIdentifier: String? = "7277e97563e911ac8f5c91d401028d218aae41f38df014d7fa0b037bb2a2e739"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + DroidDetails.fragmentDefinition)
    return document
  }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          GraphQLTypeCase(
            variants: ["Droid": AsDroid.selections],
            default: [
              .field("__typename", String.self),
            ]
          )
        ]
      }

      public static func makeHuman() -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human"])
      }

      public static func makeDroid(name: String, primaryFunction: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
      }

      public var __typename: String { data["__typename"] }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public var droidDetails: DroidDetails? {
          get {
            if !DroidDetails.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return DroidDetails(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }
      }

      public var asDroid: AsDroid? {
        get {
          if !AsDroid.possibleTypes.contains(__typename) { return nil }
          return AsDroid(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsDroid: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        public static let possibleTypes: [String] = ["Droid"]

        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("__typename", String.self),
            .field("name", String.self),
            .field("primaryFunction", String?.self),
          ]
        }

        public init(name: String, primaryFunction: String? = nil) {
          self.init(json: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
        }

        public var __typename: String { data["__typename"] }

        /// What others call this droid
        public var name: String { data["name"] }

        /// This droid's primary function
        public var primaryFunction: String? {
          get {
            return resultMap["primaryFunction"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "primaryFunction")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public var droidDetails: DroidDetails {
            get {
              return DroidDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }
  }
}

public final class HeroFriendsOfFriendsNamesQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroFriendsOfFriendsNames($episode: Episode) {
      hero(episode: $episode) {
        __typename
        friends {
          __typename
          id
          friends {
            __typename
            name
          }
        }
      }
    }
    """

  public let operationName: String = "HeroFriendsOfFriendsNames"

  public let operationIdentifier: String? = "37cd5626048e7243716ffda9e56503939dd189772124a1c21b0e0b87e69aae01"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("friends", [Friend?]?.self),
        ]
      }

      public static func makeHuman(friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String { data["__typename"] }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? { data["friends"] }

      public struct Friend: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        public static let possibleTypes: [String] = ["Human", "Droid"]

        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("id", ID.self),
            .field("friends", [Friend?]?.self),
          ]
        }

        public static func makeHuman(id: GraphQLID, friends: [Friend?]? = nil) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "id": id, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
        }

        public static func makeDroid(id: GraphQLID, friends: [Friend?]? = nil) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "id": id, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String { data["__typename"] }

        /// The ID of the character
        public var id: GraphQLID { data["id"] }

        /// The friends of the character, or an empty list if they have none
        public var friends: [Friend?]? { data["friends"] }

        public struct Friend: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
          public static let possibleTypes: [String] = ["Human", "Droid"]

          public static var selections: [Selection] { [
              .field("__typename", String.self),
              .field("name", String.self),
            ]
          }

          public static func makeHuman(name: String) -> Friend {
            return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
          }

          public static func makeDroid(name: String) -> Friend {
            return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
          }

          public var __typename: String { data["__typename"] }

          /// The name of the character
          public var name: String { data["name"] }

        }
      }
    }
  }
}

public final class HeroNameQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroName($episode: Episode) {
      hero(episode: $episode) {
        __typename
        name
      }
    }
    """

  public let operationName: String = "HeroName"

  public let operationIdentifier: String? = "f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
        ]
      }

      public static func makeHuman(name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String { data["name"] }

    }
  }
}

public final class HeroNameWithIdQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroNameWithID($episode: Episode) {
      hero(episode: $episode) {
        __typename
        id
        name
      }
    }
    """

  public let operationName: String = "HeroNameWithID"

  public let operationIdentifier: String? = "83c03f612c46fca72f6cb902df267c57bffc9209bc44dd87d2524fb2b34f6f18"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("id", ID.self),
          .field("name", String.self),
        ]
      }

      public static func makeHuman(id: GraphQLID, name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "id": id, "name": name])
      }

      public static func makeDroid(id: GraphQLID, name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "id": id, "name": name])
      }

      public var __typename: String { data["__typename"] }

      /// The ID of the character
      public var id: GraphQLID { data["id"] }

      /// The name of the character
      public var name: String { data["name"] }

    }
  }
}

public final class HeroNameWithFragmentQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroNameWithFragment($episode: Episode) {
      hero(episode: $episode) {
        __typename
        ...CharacterName
      }
    }
    """

  public let operationName: String = "HeroNameWithFragment"

  public let operationIdentifier: String? = "b952f0054915a32ec524ac0dde0244bcda246649debe149f9e32e303e21c8266"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + CharacterName.fragmentDefinition)
    return document
  }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("__typename", String.self),
          .field("name", String.self),
        ]
      }

      public static func makeHuman(name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String { data["name"] }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public var characterName: CharacterName {
          get {
            return CharacterName(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public final class HeroNameWithFragmentAndIdQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroNameWithFragmentAndID($episode: Episode) {
      hero(episode: $episode) {
        __typename
        id
        ...CharacterName
      }
    }
    """

  public let operationName: String = "HeroNameWithFragmentAndID"

  public let operationIdentifier: String? = "a87a0694c09d1ed245e9a80f245d96a5f57b20a4aa936ee9ab09b2a43620db02"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + CharacterName.fragmentDefinition)
    return document
  }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("id", ID.self),
          .field("__typename", String.self),
          .field("name", String.self),
        ]
      }

      public static func makeHuman(id: GraphQLID, name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "id": id, "name": name])
      }

      public static func makeDroid(id: GraphQLID, name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "id": id, "name": name])
      }

      public var __typename: String { data["__typename"] }

      /// The ID of the character
      public var id: GraphQLID { data["id"] }

      /// The name of the character
      public var name: String { data["name"] }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public var characterName: CharacterName {
          get {
            return CharacterName(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public final class HeroNameAndAppearsInQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroNameAndAppearsIn($episode: Episode) {
      hero(episode: $episode) {
        __typename
        name
        appearsIn
      }
    }
    """

  public let operationName: String = "HeroNameAndAppearsIn"

  public let operationIdentifier: String? = "f714414a2002404f9943490c8cc9c1a7b8ecac3ca229fa5a326186b43c1385ce"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
          .field("appearsIn", .nonNull(.list(.scalar(Episode.self)))),
        ]
      }

      public static func makeHuman(name: String, appearsIn: [Episode?]) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "appearsIn": appearsIn])
      }

      public static func makeDroid(name: String, appearsIn: [Episode?]) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String { data["name"] }

      /// The movies this character appears in
      public var appearsIn: [Episode?] { data["appearsIn"] }

    }
  }
}

public final class HeroNameAndAppearsInWithFragmentQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroNameAndAppearsInWithFragment($episode: Episode) {
      hero(episode: $episode) {
        __typename
        ...CharacterNameAndAppearsIn
      }
    }
    """

  public let operationName: String = "HeroNameAndAppearsInWithFragment"

  public let operationIdentifier: String? = "0664fed3eb4f9fbdb44e8691d9e8fd11f2b3c097ba11327592054f602bd3ba1a"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + CharacterNameAndAppearsIn.fragmentDefinition)
    return document
  }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("__typename", String.self),
          .field("name", String.self),
          .field("appearsIn", .nonNull(.list(.scalar(Episode.self)))),
        ]
      }

      public static func makeHuman(name: String, appearsIn: [Episode?]) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "appearsIn": appearsIn])
      }

      public static func makeDroid(name: String, appearsIn: [Episode?]) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String { data["name"] }

      /// The movies this character appears in
      public var appearsIn: [Episode?] { data["appearsIn"] }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public var characterNameAndAppearsIn: CharacterNameAndAppearsIn {
          get {
            return CharacterNameAndAppearsIn(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public final class HeroParentTypeDependentFieldQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroParentTypeDependentField($episode: Episode) {
      hero(episode: $episode) {
        __typename
        name
        ... on Human {
          friends {
            __typename
            name
            ... on Human {
              height(unit: FOOT)
            }
          }
        }
        ... on Droid {
          friends {
            __typename
            name
            ... on Human {
              height(unit: METER)
            }
          }
        }
      }
    }
    """

  public let operationName: String = "HeroParentTypeDependentField"

  public let operationIdentifier: String? = "561e22ac4da5209f254779b70e01557fb2fc57916b9914088429ec809e166cad"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          GraphQLTypeCase(
            variants: ["Human": AsHuman.selections, "Droid": AsDroid.selections],
            default: [
              .field("__typename", String.self),
              .field("name", String.self),
            ]
          )
        ]
      }

      public static func makeHuman(name: String, friends: [AsHuman.Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "friends": friends.flatMap { (value: [AsHuman.Friend?]) -> [ResultMap?] in value.map { (value: AsHuman.Friend?) -> ResultMap? in value.flatMap { (value: AsHuman.Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(name: String, friends: [AsDroid.Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "friends": friends.flatMap { (value: [AsDroid.Friend?]) -> [ResultMap?] in value.map { (value: AsDroid.Friend?) -> ResultMap? in value.flatMap { (value: AsDroid.Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String { data["name"] }

      public var asHuman: AsHuman? {
        get {
          if !AsHuman.possibleTypes.contains(__typename) { return nil }
          return AsHuman(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsHuman: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        public static let possibleTypes: [String] = ["Human"]

        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
            .field("friends", [Friend?]?.self),
          ]
        }

        public init(name: String, friends: [Friend?]? = nil) {
          self.init(json: ["__typename": "Human", "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String { data["__typename"] }

        /// What this human calls themselves
        public var name: String { data["name"] }

        /// This human's friends, or an empty list if they have none
        public var friends: [Friend?]? { data["friends"] }

        public struct Friend: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
          public static let possibleTypes: [String] = ["Human", "Droid"]

          public static var selections: [Selection] { [
              GraphQLTypeCase(
                variants: ["Human": AsHuman.selections],
                default: [
                  .field("__typename", String.self),
                  .field("name", String.self),
                ]
              )
            ]
          }

          public static func makeDroid(name: String) -> Friend {
            return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
          }

          public static func makeHuman(name: String, height: Double? = nil) -> Friend {
            return Friend(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
          }

          public var __typename: String { data["__typename"] }

          /// The name of the character
          public var name: String { data["name"] }

          public var asHuman: AsHuman? {
            get {
              if !AsHuman.possibleTypes.contains(__typename) { return nil }
              return AsHuman(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsHuman: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
            public static let possibleTypes: [String] = ["Human"]

            public static var selections: [Selection] { [
                .field("__typename", String.self),
                .field("name", String.self),
                .field("height", arguments: ["unit": "FOOT"], .scalar(Double.self)),
              ]
            }

            public init(name: String, height: Double? = nil) {
              self.init(json: ["__typename": "Human", "name": name, "height": height])
            }

            public var __typename: String { data["__typename"] }

            /// What this human calls themselves
            public var name: String { data["name"] }

            /// Height in the preferred unit, default is meters
            public var height: Double? {
              get {
                return resultMap["height"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "height")
              }
            }
          }
        }
      }

      public var asDroid: AsDroid? {
        get {
          if !AsDroid.possibleTypes.contains(__typename) { return nil }
          return AsDroid(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsDroid: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        public static let possibleTypes: [String] = ["Droid"]

        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("name", String.self),
            .field("friends", [Friend?]?.self),
          ]
        }

        public init(name: String, friends: [Friend?]? = nil) {
          self.init(json: ["__typename": "Droid", "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String { data["__typename"] }

        /// What others call this droid
        public var name: String { data["name"] }

        /// This droid's friends, or an empty list if they have none
        public var friends: [Friend?]? { data["friends"] }

        public struct Friend: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
          public static let possibleTypes: [String] = ["Human", "Droid"]

          public static var selections: [Selection] { [
              GraphQLTypeCase(
                variants: ["Human": AsHuman.selections],
                default: [
                  .field("__typename", String.self),
                  .field("name", String.self),
                ]
              )
            ]
          }

          public static func makeDroid(name: String) -> Friend {
            return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
          }

          public static func makeHuman(name: String, height: Double? = nil) -> Friend {
            return Friend(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
          }

          public var __typename: String { data["__typename"] }

          /// The name of the character
          public var name: String { data["name"] }

          public var asHuman: AsHuman? {
            get {
              if !AsHuman.possibleTypes.contains(__typename) { return nil }
              return AsHuman(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsHuman: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
            public static let possibleTypes: [String] = ["Human"]

            public static var selections: [Selection] { [
                .field("__typename", String.self),
                .field("name", String.self),
                .field("height", arguments: ["unit": "METER"], .scalar(Double.self)),
              ]
            }

            public init(name: String, height: Double? = nil) {
              self.init(json: ["__typename": "Human", "name": name, "height": height])
            }

            public var __typename: String { data["__typename"] }

            /// What this human calls themselves
            public var name: String { data["name"] }

            /// Height in the preferred unit, default is meters
            public var height: Double? {
              get {
                return resultMap["height"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "height")
              }
            }
          }
        }
      }
    }
  }
}

public final class HeroTypeDependentAliasedFieldQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query HeroTypeDependentAliasedField($episode: Episode) {
      hero(episode: $episode) {
        __typename
        ... on Human {
          property: homePlanet
        }
        ... on Droid {
          property: primaryFunction
        }
      }
    }
    """

  public let operationName: String = "HeroTypeDependentAliasedField"

  public let operationIdentifier: String? = "b5838c22bac1c5626023dac4412ca9b86bebfe16608991fb632a37c44e12811e"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [Selection] { [
        .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
      ]
    }

    public init(hero: Hero? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public struct Hero: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          GraphQLTypeCase(
            variants: ["Human": AsHuman.selections, "Droid": AsDroid.selections],
            default: [
              .field("__typename", String.self),
            ]
          )
        ]
      }

      public static func makeHuman(property: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "property": property])
      }

      public static func makeDroid(property: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "property": property])
      }

      public var __typename: String { data["__typename"] }

      public var asHuman: AsHuman? {
        get {
          if !AsHuman.possibleTypes.contains(__typename) { return nil }
          return AsHuman(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsHuman: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        public static let possibleTypes: [String] = ["Human"]

        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("homePlanet", alias: "property", String?.self),
          ]
        }

        public init(property: String? = nil) {
          self.init(json: ["__typename": "Human", "property": property])
        }

        public var __typename: String { data["__typename"] }

        /// The home planet of the human, or null if unknown
        public var property: String? {
          get {
            return resultMap["property"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "property")
          }
        }
      }

      public var asDroid: AsDroid? {
        get {
          if !AsDroid.possibleTypes.contains(__typename) { return nil }
          return AsDroid(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsDroid: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        public static let possibleTypes: [String] = ["Droid"]

        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("primaryFunction", alias: "property", String?.self),
          ]
        }

        public init(property: String? = nil) {
          self.init(json: ["__typename": "Droid", "property": property])
        }

        public var __typename: String { data["__typename"] }

        /// This droid's primary function
        public var property: String? {
          get {
            return resultMap["property"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "property")
          }
        }
      }
    }
  }
}

public final class SameHeroTwiceQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query SameHeroTwice {
      hero {
        __typename
        name
      }
      r2: hero {
        __typename
        appearsIn
      }
    }
    """

  public let operationName: String = "SameHeroTwice"

  public let operationIdentifier: String? = "2a8ad85a703add7d64622aaf6be76b58a1134caf28e4ff6b34dd00ba89541364"

  public init() {
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [Selection] { [
        .field("hero", Hero?.self),
        .field("hero", alias: "r2", .object(R2.selections)),
      ]
    }

    public init(hero: Hero? = nil, r2: R2? = nil) {
      self.init(json: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }, "r2": r2.flatMap { (value: R2) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? { data["hero"] }

    public var r2: R2? { data["r2"] }

    public struct Hero: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
        ]
      }

      public static func makeHuman(name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String { data["name"] }

    }

    public struct R2: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("appearsIn", .nonNull(.list(.scalar(Episode.self)))),
        ]
      }

      public static func makeHuman(appearsIn: [Episode?]) -> R2 {
        return R2(unsafeResultMap: ["__typename": "Human", "appearsIn": appearsIn])
      }

      public static func makeDroid(appearsIn: [Episode?]) -> R2 {
        return R2(unsafeResultMap: ["__typename": "Droid", "appearsIn": appearsIn])
      }

      public var __typename: String { data["__typename"] }

      /// The movies this character appears in
      public var appearsIn: [Episode?] { data["appearsIn"] }

    }
  }
}

public final class SearchQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Search($term: String) {
      search(text: $term) {
        __typename
        ... on Human {
          id
          name
        }
        ... on Droid {
          id
          name
        }
        ... on Starship {
          id
          name
        }
      }
    }
    """

  public let operationName: String = "Search"

  public let operationIdentifier: String? = "73536da2eec4d83e6e1003e674cb2299d9da2798f7bd310e57339a6bcd713b77"

  public var term: String?

  public init(term: String? = nil) {
    self.term = term
  }

  public var variables: [String: InputValue]? {
    return ["term": term].toInputVariables()
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [Selection] { [
        .field("search", arguments: ["text": .variable("term")], .list(.object(Search.selections))),
      ]
    }

    public init(search: [Search?]? = nil) {
      self.init(json: ["__typename": "Query", "search": search.flatMap { (value: [Search?]) -> [ResultMap?] in value.map { (value: Search?) -> ResultMap? in value.flatMap { (value: Search) -> ResultMap in value.resultMap } } }])
    }

    public var search: [Search?]? {
      get {
        return (resultMap["search"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Search?] in value.map { (value: ResultMap?) -> Search? in value.flatMap { (value: ResultMap) -> Search in Search(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [Search?]) -> [ResultMap?] in value.map { (value: Search?) -> ResultMap? in value.flatMap { (value: Search) -> ResultMap in value.resultMap } } }, forKey: "search")
      }
    }

    public struct Search: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid", "Starship"]

      public static var selections: [Selection] { [
          GraphQLTypeCase(
            variants: ["Human": AsHuman.selections, "Droid": AsDroid.selections, "Starship": AsStarship.selections],
            default: [
              .field("__typename", String.self),
            ]
          )
        ]
      }

      public static func makeHuman(id: GraphQLID, name: String) -> Search {
        return Search(unsafeResultMap: ["__typename": "Human", "id": id, "name": name])
      }

      public static func makeDroid(id: GraphQLID, name: String) -> Search {
        return Search(unsafeResultMap: ["__typename": "Droid", "id": id, "name": name])
      }

      public static func makeStarship(id: GraphQLID, name: String) -> Search {
        return Search(unsafeResultMap: ["__typename": "Starship", "id": id, "name": name])
      }

      public var __typename: String { data["__typename"] }

      public var asHuman: AsHuman? {
        get {
          if !AsHuman.possibleTypes.contains(__typename) { return nil }
          return AsHuman(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsHuman: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        public static let possibleTypes: [String] = ["Human"]

        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("id", ID.self),
            .field("name", String.self),
          ]
        }

        public init(id: GraphQLID, name: String) {
          self.init(json: ["__typename": "Human", "id": id, "name": name])
        }

        public var __typename: String { data["__typename"] }

        /// The ID of the human
        public var id: GraphQLID { data["id"] }

        /// What this human calls themselves
        public var name: String { data["name"] }

      }

      public var asDroid: AsDroid? {
        get {
          if !AsDroid.possibleTypes.contains(__typename) { return nil }
          return AsDroid(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsDroid: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        public static let possibleTypes: [String] = ["Droid"]

        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("id", ID.self),
            .field("name", String.self),
          ]
        }

        public init(id: GraphQLID, name: String) {
          self.init(json: ["__typename": "Droid", "id": id, "name": name])
        }

        public var __typename: String { data["__typename"] }

        /// The ID of the droid
        public var id: GraphQLID { data["id"] }

        /// What others call this droid
        public var name: String { data["name"] }

      }

      public var asStarship: AsStarship? {
        get {
          if !AsStarship.possibleTypes.contains(__typename) { return nil }
          return AsStarship(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsStarship: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
        public static let possibleTypes: [String] = ["Starship"]

        public static var selections: [Selection] { [
            .field("__typename", String.self),
            .field("id", ID.self),
            .field("name", String.self),
          ]
        }

        public init(id: GraphQLID, name: String) {
          self.init(json: ["__typename": "Starship", "id": id, "name": name])
        }

        public var __typename: String { data["__typename"] }

        /// The ID of the starship
        public var id: GraphQLID { data["id"] }

        /// The name of the starship
        public var name: String { data["name"] }

      }
    }
  }
}

public final class StarshipQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Starship {
      starship(id: 3000) {
        __typename
        name
        coordinates
      }
    }
    """

  public let operationName: String = "Starship"

  public let operationIdentifier: String? = "a3734516185da9919e3e66d74fe92b60d65292a1943dc54913f7332637dfdd2a"

  public init() {
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [Selection] { [
        .field("starship", arguments: ["id": 3000], .object(Starship.selections)),
      ]
    }

    public init(starship: Starship? = nil) {
      self.init(json: ["__typename": "Query", "starship": starship.flatMap { (value: Starship) -> ResultMap in value.resultMap }])
    }

    public var starship: Starship? { data["starship"] }

    public struct Starship: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Starship"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
          .field("coordinates", .list(.nonNull(.list(.nonNull(.scalar(Double.self)))))),
        ]
      }

      public init(name: String, coordinates: [[Double]]? = nil) {
        self.init(json: ["__typename": "Starship", "name": name, "coordinates": coordinates])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the starship
      public var name: String { data["name"] }

      public var coordinates: [[Double]]? {
        get {
          return resultMap["coordinates"] as? [[Double]]
        }
        set {
          resultMap.updateValue(newValue, forKey: "coordinates")
        }
      }
    }
  }
}

public final class StarshipCoordinatesQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query StarshipCoordinates($coordinates: [[Float!]!]) {
      starshipCoordinates(coordinates: $coordinates) {
        __typename
        name
        coordinates
        length
      }
    }
    """

  public let operationName: String = "StarshipCoordinates"

  public let operationIdentifier: String? = "8dd77d4bc7494c184606da092a665a7c2ca3c2a3f14d3b23fa5e469e207b3406"

  public var coordinates: [[Double]]?

  public init(coordinates: [[Double]]?) {
    self.coordinates = coordinates
  }

  public var variables: [String: InputValue]? {
    return ["coordinates": coordinates].toInputVariables()
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [Selection] { [
        .field("starshipCoordinates", arguments: ["coordinates": .variable("coordinates")], .object(StarshipCoordinate.selections)),
      ]
    }

    public init(starshipCoordinates: StarshipCoordinate? = nil) {
      self.init(json: ["__typename": "Query", "starshipCoordinates": starshipCoordinates.flatMap { (value: StarshipCoordinate) -> ResultMap in value.resultMap }])
    }

    public var starshipCoordinates: StarshipCoordinate? { data["starshipCoordinates"] }

    public struct StarshipCoordinate: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Starship"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
          .field("coordinates", .list(.nonNull(.list(.nonNull(.scalar(Double.self)))))),
          .field("length", .scalar(Double.self)),
        ]
      }

      public init(name: String, coordinates: [[Double]]? = nil, length: Double? = nil) {
        self.init(json: ["__typename": "Starship", "name": name, "coordinates": coordinates, "length": length])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the starship
      public var name: String { data["name"] }

      public var coordinates: [[Double]]? {
        get {
          return resultMap["coordinates"] as? [[Double]]
        }
        set {
          resultMap.updateValue(newValue, forKey: "coordinates")
        }
      }

      /// Length of the starship, along the longest axis
      public var length: Double? {
        get {
          return resultMap["length"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "length")
        }
      }
    }
  }
}

public final class ReviewAddedSubscription: GraphQLSubscription {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    subscription ReviewAdded($episode: Episode) {
      reviewAdded(episode: $episode) {
        __typename
        episode
        stars
        commentary
      }
    }
    """

  public let operationName: String = "ReviewAdded"

  public let operationIdentifier: String? = "38644c5e7cf4fd506b91d2e7010cabf84e63dfcd33cf1deb443b4b32b55e2cbe"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: [String: InputValue]? {
    return ["episode": episode].toInputVariables()
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Subscription"]

    public static var selections: [Selection] { [
        .field("reviewAdded", arguments: ["episode": .variable("episode")], .object(ReviewAdded.selections)),
      ]
    }

    public init(reviewAdded: ReviewAdded? = nil) {
      self.init(json: ["__typename": "Subscription", "reviewAdded": reviewAdded.flatMap { (value: ReviewAdded) -> ResultMap in value.resultMap }])
    }

    public var reviewAdded: ReviewAdded? { data["reviewAdded"] }

    public struct ReviewAdded: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Review"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("episode", Episode?.self),
          .field("stars", Int.self),
          .field("commentary", String?.self),
        ]
      }

      public init(episode: Episode? = nil, stars: Int, commentary: String? = nil) {
        self.init(json: ["__typename": "Review", "episode": episode, "stars": stars, "commentary": commentary])
      }

      public var __typename: String { data["__typename"] }

      /// The movie
      public var episode: Episode? {
        get {
          return resultMap["episode"] as? Episode
        }
        set {
          resultMap.updateValue(newValue, forKey: "episode")
        }
      }

      /// The number of stars this review gave, 1-5
      public var stars: Int { data["stars"] }

      /// Comment about the movie
      public var commentary: String? {
        get {
          return resultMap["commentary"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "commentary")
        }
      }
    }
  }
}

public final class HumanQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Human($id: ID!) {
      human(id: $id) {
        __typename
        name
        mass
      }
    }
    """

  public let operationName: String = "Human"

  public let operationIdentifier: String? = "b37eb69b82fd52358321e49453769750983be1c286744dbf415735d7bcf12f1e"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: [String: InputValue]? {
    return ["id": id].toInputVariables()
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [Selection] { [
        .field("human", arguments: ["id": .variable("id")], .object(Human.selections)),
      ]
    }

    public init(human: Human? = nil) {
      self.init(json: ["__typename": "Query", "human": human.flatMap { (value: Human) -> ResultMap in value.resultMap }])
    }

    public var human: Human? { data["human"] }

    public struct Human: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
          .field("mass", .scalar(Double.self)),
        ]
      }

      public init(name: String, mass: Double? = nil) {
        self.init(json: ["__typename": "Human", "name": name, "mass": mass])
      }

      public var __typename: String { data["__typename"] }

      /// What this human calls themselves
      public var name: String { data["name"] }

      /// Mass in kilograms, or null if unknown
      public var mass: Double? {
        get {
          return resultMap["mass"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "mass")
        }
      }
    }
  }
}

public final class TwoHeroesQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query TwoHeroes {
      r2: hero {
        __typename
        name
      }
      luke: hero(episode: EMPIRE) {
        __typename
        name
      }
    }
    """

  public let operationName: String = "TwoHeroes"

  public let operationIdentifier: String? = "b868fa9c48f19b8151c08c09f46831e3b9cd09f5c617d328647de785244b52bb"

  public init() {
  }

  public struct Data: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [Selection] { [
        .field("hero", alias: "r2", .object(R2.selections)),
        .field("hero", alias: "luke", arguments: ["episode": "EMPIRE"], .object(Luke.selections)),
      ]
    }

    public init(r2: R2? = nil, luke: Luke? = nil) {
      self.init(json: ["__typename": "Query", "r2": r2.flatMap { (value: R2) -> ResultMap in value.resultMap }, "luke": luke.flatMap { (value: Luke) -> ResultMap in value.resultMap }])
    }

    public var r2: R2? { data["r2"] }

    public var luke: Luke? { data["luke"] }

    public struct R2: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
        ]
      }

      public static func makeHuman(name: String) -> R2 {
        return R2(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> R2 {
        return R2(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String { data["name"] }

    }

    public struct Luke: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
        ]
      }

      public static func makeHuman(name: String) -> Luke {
        return Luke(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Luke {
        return Luke(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String { data["name"] }

    }
  }
}

public struct DroidNameAndPrimaryFunction: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment DroidNameAndPrimaryFunction on Droid {
      __typename
      ...CharacterName
      ...DroidPrimaryFunction
    }
    """

  public static let possibleTypes: [String] = ["Droid"]

  public static var selections: [Selection] { [
      .field("__typename", String.self),
      .field("__typename", String.self),
      .field("name", String.self),
      .field("__typename", String.self),
      .field("primaryFunction", String?.self),
    ]
  }

  public init(name: String, primaryFunction: String? = nil) {
    self.init(json: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
  }

  public var __typename: String { data["__typename"] }

  /// What others call this droid
  public var name: String { data["name"] }

  /// This droid's primary function
  public var primaryFunction: String? {
    get {
      return resultMap["primaryFunction"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "primaryFunction")
    }
  }

  public var fragments: Fragments {
    get {
      return Fragments(unsafeResultMap: resultMap)
    }
    set {
      resultMap += newValue.resultMap
    }
  }

  public struct Fragments {
    public var characterName: CharacterName {
      get {
        return CharacterName(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public var droidPrimaryFunction: DroidPrimaryFunction {
      get {
        return DroidPrimaryFunction(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }
  }
}

public struct CharacterNameAndDroidPrimaryFunction: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment CharacterNameAndDroidPrimaryFunction on Character {
      __typename
      ...CharacterName
      ...DroidPrimaryFunction
    }
    """

  public static let possibleTypes: [String] = ["Human", "Droid"]

  public static var selections: [Selection] { [
      GraphQLTypeCase(
        variants: ["Droid": AsDroid.selections],
        default: [
          .field("__typename", String.self),
          .field("__typename", String.self),
          .field("name", String.self),
        ]
      )
    ]
  }

  public static func makeHuman(name: String) -> CharacterNameAndDroidPrimaryFunction {
    return CharacterNameAndDroidPrimaryFunction(unsafeResultMap: ["__typename": "Human", "name": name])
  }

  public static func makeDroid(name: String, primaryFunction: String? = nil) -> CharacterNameAndDroidPrimaryFunction {
    return CharacterNameAndDroidPrimaryFunction(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
  }

  public var __typename: String { data["__typename"] }

  /// The name of the character
  public var name: String { data["name"] }

  public var fragments: Fragments {
    get {
      return Fragments(unsafeResultMap: resultMap)
    }
    set {
      resultMap += newValue.resultMap
    }
  }

  public struct Fragments {
    public var characterName: CharacterName {
      get {
        return CharacterName(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public var droidPrimaryFunction: DroidPrimaryFunction? {
      get {
        if !DroidPrimaryFunction.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
        return DroidPrimaryFunction(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap += newValue.resultMap
      }
    }
  }

  public var asDroid: AsDroid? {
    get {
      if !AsDroid.possibleTypes.contains(__typename) { return nil }
      return AsDroid(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsDroid: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Droid"]

    public static var selections: [Selection] { [
        .field("__typename", String.self),
        .field("__typename", String.self),
        .field("name", String.self),
        .field("__typename", String.self),
        .field("primaryFunction", String?.self),
      ]
    }

    public init(name: String, primaryFunction: String? = nil) {
      self.init(json: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
    }

    public var __typename: String { data["__typename"] }

    /// What others call this droid
    public var name: String { data["name"] }

    /// This droid's primary function
    public var primaryFunction: String? {
      get {
        return resultMap["primaryFunction"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "primaryFunction")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public var characterName: CharacterName {
        get {
          return CharacterName(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public var droidPrimaryFunction: DroidPrimaryFunction {
        get {
          return DroidPrimaryFunction(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }
}

public struct CharacterNameAndDroidAppearsIn: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment CharacterNameAndDroidAppearsIn on Character {
      __typename
      name
      ... on Droid {
        appearsIn
      }
    }
    """

  public static let possibleTypes: [String] = ["Human", "Droid"]

  public static var selections: [Selection] { [
      GraphQLTypeCase(
        variants: ["Droid": AsDroid.selections],
        default: [
          .field("__typename", String.self),
          .field("name", String.self),
        ]
      )
    ]
  }

  public static func makeHuman(name: String) -> CharacterNameAndDroidAppearsIn {
    return CharacterNameAndDroidAppearsIn(unsafeResultMap: ["__typename": "Human", "name": name])
  }

  public static func makeDroid(name: String, appearsIn: [Episode?]) -> CharacterNameAndDroidAppearsIn {
    return CharacterNameAndDroidAppearsIn(unsafeResultMap: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
  }

  public var __typename: String { data["__typename"] }

  /// The name of the character
  public var name: String { data["name"] }

  public var asDroid: AsDroid? {
    get {
      if !AsDroid.possibleTypes.contains(__typename) { return nil }
      return AsDroid(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsDroid: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Droid"]

    public static var selections: [Selection] { [
        .field("__typename", String.self),
        .field("name", String.self),
        .field("appearsIn", .nonNull(.list(.scalar(Episode.self)))),
      ]
    }

    public init(name: String, appearsIn: [Episode?]) {
      self.init(json: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
    }

    public var __typename: String { data["__typename"] }

    /// What others call this droid
    public var name: String { data["name"] }

    /// The movies this droid appears in
    public var appearsIn: [Episode?] { data["appearsIn"] }

  }
}

public struct DroidName: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment DroidName on Droid {
      __typename
      name
    }
    """

  public static let possibleTypes: [String] = ["Droid"]

  public static var selections: [Selection] { [
      .field("__typename", String.self),
      .field("name", String.self),
    ]
  }

  public init(name: String) {
    self.init(json: ["__typename": "Droid", "name": name])
  }

  public var __typename: String { data["__typename"] }

  /// What others call this droid
  public var name: String { data["name"] }

}

public struct DroidPrimaryFunction: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment DroidPrimaryFunction on Droid {
      __typename
      primaryFunction
    }
    """

  public static let possibleTypes: [String] = ["Droid"]

  public static var selections: [Selection] { [
      .field("__typename", String.self),
      .field("primaryFunction", String?.self),
    ]
  }

  public init(primaryFunction: String? = nil) {
    self.init(json: ["__typename": "Droid", "primaryFunction": primaryFunction])
  }

  public var __typename: String { data["__typename"] }

  /// This droid's primary function
  public var primaryFunction: String? {
    get {
      return resultMap["primaryFunction"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "primaryFunction")
    }
  }
}

public struct HumanHeightWithVariable: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment HumanHeightWithVariable on Human {
      __typename
      height(unit: $heightUnit)
    }
    """

  public static let possibleTypes: [String] = ["Human"]

  public static var selections: [Selection] { [
      .field("__typename", String.self),
      .field("height", arguments: ["unit": .variable("heightUnit")], .scalar(Double.self)),
    ]
  }

  public init(height: Double? = nil) {
    self.init(json: ["__typename": "Human", "height": height])
  }

  public var __typename: String { data["__typename"] }

  /// Height in the preferred unit, default is meters
  public var height: Double? {
    get {
      return resultMap["height"] as? Double
    }
    set {
      resultMap.updateValue(newValue, forKey: "height")
    }
  }
}

public struct CharacterNameAndAppearsInWithNestedFragments: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment CharacterNameAndAppearsInWithNestedFragments on Character {
      __typename
      ...CharacterNameWithNestedAppearsInFragment
    }
    """

  public static let possibleTypes: [String] = ["Human", "Droid"]

  public static var selections: [Selection] { [
      .field("__typename", String.self),
      .field("__typename", String.self),
      .field("name", String.self),
      .field("__typename", String.self),
      .field("appearsIn", .nonNull(.list(.scalar(Episode.self)))),
    ]
  }

  public static func makeHuman(name: String, appearsIn: [Episode?]) -> CharacterNameAndAppearsInWithNestedFragments {
    return CharacterNameAndAppearsInWithNestedFragments(unsafeResultMap: ["__typename": "Human", "name": name, "appearsIn": appearsIn])
  }

  public static func makeDroid(name: String, appearsIn: [Episode?]) -> CharacterNameAndAppearsInWithNestedFragments {
    return CharacterNameAndAppearsInWithNestedFragments(unsafeResultMap: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
  }

  public var __typename: String { data["__typename"] }

  /// The name of the character
  public var name: String { data["name"] }

  /// The movies this character appears in
  public var appearsIn: [Episode?] { data["appearsIn"] }

  public var fragments: Fragments {
    get {
      return Fragments(unsafeResultMap: resultMap)
    }
    set {
      resultMap += newValue.resultMap
    }
  }

  public struct Fragments {
    public var characterNameWithNestedAppearsInFragment: CharacterNameWithNestedAppearsInFragment {
      get {
        return CharacterNameWithNestedAppearsInFragment(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public var characterAppearsIn: CharacterAppearsIn {
      get {
        return CharacterAppearsIn(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }
  }
}

public struct CharacterNameWithNestedAppearsInFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment CharacterNameWithNestedAppearsInFragment on Character {
      __typename
      name
      ...CharacterAppearsIn
    }
    """

  public static let possibleTypes: [String] = ["Human", "Droid"]

  public static var selections: [Selection] { [
      .field("__typename", String.self),
      .field("name", String.self),
      .field("__typename", String.self),
      .field("appearsIn", .nonNull(.list(.scalar(Episode.self)))),
    ]
  }

  public static func makeHuman(name: String, appearsIn: [Episode?]) -> CharacterNameWithNestedAppearsInFragment {
    return CharacterNameWithNestedAppearsInFragment(unsafeResultMap: ["__typename": "Human", "name": name, "appearsIn": appearsIn])
  }

  public static func makeDroid(name: String, appearsIn: [Episode?]) -> CharacterNameWithNestedAppearsInFragment {
    return CharacterNameWithNestedAppearsInFragment(unsafeResultMap: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
  }

  public var __typename: String { data["__typename"] }

  /// The name of the character
  public var name: String { data["name"] }

  /// The movies this character appears in
  public var appearsIn: [Episode?] { data["appearsIn"] }

  public var fragments: Fragments {
    get {
      return Fragments(unsafeResultMap: resultMap)
    }
    set {
      resultMap += newValue.resultMap
    }
  }

  public struct Fragments {
    public var characterAppearsIn: CharacterAppearsIn {
      get {
        return CharacterAppearsIn(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }
  }
}

public struct CharacterNameWithInlineFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment CharacterNameWithInlineFragment on Character {
      __typename
      ... on Human {
        friends {
          __typename
          appearsIn
        }
      }
      ... on Droid {
        ...CharacterName
        ...FriendsNames
      }
    }
    """

  public static let possibleTypes: [String] = ["Human", "Droid"]

  public static var selections: [Selection] { [
      GraphQLTypeCase(
        variants: ["Human": AsHuman.selections, "Droid": AsDroid.selections],
        default: [
          .field("__typename", String.self),
        ]
      )
    ]
  }

  public static func makeHuman(friends: [AsHuman.Friend?]? = nil) -> CharacterNameWithInlineFragment {
    return CharacterNameWithInlineFragment(unsafeResultMap: ["__typename": "Human", "friends": friends.flatMap { (value: [AsHuman.Friend?]) -> [ResultMap?] in value.map { (value: AsHuman.Friend?) -> ResultMap? in value.flatMap { (value: AsHuman.Friend) -> ResultMap in value.resultMap } } }])
  }

  public static func makeDroid(name: String, friends: [AsDroid.Friend?]? = nil) -> CharacterNameWithInlineFragment {
    return CharacterNameWithInlineFragment(unsafeResultMap: ["__typename": "Droid", "name": name, "friends": friends.flatMap { (value: [AsDroid.Friend?]) -> [ResultMap?] in value.map { (value: AsDroid.Friend?) -> ResultMap? in value.flatMap { (value: AsDroid.Friend) -> ResultMap in value.resultMap } } }])
  }

  public var __typename: String { data["__typename"] }

  public var asHuman: AsHuman? {
    get {
      if !AsHuman.possibleTypes.contains(__typename) { return nil }
      return AsHuman(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsHuman: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Human"]

    public static var selections: [Selection] { [
        .field("__typename", String.self),
        .field("friends", [Friend?]?.self),
      ]
    }

    public init(friends: [Friend?]? = nil) {
      self.init(json: ["__typename": "Human", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
    }

    public var __typename: String { data["__typename"] }

    /// This human's friends, or an empty list if they have none
    public var friends: [Friend?]? {
      get {
        return (resultMap["friends"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Friend?] in value.map { (value: ResultMap?) -> Friend? in value.flatMap { (value: ResultMap) -> Friend in Friend(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }, forKey: "friends")
      }
    }

    public struct Friend: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("appearsIn", .nonNull(.list(.scalar(Episode.self)))),
        ]
      }

      public static func makeHuman(appearsIn: [Episode?]) -> Friend {
        return Friend(unsafeResultMap: ["__typename": "Human", "appearsIn": appearsIn])
      }

      public static func makeDroid(appearsIn: [Episode?]) -> Friend {
        return Friend(unsafeResultMap: ["__typename": "Droid", "appearsIn": appearsIn])
      }

      public var __typename: String { data["__typename"] }

      /// The movies this character appears in
      public var appearsIn: [Episode?] { data["appearsIn"] }

    }
  }

  public var asDroid: AsDroid? {
    get {
      if !AsDroid.possibleTypes.contains(__typename) { return nil }
      return AsDroid(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsDroid: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Droid"]

    public static var selections: [Selection] { [
        .field("__typename", String.self),
        .field("__typename", String.self),
        .field("name", String.self),
        .field("__typename", String.self),
        .field("friends", [Friend?]?.self),
      ]
    }

    public init(name: String, friends: [Friend?]? = nil) {
      self.init(json: ["__typename": "Droid", "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
    }

    public var __typename: String { data["__typename"] }

    /// What others call this droid
    public var name: String { data["name"] }

    /// This droid's friends, or an empty list if they have none
    public var friends: [Friend?]? {
      get {
        return (resultMap["friends"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Friend?] in value.map { (value: ResultMap?) -> Friend? in value.flatMap { (value: ResultMap) -> Friend in Friend(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }, forKey: "friends")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public var characterName: CharacterName {
        get {
          return CharacterName(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public var friendsNames: FriendsNames {
        get {
          return FriendsNames(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }

    public struct Friend: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
      public static let possibleTypes: [String] = ["Human", "Droid"]

      public static var selections: [Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
        ]
      }

      public static func makeHuman(name: String) -> Friend {
        return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Friend {
        return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String { data["__typename"] }

      /// The name of the character
      public var name: String { data["name"] }

    }
  }
}

public struct FriendsNames: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment FriendsNames on Character {
      __typename
      friends {
        __typename
        name
      }
    }
    """

  public static let possibleTypes: [String] = ["Human", "Droid"]

  public static var selections: [Selection] { [
      .field("__typename", String.self),
      .field("friends", [Friend?]?.self),
    ]
  }

  public static func makeHuman(friends: [Friend?]? = nil) -> FriendsNames {
    return FriendsNames(unsafeResultMap: ["__typename": "Human", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
  }

  public static func makeDroid(friends: [Friend?]? = nil) -> FriendsNames {
    return FriendsNames(unsafeResultMap: ["__typename": "Droid", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
  }

  public var __typename: String { data["__typename"] }

  /// The friends of the character, or an empty list if they have none
  public var friends: [Friend?]? {
    get {
      return (resultMap["friends"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Friend?] in value.map { (value: ResultMap?) -> Friend? in value.flatMap { (value: ResultMap) -> Friend in Friend(unsafeResultMap: value) } } }
    }
    set {
      resultMap.updateValue(newValue.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }, forKey: "friends")
    }
  }

  public struct Friend: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Human", "Droid"]

    public static var selections: [Selection] { [
        .field("__typename", String.self),
        .field("name", String.self),
      ]
    }

    public static func makeHuman(name: String) -> Friend {
      return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
    }

    public static func makeDroid(name: String) -> Friend {
      return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
    }

    public var __typename: String { data["__typename"] }

    /// The name of the character
    public var name: String { data["name"] }

  }
}

public struct CharacterAppearsIn: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment CharacterAppearsIn on Character {
      __typename
      appearsIn
    }
    """

  public static let possibleTypes: [String] = ["Human", "Droid"]

  public static var selections: [Selection] { [
      .field("__typename", String.self),
      .field("appearsIn", .nonNull(.list(.scalar(Episode.self)))),
    ]
  }

  public static func makeHuman(appearsIn: [Episode?]) -> CharacterAppearsIn {
    return CharacterAppearsIn(unsafeResultMap: ["__typename": "Human", "appearsIn": appearsIn])
  }

  public static func makeDroid(appearsIn: [Episode?]) -> CharacterAppearsIn {
    return CharacterAppearsIn(unsafeResultMap: ["__typename": "Droid", "appearsIn": appearsIn])
  }

  public var __typename: String { data["__typename"] }

  /// The movies this character appears in
  public var appearsIn: [Episode?] { data["appearsIn"] }

}

public struct HeroDetails: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment HeroDetails on Character {
      __typename
      name
      ... on Human {
        height
      }
      ... on Droid {
        primaryFunction
      }
    }
    """

  public static let possibleTypes: [String] = ["Human", "Droid"]

  public static var selections: [Selection] { [
      GraphQLTypeCase(
        variants: ["Human": AsHuman.selections, "Droid": AsDroid.selections],
        default: [
          .field("__typename", String.self),
          .field("name", String.self),
        ]
      )
    ]
  }

  public static func makeHuman(name: String, height: Double? = nil) -> HeroDetails {
    return HeroDetails(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
  }

  public static func makeDroid(name: String, primaryFunction: String? = nil) -> HeroDetails {
    return HeroDetails(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
  }

  public var __typename: String { data["__typename"] }

  /// The name of the character
  public var name: String { data["name"] }

  public var asHuman: AsHuman? {
    get {
      if !AsHuman.possibleTypes.contains(__typename) { return nil }
      return AsHuman(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsHuman: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Human"]

    public static var selections: [Selection] { [
        .field("__typename", String.self),
        .field("name", String.self),
        .field("height", .scalar(Double.self)),
      ]
    }

    public init(name: String, height: Double? = nil) {
      self.init(json: ["__typename": "Human", "name": name, "height": height])
    }

    public var __typename: String { data["__typename"] }

    /// What this human calls themselves
    public var name: String { data["name"] }

    /// Height in the preferred unit, default is meters
    public var height: Double? { data["height"] }

  }

  public var asDroid: AsDroid? {
    get {
      if !AsDroid.possibleTypes.contains(__typename) { return nil }
      return AsDroid(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsDroid: SelectionSet {
public let data: ResponseDict; public init(data: ResponseDict) { self.data = data }
    public static let possibleTypes: [String] = ["Droid"]

    public static var selections: [Selection] { [
        .field("__typename", String.self),
        .field("name", String.self),
        .field("primaryFunction", String?.self),
      ]
    }

    public init(name: String, primaryFunction: String? = nil) {
      self.init(json: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
    }

    public var __typename: String { data["__typename"] }

    /// What others call this droid
    public var name: String { data["name"] }

    /// This droid's primary function
    public var primaryFunction: String? {
      get {
        return resultMap["primaryFunction"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "primaryFunction")
      }
    }
  }
}

public struct DroidDetails: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment DroidDetails on Droid {
      __typename
      name
      primaryFunction
    }
    """

  public static let possibleTypes: [String] = ["Droid"]

  public static var selections: [Selection] { [
      .field("__typename", String.self),
      .field("name", String.self),
      .field("primaryFunction", String?.self),
    ]
  }

  public init(name: String, primaryFunction: String? = nil) {
    self.init(json: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
  }

  public var __typename: String { data["__typename"] }

  /// What others call this droid
  public var name: String { data["name"] }

  /// This droid's primary function
  public var primaryFunction: String? {
    get {
      return resultMap["primaryFunction"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "primaryFunction")
    }
  }
}

public struct CharacterName: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment CharacterName on Character {
      __typename
      name
    }
    """

  public static let possibleTypes: [String] = ["Human", "Droid"]

  public static var selections: [Selection] { [
      .field("__typename", String.self),
      .field("name", String.self),
    ]
  }

  public static func makeHuman(name: String) -> CharacterName {
    return CharacterName(unsafeResultMap: ["__typename": "Human", "name": name])
  }

  public static func makeDroid(name: String) -> CharacterName {
    return CharacterName(unsafeResultMap: ["__typename": "Droid", "name": name])
  }

  public var __typename: String { data["__typename"] }

  /// The name of the character
  public var name: String { data["name"] }

}

public struct CharacterNameAndAppearsIn: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment CharacterNameAndAppearsIn on Character {
      __typename
      name
      appearsIn
    }
    """

  public static let possibleTypes: [String] = ["Human", "Droid"]

  public static var selections: [Selection] { [
      .field("__typename", String.self),
      .field("name", String.self),
      .field("appearsIn", .nonNull(.list(.scalar(Episode.self)))),
    ]
  }

  public static func makeHuman(name: String, appearsIn: [Episode?]) -> CharacterNameAndAppearsIn {
    return CharacterNameAndAppearsIn(unsafeResultMap: ["__typename": "Human", "name": name, "appearsIn": appearsIn])
  }

  public static func makeDroid(name: String, appearsIn: [Episode?]) -> CharacterNameAndAppearsIn {
    return CharacterNameAndAppearsIn(unsafeResultMap: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
  }

  public var __typename: String { data["__typename"] }

  /// The name of the character
  public var name: String { data["name"] }

  /// The movies this character appears in
  public var appearsIn: [Episode?] { data["appearsIn"] }

}
