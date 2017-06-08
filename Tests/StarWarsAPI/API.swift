//  This file was automatically generated and should not be edited.

import Apollo

/// The episodes in the Star Wars trilogy
public enum Episode: String {
  case newhope = "NEWHOPE" /// Star Wars Episode IV: A New Hope, released in 1977.
  case empire = "EMPIRE" /// Star Wars Episode V: The Empire Strikes Back, released in 1980.
  case jedi = "JEDI" /// Star Wars Episode VI: Return of the Jedi, released in 1983.
}

extension Episode: Apollo.JSONDecodable, Apollo.JSONEncodable {}

/// The input object sent when someone is creating a new review
public struct ReviewInput: GraphQLMapConvertible {
  /// 0-5 stars
  public var stars: Int
  /// Comment about the movie, optional
  public var commentary: Optional<String?>
  /// Favorite color, optional
  public var favoriteColor: Optional<ColorInput?>

  public init(stars: Int, commentary: Optional<String?> = nil, favoriteColor: Optional<ColorInput?> = nil) {
    self.stars = stars
    self.commentary = commentary
    self.favoriteColor = favoriteColor
  }

  public var graphQLMap: GraphQLMap {
    return ["stars": stars, "commentary": commentary, "favoriteColor": favoriteColor]
  }
}

/// The input object sent when passing in a color
public struct ColorInput: GraphQLMapConvertible {
  public var red: Int
  public var green: Int
  public var blue: Int

  public init(red: Int, green: Int, blue: Int) {
    self.red = red
    self.green = green
    self.blue = blue
  }

  public var graphQLMap: GraphQLMap {
    return ["red": red, "green": green, "blue": blue]
  }
}

public final class CreateReviewForEpisodeMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateReviewForEpisode($episode: Episode!, $review: ReviewInput!) {" +
    "  createReview(episode: $episode, review: $review) {" +
    "    __typename" +
    "    stars" +
    "    commentary" +
    "  }" +
    "}"

  public var episode: Episode
  public var review: ReviewInput

  public init(episode: Episode, review: ReviewInput) {
    self.episode = episode
    self.review = review
  }

  public var variables: GraphQLMap? {
    return ["episode": episode, "review": review]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [Selection] = [
      Field("createReview", arguments: ["episode": Variable("episode"), "review": Variable("review")], type: .object(Data.CreateReview.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createReview: CreateReview? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createReview": createReview])
    }

    public var createReview: CreateReview? {
      get {
        return (snapshot["createReview"]! as! Snapshot?).flatMap { CreateReview(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createReview")
      }
    }

    public struct CreateReview: GraphQLSelectionSet {
      public static let possibleTypes = ["Review"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("stars", type: .nonNull(.scalar(Int.self))),
        Field("commentary", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(stars: Int, commentary: String? = nil) {
        self.init(snapshot: ["__typename": "Review", "stars": stars, "commentary": commentary])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The number of stars this review gave, 1-5
      public var stars: Int {
        get {
          return snapshot["stars"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "stars")
        }
      }

      /// Comment about the movie
      public var commentary: String? {
        get {
          return snapshot["commentary"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "commentary")
        }
      }
    }
  }
}

public final class CreateAwesomeReviewMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateAwesomeReview {" +
    "  createReview(episode: JEDI, review: {stars: 10, commentary: \"This is awesome!\"}) {" +
    "    __typename" +
    "    stars" +
    "    commentary" +
    "  }" +
    "}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [Selection] = [
      Field("createReview", arguments: ["episode": "JEDI", "review": ["stars": 10, "commentary": "This is awesome!"]], type: .object(Data.CreateReview.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createReview: CreateReview? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createReview": createReview])
    }

    public var createReview: CreateReview? {
      get {
        return (snapshot["createReview"]! as! Snapshot?).flatMap { CreateReview(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createReview")
      }
    }

    public struct CreateReview: GraphQLSelectionSet {
      public static let possibleTypes = ["Review"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("stars", type: .nonNull(.scalar(Int.self))),
        Field("commentary", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(stars: Int, commentary: String? = nil) {
        self.init(snapshot: ["__typename": "Review", "stars": stars, "commentary": commentary])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The number of stars this review gave, 1-5
      public var stars: Int {
        get {
          return snapshot["stars"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "stars")
        }
      }

      /// Comment about the movie
      public var commentary: String? {
        get {
          return snapshot["commentary"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "commentary")
        }
      }
    }
  }
}

public final class HeroAndFriendsNamesQuery: GraphQLQuery {
  public static let operationString =
    "query HeroAndFriendsNames($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    name" +
    "    friends {" +
    "      __typename" +
    "      name" +
    "    }" +
    "  }" +
    "}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
        Field("friends", type: .list(.object(Hero.Friend.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "name": name, "friends": friends])
      }

      public static func makeDroid(name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "name": name, "friends": friends])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? {
        get {
          return (snapshot["friends"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Friend(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "friends")
        }
      }

      public struct Friend: GraphQLSelectionSet {
        public static let possibleTypes = ["Human", "Droid"]

        public static let selections: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public static func makeHuman(name: String) -> Friend {
          return Friend(snapshot: ["__typename": "Human", "name": name])
        }

        public static func makeDroid(name: String) -> Friend {
          return Friend(snapshot: ["__typename": "Droid", "name": name])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The name of the character
        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }
      }
    }
  }
}

public final class HeroAndFriendsNamesWithIDsQuery: GraphQLQuery {
  public static let operationString =
    "query HeroAndFriendsNamesWithIDs($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    id" +
    "    name" +
    "    friends {" +
    "      __typename" +
    "      id" +
    "      name" +
    "    }" +
    "  }" +
    "}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("id", type: .nonNull(.scalar(GraphQLID.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
        Field("friends", type: .list(.object(Hero.Friend.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(id: GraphQLID, name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "id": id, "name": name, "friends": friends])
      }

      public static func makeDroid(id: GraphQLID, name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "id": id, "name": name, "friends": friends])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The ID of the character
      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? {
        get {
          return (snapshot["friends"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Friend(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "friends")
        }
      }

      public struct Friend: GraphQLSelectionSet {
        public static let possibleTypes = ["Human", "Droid"]

        public static let selections: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("id", type: .nonNull(.scalar(GraphQLID.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public static func makeHuman(id: GraphQLID, name: String) -> Friend {
          return Friend(snapshot: ["__typename": "Human", "id": id, "name": name])
        }

        public static func makeDroid(id: GraphQLID, name: String) -> Friend {
          return Friend(snapshot: ["__typename": "Droid", "id": id, "name": name])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The ID of the character
        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        /// The name of the character
        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }
      }
    }
  }
}

public final class HeroAndFriendsNamesWithIdForParentOnlyQuery: GraphQLQuery {
  public static let operationString =
    "query HeroAndFriendsNamesWithIDForParentOnly($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    id" +
    "    name" +
    "    friends {" +
    "      __typename" +
    "      name" +
    "    }" +
    "  }" +
    "}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("id", type: .nonNull(.scalar(GraphQLID.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
        Field("friends", type: .list(.object(Hero.Friend.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(id: GraphQLID, name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "id": id, "name": name, "friends": friends])
      }

      public static func makeDroid(id: GraphQLID, name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "id": id, "name": name, "friends": friends])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The ID of the character
      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? {
        get {
          return (snapshot["friends"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Friend(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "friends")
        }
      }

      public struct Friend: GraphQLSelectionSet {
        public static let possibleTypes = ["Human", "Droid"]

        public static let selections: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public static func makeHuman(name: String) -> Friend {
          return Friend(snapshot: ["__typename": "Human", "name": name])
        }

        public static func makeDroid(name: String) -> Friend {
          return Friend(snapshot: ["__typename": "Droid", "name": name])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The name of the character
        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }
      }
    }
  }
}

public final class HeroAndFriendsNamesWithFragmentQuery: GraphQLQuery {
  public static let operationString =
    "query HeroAndFriendsNamesWithFragment($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    name" +
    "    ...FriendsNames" +
    "  }" +
    "}"
  public static var requestString: String { return operationString.appending(FriendsNames.fragmentString) }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
        Field("friends", type: .list(.object(Hero.Friend.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "name": name, "friends": friends])
      }

      public static func makeDroid(name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "name": name, "friends": friends])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? {
        get {
          return (snapshot["friends"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Friend(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "friends")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot = newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var friendsNames: FriendsNames {
          get {
            return FriendsNames(snapshot: snapshot)
          }
          set {
            snapshot = newValue.snapshot
          }
        }
      }

      public struct Friend: GraphQLSelectionSet {
        public static let possibleTypes = ["Human", "Droid"]

        public static let selections: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public static func makeHuman(name: String) -> Friend {
          return Friend(snapshot: ["__typename": "Human", "name": name])
        }

        public static func makeDroid(name: String) -> Friend {
          return Friend(snapshot: ["__typename": "Droid", "name": name])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The name of the character
        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }
      }
    }
  }
}

public final class HeroAppearsInQuery: GraphQLQuery {
  public static let operationString =
    "query HeroAppearsIn {" +
    "  hero {" +
    "    __typename" +
    "    appearsIn" +
    "  }" +
    "}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(appearsIn: [Episode?]) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "appearsIn": appearsIn])
      }

      public static func makeDroid(appearsIn: [Episode?]) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "appearsIn": appearsIn])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The movies this character appears in
      public var appearsIn: [Episode?] {
        get {
          return snapshot["appearsIn"]! as! [Episode?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "appearsIn")
        }
      }
    }
  }
}

public final class HeroAppearsInWithFragmentQuery: GraphQLQuery {
  public static let operationString =
    "query HeroAppearsInWithFragment($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    ...CharacterAppearsIn" +
    "  }" +
    "}"
  public static var requestString: String { return operationString.appending(CharacterAppearsIn.fragmentString) }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(appearsIn: [Episode?]) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "appearsIn": appearsIn])
      }

      public static func makeDroid(appearsIn: [Episode?]) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "appearsIn": appearsIn])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The movies this character appears in
      public var appearsIn: [Episode?] {
        get {
          return snapshot["appearsIn"]! as! [Episode?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "appearsIn")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot = newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var characterAppearsIn: CharacterAppearsIn {
          get {
            return CharacterAppearsIn(snapshot: snapshot)
          }
          set {
            snapshot = newValue.snapshot
          }
        }
      }
    }
  }
}

public final class HeroDetailsQuery: GraphQLQuery {
  public static let operationString =
    "query HeroDetails($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    name" +
    "    ... on Human {" +
    "      __typename" +
    "      height" +
    "    }" +
    "    ... on Droid {" +
    "      __typename" +
    "      primaryFunction" +
    "    }" +
    "  }" +
    "}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
        FragmentSpread(Hero.AsHuman.self),
        FragmentSpread(Hero.AsDroid.self),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(name: String, height: Double? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "name": name, "height": height])
      }

      public static func makeDroid(name: String, primaryFunction: String? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var asHuman: AsHuman? {
        get {
          if !AsHuman.possibleTypes.contains(__typename) { return nil }
          return AsHuman(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public var asDroid: AsDroid? {
        get {
          if !AsDroid.possibleTypes.contains(__typename) { return nil }
          return AsDroid(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public struct AsHuman: GraphQLFragment {
        public static let possibleTypes = ["Human"]

        public static let selections: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
          Field("height", type: .scalar(Double.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, height: Double? = nil) {
          self.init(snapshot: ["__typename": "Human", "name": name, "height": height])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        /// What this human calls themselves
        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        /// Height in the preferred unit, default is meters
        public var height: Double? {
          get {
            return snapshot["height"]! as! Double?
          }
          set {
            snapshot.updateValue(newValue, forKey: "height")
          }
        }
      }

      public struct AsDroid: GraphQLFragment {
        public static let possibleTypes = ["Droid"]

        public static let selections: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
          Field("primaryFunction", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, primaryFunction: String? = nil) {
          self.init(snapshot: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        /// What others call this droid
        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        /// This droid's primary function
        public var primaryFunction: String? {
          get {
            return snapshot["primaryFunction"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "primaryFunction")
          }
        }
      }
    }
  }
}

public final class HeroDetailsWithFragmentQuery: GraphQLQuery {
  public static let operationString =
    "query HeroDetailsWithFragment($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    ...HeroDetails" +
    "  }" +
    "}"
  public static var requestString: String { return operationString.appending(HeroDetails.fragmentString) }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
        FragmentSpread(Hero.AsHuman.self),
        FragmentSpread(Hero.AsDroid.self),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(name: String, height: Double? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "name": name, "height": height])
      }

      public static func makeDroid(name: String, primaryFunction: String? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var asHuman: AsHuman? {
        get {
          if !AsHuman.possibleTypes.contains(__typename) { return nil }
          return AsHuman(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public var asDroid: AsDroid? {
        get {
          if !AsDroid.possibleTypes.contains(__typename) { return nil }
          return AsDroid(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot = newValue.snapshot
        }
      }

      public struct AsHuman: GraphQLFragment {
        public static let possibleTypes = ["Human"]

        public static let selections: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
          Field("height", type: .scalar(Double.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, height: Double? = nil) {
          self.init(snapshot: ["__typename": "Human", "name": name, "height": height])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        /// What this human calls themselves
        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        /// Height in the preferred unit, default is meters
        public var height: Double? {
          get {
            return snapshot["height"]! as! Double?
          }
          set {
            snapshot.updateValue(newValue, forKey: "height")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot = newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var heroDetails: HeroDetails {
            get {
              return HeroDetails(snapshot: snapshot)
            }
            set {
              snapshot = newValue.snapshot
            }
          }
        }
      }

      public struct AsDroid: GraphQLFragment {
        public static let possibleTypes = ["Droid"]

        public static let selections: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
          Field("primaryFunction", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, primaryFunction: String? = nil) {
          self.init(snapshot: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        /// What others call this droid
        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        /// This droid's primary function
        public var primaryFunction: String? {
          get {
            return snapshot["primaryFunction"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "primaryFunction")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(snapshot: snapshot)
          }
          set {
            snapshot = newValue.snapshot
          }
        }

        public struct Fragments {
          public var snapshot: Snapshot

          public var heroDetails: HeroDetails {
            get {
              return HeroDetails(snapshot: snapshot)
            }
            set {
              snapshot = newValue.snapshot
            }
          }
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var heroDetails: HeroDetails {
          get {
            return HeroDetails(snapshot: snapshot)
          }
          set {
            snapshot = newValue.snapshot
          }
        }
      }
    }
  }
}

public final class HeroNameQuery: GraphQLQuery {
  public static let operationString =
    "query HeroName($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    name" +
    "  }" +
    "}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(name: String) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}

public final class HeroNameWithIdQuery: GraphQLQuery {
  public static let operationString =
    "query HeroNameWithID($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    id" +
    "    name" +
    "  }" +
    "}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("id", type: .nonNull(.scalar(GraphQLID.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(id: GraphQLID, name: String) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "id": id, "name": name])
      }

      public static func makeDroid(id: GraphQLID, name: String) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "id": id, "name": name])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The ID of the character
      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}

public final class HeroNameWithFragmentQuery: GraphQLQuery {
  public static let operationString =
    "query HeroNameWithFragment($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    ...CharacterName" +
    "  }" +
    "}"
  public static var requestString: String { return operationString.appending(CharacterName.fragmentString) }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(name: String) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot = newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var characterName: CharacterName {
          get {
            return CharacterName(snapshot: snapshot)
          }
          set {
            snapshot = newValue.snapshot
          }
        }
      }
    }
  }
}

public final class HeroNameAndAppearsInWithFragmentQuery: GraphQLQuery {
  public static let operationString =
    "query HeroNameAndAppearsInWithFragment($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    ...CharacterNameAndAppearsIn" +
    "  }" +
    "}"
  public static var requestString: String { return operationString.appending(CharacterNameAndAppearsIn.fragmentString) }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
        Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(name: String, appearsIn: [Episode?]) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "name": name, "appearsIn": appearsIn])
      }

      public static func makeDroid(name: String, appearsIn: [Episode?]) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      /// The movies this character appears in
      public var appearsIn: [Episode?] {
        get {
          return snapshot["appearsIn"]! as! [Episode?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "appearsIn")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(snapshot: snapshot)
        }
        set {
          snapshot = newValue.snapshot
        }
      }

      public struct Fragments {
        public var snapshot: Snapshot

        public var characterNameAndAppearsIn: CharacterNameAndAppearsIn {
          get {
            return CharacterNameAndAppearsIn(snapshot: snapshot)
          }
          set {
            snapshot = newValue.snapshot
          }
        }
      }
    }
  }
}

public final class HeroNameConditionalInclusionQuery: GraphQLQuery {
  public static let operationString =
    "query HeroNameConditionalInclusion($episode: Episode, $includeName: Boolean!) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    name @include(if: $includeName)" +
    "  }" +
    "}"

  public var episode: Episode?
  public var includeName: Bool

  public init(episode: Episode? = nil, includeName: Bool) {
    self.episode = episode
    self.includeName = includeName
  }

  public var variables: GraphQLMap? {
    return ["episode": episode, "includeName": includeName]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(name: String? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String? {
        get {
          return snapshot["name"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}

public final class HeroNameConditionalExclusionQuery: GraphQLQuery {
  public static let operationString =
    "query HeroNameConditionalExclusion($episode: Episode, $skipName: Boolean!) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    name @skip(if: $skipName)" +
    "  }" +
    "}"

  public var episode: Episode?
  public var skipName: Bool

  public init(episode: Episode? = nil, skipName: Bool) {
    self.episode = episode
    self.skipName = skipName
  }

  public var variables: GraphQLMap? {
    return ["episode": episode, "skipName": skipName]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(name: String? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String? {
        get {
          return snapshot["name"]! as! String?
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}

public final class HeroParentTypeDependentFieldQuery: GraphQLQuery {
  public static let operationString =
    "query HeroParentTypeDependentField($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    name" +
    "    ... on Human {" +
    "      __typename" +
    "      friends {" +
    "        __typename" +
    "        name" +
    "        ... on Human {" +
    "          __typename" +
    "          height(unit: FOOT)" +
    "        }" +
    "      }" +
    "    }" +
    "    ... on Droid {" +
    "      __typename" +
    "      friends {" +
    "        __typename" +
    "        name" +
    "        ... on Human {" +
    "          __typename" +
    "          height(unit: METER)" +
    "        }" +
    "      }" +
    "    }" +
    "  }" +
    "}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
        FragmentSpread(Hero.AsHuman.self),
        FragmentSpread(Hero.AsDroid.self),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(name: String, friends: [AsHuman.Friend?]? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "name": name, "friends": friends])
      }

      public static func makeDroid(name: String, friends: [AsDroid.Friend?]? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "name": name, "friends": friends])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var asHuman: AsHuman? {
        get {
          if !AsHuman.possibleTypes.contains(__typename) { return nil }
          return AsHuman(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public var asDroid: AsDroid? {
        get {
          if !AsDroid.possibleTypes.contains(__typename) { return nil }
          return AsDroid(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public struct AsHuman: GraphQLFragment {
        public static let possibleTypes = ["Human"]

        public static let selections: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
          Field("friends", type: .list(.object(AsHuman.Friend.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, friends: [Friend?]? = nil) {
          self.init(snapshot: ["__typename": "Human", "name": name, "friends": friends])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        /// What this human calls themselves
        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        /// This human's friends, or an empty list if they have none
        public var friends: [Friend?]? {
          get {
            return (snapshot["friends"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Friend(snapshot: $0) } } }
          }
          set {
            snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "friends")
          }
        }

        public struct Friend: GraphQLSelectionSet {
          public static let possibleTypes = ["Human", "Droid"]

          public static let selections: [Selection] = [
            Field("__typename", type: .nonNull(.scalar(String.self))),
            Field("name", type: .nonNull(.scalar(String.self))),
            FragmentSpread(Friend.AsHuman.self),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public static func makeHuman(name: String, height: Double? = nil) -> Friend {
            return Friend(snapshot: ["__typename": "Human", "name": name, "height": height])
          }

          public static func makeDroid(name: String) -> Friend {
            return Friend(snapshot: ["__typename": "Droid", "name": name])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          /// The name of the character
          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "name")
            }
          }

          public var asHuman: AsHuman? {
            get {
              if !AsHuman.possibleTypes.contains(__typename) { return nil }
              return AsHuman(snapshot: snapshot)
            }
            set {
              guard let newValue = newValue else { return }
              snapshot = newValue.snapshot
            }
          }

          public struct AsHuman: GraphQLFragment {
            public static let possibleTypes = ["Human"]

            public static let selections: [Selection] = [
              Field("__typename", type: .nonNull(.scalar(String.self))),
              Field("name", type: .nonNull(.scalar(String.self))),
              Field("height", arguments: ["unit": "FOOT"], type: .scalar(Double.self)),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(name: String, height: Double? = nil) {
              self.init(snapshot: ["__typename": "Human", "name": name, "height": height])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            /// What this human calls themselves
            public var name: String {
              get {
                return snapshot["name"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "name")
              }
            }

            /// Height in the preferred unit, default is meters
            public var height: Double? {
              get {
                return snapshot["height"]! as! Double?
              }
              set {
                snapshot.updateValue(newValue, forKey: "height")
              }
            }
          }
        }
      }

      public struct AsDroid: GraphQLFragment {
        public static let possibleTypes = ["Droid"]

        public static let selections: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
          Field("friends", type: .list(.object(AsDroid.Friend.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, friends: [Friend?]? = nil) {
          self.init(snapshot: ["__typename": "Droid", "name": name, "friends": friends])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        /// What others call this droid
        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        /// This droid's friends, or an empty list if they have none
        public var friends: [Friend?]? {
          get {
            return (snapshot["friends"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Friend(snapshot: $0) } } }
          }
          set {
            snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "friends")
          }
        }

        public struct Friend: GraphQLSelectionSet {
          public static let possibleTypes = ["Human", "Droid"]

          public static let selections: [Selection] = [
            Field("__typename", type: .nonNull(.scalar(String.self))),
            Field("name", type: .nonNull(.scalar(String.self))),
            FragmentSpread(Friend.AsHuman.self),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public static func makeHuman(name: String, height: Double? = nil) -> Friend {
            return Friend(snapshot: ["__typename": "Human", "name": name, "height": height])
          }

          public static func makeDroid(name: String) -> Friend {
            return Friend(snapshot: ["__typename": "Droid", "name": name])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          /// The name of the character
          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "name")
            }
          }

          public var asHuman: AsHuman? {
            get {
              if !AsHuman.possibleTypes.contains(__typename) { return nil }
              return AsHuman(snapshot: snapshot)
            }
            set {
              guard let newValue = newValue else { return }
              snapshot = newValue.snapshot
            }
          }

          public struct AsHuman: GraphQLFragment {
            public static let possibleTypes = ["Human"]

            public static let selections: [Selection] = [
              Field("__typename", type: .nonNull(.scalar(String.self))),
              Field("name", type: .nonNull(.scalar(String.self))),
              Field("height", arguments: ["unit": "METER"], type: .scalar(Double.self)),
            ]

            public var snapshot: Snapshot

            public init(snapshot: Snapshot) {
              self.snapshot = snapshot
            }

            public init(name: String, height: Double? = nil) {
              self.init(snapshot: ["__typename": "Human", "name": name, "height": height])
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "__typename")
              }
            }

            /// What this human calls themselves
            public var name: String {
              get {
                return snapshot["name"]! as! String
              }
              set {
                snapshot.updateValue(newValue, forKey: "name")
              }
            }

            /// Height in the preferred unit, default is meters
            public var height: Double? {
              get {
                return snapshot["height"]! as! Double?
              }
              set {
                snapshot.updateValue(newValue, forKey: "height")
              }
            }
          }
        }
      }
    }
  }
}

public final class HeroTypeDependentAliasedFieldQuery: GraphQLQuery {
  public static let operationString =
    "query HeroTypeDependentAliasedField($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    ... on Human {" +
    "      __typename" +
    "      property: homePlanet" +
    "    }" +
    "    ... on Droid {" +
    "      __typename" +
    "      property: primaryFunction" +
    "    }" +
    "  }" +
    "}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        FragmentSpread(Hero.AsHuman.self),
        FragmentSpread(Hero.AsDroid.self),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(property: String? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "property": property])
      }

      public static func makeDroid(property: String? = nil) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "property": property])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var asHuman: AsHuman? {
        get {
          if !AsHuman.possibleTypes.contains(__typename) { return nil }
          return AsHuman(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public var asDroid: AsDroid? {
        get {
          if !AsDroid.possibleTypes.contains(__typename) { return nil }
          return AsDroid(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public struct AsHuman: GraphQLFragment {
        public static let possibleTypes = ["Human"]

        public static let selections: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("homePlanet", alias: "property", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(property: String? = nil) {
          self.init(snapshot: ["__typename": "Human", "property": property])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The home planet of the human, or null if unknown
        public var property: String? {
          get {
            return snapshot["property"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "property")
          }
        }
      }

      public struct AsDroid: GraphQLFragment {
        public static let possibleTypes = ["Droid"]

        public static let selections: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("primaryFunction", alias: "property", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(property: String? = nil) {
          self.init(snapshot: ["__typename": "Droid", "property": property])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        /// This droid's primary function
        public var property: String? {
          get {
            return snapshot["property"]! as! String?
          }
          set {
            snapshot.updateValue(newValue, forKey: "property")
          }
        }
      }
    }
  }
}

public final class HumanQuery: GraphQLQuery {
  public static let operationString =
    "query Human($id: ID!) {" +
    "  human(id: $id) {" +
    "    __typename" +
    "    name" +
    "    mass" +
    "  }" +
    "}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("human", arguments: ["id": Variable("id")], type: .object(Data.Human.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(human: Human? = nil) {
      self.init(snapshot: ["__typename": "Query", "human": human])
    }

    public var human: Human? {
      get {
        return (snapshot["human"]! as! Snapshot?).flatMap { Human(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "human")
      }
    }

    public struct Human: GraphQLSelectionSet {
      public static let possibleTypes = ["Human"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
        Field("mass", type: .scalar(Double.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(name: String, mass: Double? = nil) {
        self.init(snapshot: ["__typename": "Human", "name": name, "mass": mass])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// What this human calls themselves
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      /// Mass in kilograms, or null if unknown
      public var mass: Double? {
        get {
          return snapshot["mass"]! as! Double?
        }
        set {
          snapshot.updateValue(newValue, forKey: "mass")
        }
      }
    }
  }
}

public final class SameHeroTwiceQuery: GraphQLQuery {
  public static let operationString =
    "query SameHeroTwice {" +
    "  hero {" +
    "    __typename" +
    "    name" +
    "  }" +
    "  r2: hero {" +
    "    __typename" +
    "    appearsIn" +
    "  }" +
    "}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", type: .object(Data.Hero.self)),
      Field("hero", alias: "r2", type: .object(Data.R2.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil, r2: R2? = nil) {
      self.init(snapshot: ["__typename": "Query", "hero": hero, "r2": r2])
    }

    public var hero: Hero? {
      get {
        return (snapshot["hero"]! as! Snapshot?).flatMap { Hero(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "hero")
      }
    }

    public var r2: R2? {
      get {
        return (snapshot["r2"]! as! Snapshot?).flatMap { R2(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "r2")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(name: String) -> Hero {
        return Hero(snapshot: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Hero {
        return Hero(snapshot: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }
    }

    public struct R2: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(appearsIn: [Episode?]) -> R2 {
        return R2(snapshot: ["__typename": "Human", "appearsIn": appearsIn])
      }

      public static func makeDroid(appearsIn: [Episode?]) -> R2 {
        return R2(snapshot: ["__typename": "Droid", "appearsIn": appearsIn])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The movies this character appears in
      public var appearsIn: [Episode?] {
        get {
          return snapshot["appearsIn"]! as! [Episode?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "appearsIn")
        }
      }
    }
  }
}

public final class StarshipQuery: GraphQLQuery {
  public static let operationString =
    "query Starship {" +
    "  starship(id: 3000) {" +
    "    __typename" +
    "    name" +
    "    coordinates" +
    "  }" +
    "}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("starship", arguments: ["id": 3000], type: .object(Data.Starship.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(starship: Starship? = nil) {
      self.init(snapshot: ["__typename": "Query", "starship": starship])
    }

    public var starship: Starship? {
      get {
        return (snapshot["starship"]! as! Snapshot?).flatMap { Starship(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "starship")
      }
    }

    public struct Starship: GraphQLSelectionSet {
      public static let possibleTypes = ["Starship"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
        Field("coordinates", type: .list(.nonNull(.list(.nonNull(.scalar(Double.self)))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(name: String, coordinates: [[Double]]? = nil) {
        self.init(snapshot: ["__typename": "Starship", "name": name, "coordinates": coordinates])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the starship
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var coordinates: [[Double]]? {
        get {
          return snapshot["coordinates"]! as! [[Double]]?
        }
        set {
          snapshot.updateValue(newValue, forKey: "coordinates")
        }
      }
    }
  }
}

public final class TwoHeroesQuery: GraphQLQuery {
  public static let operationString =
    "query TwoHeroes {" +
    "  r2: hero {" +
    "    __typename" +
    "    name" +
    "  }" +
    "  luke: hero(episode: EMPIRE) {" +
    "    __typename" +
    "    name" +
    "  }" +
    "}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [Selection] = [
      Field("hero", alias: "r2", type: .object(Data.R2.self)),
      Field("hero", alias: "luke", arguments: ["episode": "EMPIRE"], type: .object(Data.Luke.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(r2: R2? = nil, luke: Luke? = nil) {
      self.init(snapshot: ["__typename": "Query", "r2": r2, "luke": luke])
    }

    public var r2: R2? {
      get {
        return (snapshot["r2"]! as! Snapshot?).flatMap { R2(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "r2")
      }
    }

    public var luke: Luke? {
      get {
        return (snapshot["luke"]! as! Snapshot?).flatMap { Luke(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "luke")
      }
    }

    public struct R2: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(name: String) -> R2 {
        return R2(snapshot: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> R2 {
        return R2(snapshot: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }
    }

    public struct Luke: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(name: String) -> Luke {
        return Luke(snapshot: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Luke {
        return Luke(snapshot: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}

public struct DroidNameAndPrimaryFunction: GraphQLFragment {
  public static let fragmentString =
    "fragment DroidNameAndPrimaryFunction on Droid {" +
    "  __typename" +
    "  ...CharacterName" +
    "  ...DroidPrimaryFunction" +
    "}"

  public static let possibleTypes = ["Droid"]

  public static let selections: [Selection] = [
    Field("__typename", type: .nonNull(.scalar(String.self))),
    Field("name", type: .nonNull(.scalar(String.self))),
    Field("primaryFunction", type: .scalar(String.self)),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(name: String, primaryFunction: String? = nil) {
    self.init(snapshot: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  /// What others call this droid
  public var name: String {
    get {
      return snapshot["name"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "name")
    }
  }

  /// This droid's primary function
  public var primaryFunction: String? {
    get {
      return snapshot["primaryFunction"]! as! String?
    }
    set {
      snapshot.updateValue(newValue, forKey: "primaryFunction")
    }
  }

  public var fragments: Fragments {
    get {
      return Fragments(snapshot: snapshot)
    }
    set {
      snapshot = newValue.snapshot
    }
  }

  public struct Fragments {
    public var snapshot: Snapshot

    public var characterName: CharacterName {
      get {
        return CharacterName(snapshot: snapshot)
      }
      set {
        snapshot = newValue.snapshot
      }
    }

    public var droidPrimaryFunction: DroidPrimaryFunction {
      get {
        return DroidPrimaryFunction(snapshot: snapshot)
      }
      set {
        snapshot = newValue.snapshot
      }
    }
  }
}

public struct CharacterNameAndDroidPrimaryFunction: GraphQLFragment {
  public static let fragmentString =
    "fragment CharacterNameAndDroidPrimaryFunction on Character {" +
    "  __typename" +
    "  ...CharacterName" +
    "  ...DroidPrimaryFunction" +
    "}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [Selection] = [
    Field("__typename", type: .nonNull(.scalar(String.self))),
    Field("name", type: .nonNull(.scalar(String.self))),
    FragmentSpread(CharacterNameAndDroidPrimaryFunction.AsDroid.self),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public static func makeHuman(name: String) -> CharacterNameAndDroidPrimaryFunction {
    return CharacterNameAndDroidPrimaryFunction(snapshot: ["__typename": "Human", "name": name])
  }

  public static func makeDroid(name: String, primaryFunction: String? = nil) -> CharacterNameAndDroidPrimaryFunction {
    return CharacterNameAndDroidPrimaryFunction(snapshot: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The name of the character
  public var name: String {
    get {
      return snapshot["name"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "name")
    }
  }

  public var asDroid: AsDroid? {
    get {
      if !AsDroid.possibleTypes.contains(__typename) { return nil }
      return AsDroid(snapshot: snapshot)
    }
    set {
      guard let newValue = newValue else { return }
      snapshot = newValue.snapshot
    }
  }

  public var fragments: Fragments {
    get {
      return Fragments(snapshot: snapshot)
    }
    set {
      snapshot = newValue.snapshot
    }
  }

  public struct AsDroid: GraphQLFragment {
    public static let possibleTypes = ["Droid"]

    public static let selections: [Selection] = [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
      Field("primaryFunction", type: .scalar(String.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(name: String, primaryFunction: String? = nil) {
      self.init(snapshot: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
    }

    public var __typename: String {
      get {
        return snapshot["__typename"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "__typename")
      }
    }

    /// What others call this droid
    public var name: String {
      get {
        return snapshot["name"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "name")
      }
    }

    /// This droid's primary function
    public var primaryFunction: String? {
      get {
        return snapshot["primaryFunction"]! as! String?
      }
      set {
        snapshot.updateValue(newValue, forKey: "primaryFunction")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(snapshot: snapshot)
      }
      set {
        snapshot = newValue.snapshot
      }
    }

    public struct Fragments {
      public var snapshot: Snapshot

      public var characterName: CharacterName {
        get {
          return CharacterName(snapshot: snapshot)
        }
        set {
          snapshot = newValue.snapshot
        }
      }

      public var droidPrimaryFunction: DroidPrimaryFunction {
        get {
          return DroidPrimaryFunction(snapshot: snapshot)
        }
        set {
          snapshot = newValue.snapshot
        }
      }
    }
  }

  public struct Fragments {
    public var snapshot: Snapshot

    public var characterName: CharacterName {
      get {
        return CharacterName(snapshot: snapshot)
      }
      set {
        snapshot = newValue.snapshot
      }
    }

    public var droidPrimaryFunction: DroidPrimaryFunction? {
      get {
        if !DroidPrimaryFunction.possibleTypes.contains(snapshot["__typename"]! as! String) { return nil }
        return DroidPrimaryFunction(snapshot: snapshot)
      }
      set {
        guard let newValue = newValue else { return }
        snapshot = newValue.snapshot
      }
    }
  }
}

public struct CharacterNameAndDroidAppearsIn: GraphQLFragment {
  public static let fragmentString =
    "fragment CharacterNameAndDroidAppearsIn on Character {" +
    "  __typename" +
    "  name" +
    "  ... on Droid {" +
    "    __typename" +
    "    appearsIn" +
    "  }" +
    "}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [Selection] = [
    Field("__typename", type: .nonNull(.scalar(String.self))),
    Field("name", type: .nonNull(.scalar(String.self))),
    FragmentSpread(CharacterNameAndDroidAppearsIn.AsDroid.self),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public static func makeHuman(name: String) -> CharacterNameAndDroidAppearsIn {
    return CharacterNameAndDroidAppearsIn(snapshot: ["__typename": "Human", "name": name])
  }

  public static func makeDroid(name: String, appearsIn: [Episode?]) -> CharacterNameAndDroidAppearsIn {
    return CharacterNameAndDroidAppearsIn(snapshot: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The name of the character
  public var name: String {
    get {
      return snapshot["name"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "name")
    }
  }

  public var asDroid: AsDroid? {
    get {
      if !AsDroid.possibleTypes.contains(__typename) { return nil }
      return AsDroid(snapshot: snapshot)
    }
    set {
      guard let newValue = newValue else { return }
      snapshot = newValue.snapshot
    }
  }

  public struct AsDroid: GraphQLFragment {
    public static let possibleTypes = ["Droid"]

    public static let selections: [Selection] = [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
      Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(name: String, appearsIn: [Episode?]) {
      self.init(snapshot: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
    }

    public var __typename: String {
      get {
        return snapshot["__typename"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "__typename")
      }
    }

    /// What others call this droid
    public var name: String {
      get {
        return snapshot["name"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "name")
      }
    }

    /// The movies this droid appears in
    public var appearsIn: [Episode?] {
      get {
        return snapshot["appearsIn"]! as! [Episode?]
      }
      set {
        snapshot.updateValue(newValue, forKey: "appearsIn")
      }
    }
  }
}

public struct DroidName: GraphQLFragment {
  public static let fragmentString =
    "fragment DroidName on Droid {" +
    "  __typename" +
    "  name" +
    "}"

  public static let possibleTypes = ["Droid"]

  public static let selections: [Selection] = [
    Field("__typename", type: .nonNull(.scalar(String.self))),
    Field("name", type: .nonNull(.scalar(String.self))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(name: String) {
    self.init(snapshot: ["__typename": "Droid", "name": name])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  /// What others call this droid
  public var name: String {
    get {
      return snapshot["name"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "name")
    }
  }
}

public struct DroidPrimaryFunction: GraphQLFragment {
  public static let fragmentString =
    "fragment DroidPrimaryFunction on Droid {" +
    "  __typename" +
    "  primaryFunction" +
    "}"

  public static let possibleTypes = ["Droid"]

  public static let selections: [Selection] = [
    Field("__typename", type: .nonNull(.scalar(String.self))),
    Field("primaryFunction", type: .scalar(String.self)),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(primaryFunction: String? = nil) {
    self.init(snapshot: ["__typename": "Droid", "primaryFunction": primaryFunction])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  /// This droid's primary function
  public var primaryFunction: String? {
    get {
      return snapshot["primaryFunction"]! as! String?
    }
    set {
      snapshot.updateValue(newValue, forKey: "primaryFunction")
    }
  }
}

public struct HumanHeightWithVariable: GraphQLFragment {
  public static let fragmentString =
    "fragment HumanHeightWithVariable on Human {" +
    "  __typename" +
    "  height(unit: $heightUnit)" +
    "}"

  public static let possibleTypes = ["Human"]

  public static let selections: [Selection] = [
    Field("__typename", type: .nonNull(.scalar(String.self))),
    Field("height", arguments: ["unit": Variable("heightUnit")], type: .scalar(Double.self)),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public init(height: Double? = nil) {
    self.init(snapshot: ["__typename": "Human", "height": height])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  /// Height in the preferred unit, default is meters
  public var height: Double? {
    get {
      return snapshot["height"]! as! Double?
    }
    set {
      snapshot.updateValue(newValue, forKey: "height")
    }
  }
}

public struct CharacterNameAndAppearsInWithNestedFragments: GraphQLFragment {
  public static let fragmentString =
    "fragment CharacterNameAndAppearsInWithNestedFragments on Character {" +
    "  __typename" +
    "  ...CharacterNameWithNestedAppearsInFragment" +
    "}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [Selection] = [
    Field("__typename", type: .nonNull(.scalar(String.self))),
    Field("name", type: .nonNull(.scalar(String.self))),
    Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public static func makeHuman(name: String, appearsIn: [Episode?]) -> CharacterNameAndAppearsInWithNestedFragments {
    return CharacterNameAndAppearsInWithNestedFragments(snapshot: ["__typename": "Human", "name": name, "appearsIn": appearsIn])
  }

  public static func makeDroid(name: String, appearsIn: [Episode?]) -> CharacterNameAndAppearsInWithNestedFragments {
    return CharacterNameAndAppearsInWithNestedFragments(snapshot: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The name of the character
  public var name: String {
    get {
      return snapshot["name"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "name")
    }
  }

  /// The movies this character appears in
  public var appearsIn: [Episode?] {
    get {
      return snapshot["appearsIn"]! as! [Episode?]
    }
    set {
      snapshot.updateValue(newValue, forKey: "appearsIn")
    }
  }

  public var fragments: Fragments {
    get {
      return Fragments(snapshot: snapshot)
    }
    set {
      snapshot = newValue.snapshot
    }
  }

  public struct Fragments {
    public var snapshot: Snapshot

    public var characterNameWithNestedAppearsInFragment: CharacterNameWithNestedAppearsInFragment {
      get {
        return CharacterNameWithNestedAppearsInFragment(snapshot: snapshot)
      }
      set {
        snapshot = newValue.snapshot
      }
    }

    public var characterAppearsIn: CharacterAppearsIn {
      get {
        return CharacterAppearsIn(snapshot: snapshot)
      }
      set {
        snapshot = newValue.snapshot
      }
    }
  }
}

public struct CharacterNameWithNestedAppearsInFragment: GraphQLFragment {
  public static let fragmentString =
    "fragment CharacterNameWithNestedAppearsInFragment on Character {" +
    "  __typename" +
    "  name" +
    "  ...CharacterAppearsIn" +
    "}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [Selection] = [
    Field("__typename", type: .nonNull(.scalar(String.self))),
    Field("name", type: .nonNull(.scalar(String.self))),
    Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public static func makeHuman(name: String, appearsIn: [Episode?]) -> CharacterNameWithNestedAppearsInFragment {
    return CharacterNameWithNestedAppearsInFragment(snapshot: ["__typename": "Human", "name": name, "appearsIn": appearsIn])
  }

  public static func makeDroid(name: String, appearsIn: [Episode?]) -> CharacterNameWithNestedAppearsInFragment {
    return CharacterNameWithNestedAppearsInFragment(snapshot: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The name of the character
  public var name: String {
    get {
      return snapshot["name"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "name")
    }
  }

  /// The movies this character appears in
  public var appearsIn: [Episode?] {
    get {
      return snapshot["appearsIn"]! as! [Episode?]
    }
    set {
      snapshot.updateValue(newValue, forKey: "appearsIn")
    }
  }

  public var fragments: Fragments {
    get {
      return Fragments(snapshot: snapshot)
    }
    set {
      snapshot = newValue.snapshot
    }
  }

  public struct Fragments {
    public var snapshot: Snapshot

    public var characterAppearsIn: CharacterAppearsIn {
      get {
        return CharacterAppearsIn(snapshot: snapshot)
      }
      set {
        snapshot = newValue.snapshot
      }
    }
  }
}

public struct CharacterNameWithInlineFragment: GraphQLFragment {
  public static let fragmentString =
    "fragment CharacterNameWithInlineFragment on Character {" +
    "  __typename" +
    "  ... on Human {" +
    "    __typename" +
    "    friends {" +
    "      __typename" +
    "      appearsIn" +
    "    }" +
    "  }" +
    "  ... on Droid {" +
    "    __typename" +
    "    ...CharacterName" +
    "    ...FriendsNames" +
    "  }" +
    "}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [Selection] = [
    Field("__typename", type: .nonNull(.scalar(String.self))),
    FragmentSpread(CharacterNameWithInlineFragment.AsHuman.self),
    FragmentSpread(CharacterNameWithInlineFragment.AsDroid.self),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public static func makeHuman(friends: [AsHuman.Friend?]? = nil) -> CharacterNameWithInlineFragment {
    return CharacterNameWithInlineFragment(snapshot: ["__typename": "Human", "friends": friends])
  }

  public static func makeDroid(friends: [AsDroid.Friend?]? = nil, name: String) -> CharacterNameWithInlineFragment {
    return CharacterNameWithInlineFragment(snapshot: ["__typename": "Droid", "friends": friends, "name": name])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  public var asHuman: AsHuman? {
    get {
      if !AsHuman.possibleTypes.contains(__typename) { return nil }
      return AsHuman(snapshot: snapshot)
    }
    set {
      guard let newValue = newValue else { return }
      snapshot = newValue.snapshot
    }
  }

  public var asDroid: AsDroid? {
    get {
      if !AsDroid.possibleTypes.contains(__typename) { return nil }
      return AsDroid(snapshot: snapshot)
    }
    set {
      guard let newValue = newValue else { return }
      snapshot = newValue.snapshot
    }
  }

  public struct AsHuman: GraphQLFragment {
    public static let possibleTypes = ["Human"]

    public static let selections: [Selection] = [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("friends", type: .list(.object(AsHuman.Friend.self))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(friends: [Friend?]? = nil) {
      self.init(snapshot: ["__typename": "Human", "friends": friends])
    }

    public var __typename: String {
      get {
        return snapshot["__typename"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "__typename")
      }
    }

    /// This human's friends, or an empty list if they have none
    public var friends: [Friend?]? {
      get {
        return (snapshot["friends"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Friend(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "friends")
      }
    }

    public struct Friend: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(appearsIn: [Episode?]) -> Friend {
        return Friend(snapshot: ["__typename": "Human", "appearsIn": appearsIn])
      }

      public static func makeDroid(appearsIn: [Episode?]) -> Friend {
        return Friend(snapshot: ["__typename": "Droid", "appearsIn": appearsIn])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The movies this character appears in
      public var appearsIn: [Episode?] {
        get {
          return snapshot["appearsIn"]! as! [Episode?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "appearsIn")
        }
      }
    }
  }

  public struct AsDroid: GraphQLFragment {
    public static let possibleTypes = ["Droid"]

    public static let selections: [Selection] = [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("friends", type: .list(.object(AsDroid.Friend.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(friends: [Friend?]? = nil, name: String) {
      self.init(snapshot: ["__typename": "Droid", "friends": friends, "name": name])
    }

    public var __typename: String {
      get {
        return snapshot["__typename"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "__typename")
      }
    }

    /// This droid's friends, or an empty list if they have none
    public var friends: [Friend?]? {
      get {
        return (snapshot["friends"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Friend(snapshot: $0) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "friends")
      }
    }

    /// What others call this droid
    public var name: String {
      get {
        return snapshot["name"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "name")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(snapshot: snapshot)
      }
      set {
        snapshot = newValue.snapshot
      }
    }

    public struct Fragments {
      public var snapshot: Snapshot

      public var characterName: CharacterName {
        get {
          return CharacterName(snapshot: snapshot)
        }
        set {
          snapshot = newValue.snapshot
        }
      }

      public var friendsNames: FriendsNames {
        get {
          return FriendsNames(snapshot: snapshot)
        }
        set {
          snapshot = newValue.snapshot
        }
      }
    }

    public struct Friend: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeHuman(name: String) -> Friend {
        return Friend(snapshot: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Friend {
        return Friend(snapshot: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}

public struct FriendsNames: GraphQLFragment {
  public static let fragmentString =
    "fragment FriendsNames on Character {" +
    "  __typename" +
    "  friends {" +
    "    __typename" +
    "    name" +
    "  }" +
    "}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [Selection] = [
    Field("__typename", type: .nonNull(.scalar(String.self))),
    Field("friends", type: .list(.object(FriendsNames.Friend.self))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public static func makeHuman(friends: [Friend?]? = nil) -> FriendsNames {
    return FriendsNames(snapshot: ["__typename": "Human", "friends": friends])
  }

  public static func makeDroid(friends: [Friend?]? = nil) -> FriendsNames {
    return FriendsNames(snapshot: ["__typename": "Droid", "friends": friends])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The friends of the character, or an empty list if they have none
  public var friends: [Friend?]? {
    get {
      return (snapshot["friends"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Friend(snapshot: $0) } } }
    }
    set {
      snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "friends")
    }
  }

  public struct Friend: GraphQLSelectionSet {
    public static let possibleTypes = ["Human", "Droid"]

    public static let selections: [Selection] = [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public static func makeHuman(name: String) -> Friend {
      return Friend(snapshot: ["__typename": "Human", "name": name])
    }

    public static func makeDroid(name: String) -> Friend {
      return Friend(snapshot: ["__typename": "Droid", "name": name])
    }

    public var __typename: String {
      get {
        return snapshot["__typename"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "__typename")
      }
    }

    /// The name of the character
    public var name: String {
      get {
        return snapshot["name"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "name")
      }
    }
  }
}

public struct CharacterAppearsIn: GraphQLFragment {
  public static let fragmentString =
    "fragment CharacterAppearsIn on Character {" +
    "  __typename" +
    "  appearsIn" +
    "}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [Selection] = [
    Field("__typename", type: .nonNull(.scalar(String.self))),
    Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public static func makeHuman(appearsIn: [Episode?]) -> CharacterAppearsIn {
    return CharacterAppearsIn(snapshot: ["__typename": "Human", "appearsIn": appearsIn])
  }

  public static func makeDroid(appearsIn: [Episode?]) -> CharacterAppearsIn {
    return CharacterAppearsIn(snapshot: ["__typename": "Droid", "appearsIn": appearsIn])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The movies this character appears in
  public var appearsIn: [Episode?] {
    get {
      return snapshot["appearsIn"]! as! [Episode?]
    }
    set {
      snapshot.updateValue(newValue, forKey: "appearsIn")
    }
  }
}

public struct HeroDetails: GraphQLFragment {
  public static let fragmentString =
    "fragment HeroDetails on Character {" +
    "  __typename" +
    "  name" +
    "  ... on Human {" +
    "    __typename" +
    "    height" +
    "  }" +
    "  ... on Droid {" +
    "    __typename" +
    "    primaryFunction" +
    "  }" +
    "}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [Selection] = [
    Field("__typename", type: .nonNull(.scalar(String.self))),
    Field("name", type: .nonNull(.scalar(String.self))),
    FragmentSpread(HeroDetails.AsHuman.self),
    FragmentSpread(HeroDetails.AsDroid.self),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public static func makeHuman(name: String, height: Double? = nil) -> HeroDetails {
    return HeroDetails(snapshot: ["__typename": "Human", "name": name, "height": height])
  }

  public static func makeDroid(name: String, primaryFunction: String? = nil) -> HeroDetails {
    return HeroDetails(snapshot: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The name of the character
  public var name: String {
    get {
      return snapshot["name"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "name")
    }
  }

  public var asHuman: AsHuman? {
    get {
      if !AsHuman.possibleTypes.contains(__typename) { return nil }
      return AsHuman(snapshot: snapshot)
    }
    set {
      guard let newValue = newValue else { return }
      snapshot = newValue.snapshot
    }
  }

  public var asDroid: AsDroid? {
    get {
      if !AsDroid.possibleTypes.contains(__typename) { return nil }
      return AsDroid(snapshot: snapshot)
    }
    set {
      guard let newValue = newValue else { return }
      snapshot = newValue.snapshot
    }
  }

  public struct AsHuman: GraphQLFragment {
    public static let possibleTypes = ["Human"]

    public static let selections: [Selection] = [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
      Field("height", type: .scalar(Double.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(name: String, height: Double? = nil) {
      self.init(snapshot: ["__typename": "Human", "name": name, "height": height])
    }

    public var __typename: String {
      get {
        return snapshot["__typename"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "__typename")
      }
    }

    /// What this human calls themselves
    public var name: String {
      get {
        return snapshot["name"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "name")
      }
    }

    /// Height in the preferred unit, default is meters
    public var height: Double? {
      get {
        return snapshot["height"]! as! Double?
      }
      set {
        snapshot.updateValue(newValue, forKey: "height")
      }
    }
  }

  public struct AsDroid: GraphQLFragment {
    public static let possibleTypes = ["Droid"]

    public static let selections: [Selection] = [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
      Field("primaryFunction", type: .scalar(String.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(name: String, primaryFunction: String? = nil) {
      self.init(snapshot: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
    }

    public var __typename: String {
      get {
        return snapshot["__typename"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "__typename")
      }
    }

    /// What others call this droid
    public var name: String {
      get {
        return snapshot["name"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "name")
      }
    }

    /// This droid's primary function
    public var primaryFunction: String? {
      get {
        return snapshot["primaryFunction"]! as! String?
      }
      set {
        snapshot.updateValue(newValue, forKey: "primaryFunction")
      }
    }
  }
}

public struct CharacterName: GraphQLFragment {
  public static let fragmentString =
    "fragment CharacterName on Character {" +
    "  __typename" +
    "  name" +
    "}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [Selection] = [
    Field("__typename", type: .nonNull(.scalar(String.self))),
    Field("name", type: .nonNull(.scalar(String.self))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public static func makeHuman(name: String) -> CharacterName {
    return CharacterName(snapshot: ["__typename": "Human", "name": name])
  }

  public static func makeDroid(name: String) -> CharacterName {
    return CharacterName(snapshot: ["__typename": "Droid", "name": name])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The name of the character
  public var name: String {
    get {
      return snapshot["name"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "name")
    }
  }
}

public struct CharacterNameAndAppearsIn: GraphQLFragment {
  public static let fragmentString =
    "fragment CharacterNameAndAppearsIn on Character {" +
    "  __typename" +
    "  name" +
    "  appearsIn" +
    "}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [Selection] = [
    Field("__typename", type: .nonNull(.scalar(String.self))),
    Field("name", type: .nonNull(.scalar(String.self))),
    Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
  ]

  public var snapshot: Snapshot

  public init(snapshot: Snapshot) {
    self.snapshot = snapshot
  }

  public static func makeHuman(name: String, appearsIn: [Episode?]) -> CharacterNameAndAppearsIn {
    return CharacterNameAndAppearsIn(snapshot: ["__typename": "Human", "name": name, "appearsIn": appearsIn])
  }

  public static func makeDroid(name: String, appearsIn: [Episode?]) -> CharacterNameAndAppearsIn {
    return CharacterNameAndAppearsIn(snapshot: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The name of the character
  public var name: String {
    get {
      return snapshot["name"]! as! String
    }
    set {
      snapshot.updateValue(newValue, forKey: "name")
    }
  }

  /// The movies this character appears in
  public var appearsIn: [Episode?] {
    get {
      return snapshot["appearsIn"]! as! [Episode?]
    }
    set {
      snapshot.updateValue(newValue, forKey: "appearsIn")
    }
  }
}