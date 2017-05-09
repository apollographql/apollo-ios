//  This file was automatically generated and should not be edited.

import Apollo

/// The episodes in the Star Wars trilogy
public enum Episode: String {
  case newhope = "NEWHOPE" /// Star Wars Episode IV: A New Hope, released in 1977.
  case empire = "EMPIRE" /// Star Wars Episode V: The Empire Strikes Back, released in 1980.
  case jedi = "JEDI" /// Star Wars Episode VI: Return of the Jedi, released in 1983.
}

extension Episode: JSONDecodable, JSONEncodable {}

/// The input object sent when someone is creating a new review
public struct ReviewInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(stars: Int, commentary: String? = nil, favoriteColor: ColorInput? = nil) {
    graphQLMap = ["stars": stars, "commentary": commentary, "favoriteColor": favoriteColor]
  }
}

/// The input object sent when passing in a color
public struct ColorInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(red: Int, green: Int, blue: Int) {
    graphQLMap = ["red": red, "green": green, "blue": blue]
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
    public static let selections: [Selection] = [
      Field("createReview", arguments: ["episode": Variable("episode"), "review": Variable("review")], type: .object(Data.CreateReview.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createReview: CreateReview? = nil) {
      self.snapshot = ["createReview": createReview]
    }

    public var createReview: CreateReview? {
      get {
        return CreateReview(snapshot: snapshot["createReview"]! as! Snapshot)
      }
      set {
        snapshot["createReview"] = newValue?.snapshot
      }
    }

    public struct CreateReview: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("stars", type: .nonNull(.scalar(Int.self))),
        Field("commentary", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String, stars: Int, commentary: String? = nil) {
        self.snapshot = ["__typename": __typename, "stars": stars, "commentary": commentary]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var stars: Int {
        get {
          return snapshot["stars"]! as! Int
        }
        set {
          snapshot["stars"] = newValue
        }
      }

      public var commentary: String? {
        get {
          return snapshot["commentary"]! as! String?
        }
        set {
          snapshot["commentary"] = newValue
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
    public static let selections: [Selection] = [
      Field("createReview", arguments: ["episode": "JEDI", "review": ["stars": 10, "commentary": "This is awesome!"]], type: .object(Data.CreateReview.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createReview: CreateReview? = nil) {
      self.snapshot = ["createReview": createReview]
    }

    public var createReview: CreateReview? {
      get {
        return CreateReview(snapshot: snapshot["createReview"]! as! Snapshot)
      }
      set {
        snapshot["createReview"] = newValue?.snapshot
      }
    }

    public struct CreateReview: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("stars", type: .nonNull(.scalar(Int.self))),
        Field("commentary", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String, stars: Int, commentary: String? = nil) {
        self.snapshot = ["__typename": __typename, "stars": stars, "commentary": commentary]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var stars: Int {
        get {
          return snapshot["stars"]! as! Int
        }
        set {
          snapshot["stars"] = newValue
        }
      }

      public var commentary: String? {
        get {
          return snapshot["commentary"]! as! String?
        }
        set {
          snapshot["commentary"] = newValue
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
    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.snapshot = ["hero": hero]
    }

    public var hero: Hero? {
      get {
        return Hero(snapshot: snapshot["hero"]! as! Snapshot)
      }
      set {
        snapshot["hero"] = newValue?.snapshot
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
        Field("friends", type: .list(.object(Hero.Friend.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String, name: String, friends: [Friend?]? = nil) {
        self.snapshot = ["__typename": __typename, "name": name, "friends": friends]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot["name"] = newValue
        }
      }

      public var friends: [Friend?]? {
        get {
          return (snapshot["friends"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Friend(snapshot: $0) } } }
        }
        set {
          snapshot["friends"] = newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }
        }
      }

      public struct Friend: GraphQLSelectionSet {
        public static let selections: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(__typename: String, name: String) {
          self.snapshot = ["__typename": __typename, "name": name]
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot["__typename"] = newValue
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot["name"] = newValue
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
    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.snapshot = ["hero": hero]
    }

    public var hero: Hero? {
      get {
        return Hero(snapshot: snapshot["hero"]! as! Snapshot)
      }
      set {
        snapshot["hero"] = newValue?.snapshot
      }
    }

    public struct Hero: GraphQLSelectionSet {
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

      public init(__typename: String, id: GraphQLID, name: String, friends: [Friend?]? = nil) {
        self.snapshot = ["__typename": __typename, "id": id, "name": name, "friends": friends]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot["id"] = newValue
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot["name"] = newValue
        }
      }

      public var friends: [Friend?]? {
        get {
          return (snapshot["friends"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Friend(snapshot: $0) } } }
        }
        set {
          snapshot["friends"] = newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }
        }
      }

      public struct Friend: GraphQLSelectionSet {
        public static let selections: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("id", type: .nonNull(.scalar(GraphQLID.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(__typename: String, id: GraphQLID, name: String) {
          self.snapshot = ["__typename": __typename, "id": id, "name": name]
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot["__typename"] = newValue
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot["id"] = newValue
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot["name"] = newValue
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
    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.snapshot = ["hero": hero]
    }

    public var hero: Hero? {
      get {
        return Hero(snapshot: snapshot["hero"]! as! Snapshot)
      }
      set {
        snapshot["hero"] = newValue?.snapshot
      }
    }

    public struct Hero: GraphQLSelectionSet {
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

      public init(__typename: String, id: GraphQLID, name: String, friends: [Friend?]? = nil) {
        self.snapshot = ["__typename": __typename, "id": id, "name": name, "friends": friends]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot["id"] = newValue
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot["name"] = newValue
        }
      }

      public var friends: [Friend?]? {
        get {
          return (snapshot["friends"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Friend(snapshot: $0) } } }
        }
        set {
          snapshot["friends"] = newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }
        }
      }

      public struct Friend: GraphQLSelectionSet {
        public static let selections: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(__typename: String, name: String) {
          self.snapshot = ["__typename": __typename, "name": name]
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot["__typename"] = newValue
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot["name"] = newValue
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
    "    friends {" +
    "      __typename" +
    "      name" +
    "    }" +
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
    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.snapshot = ["hero": hero]
    }

    public var hero: Hero? {
      get {
        return Hero(snapshot: snapshot["hero"]! as! Snapshot)
      }
      set {
        snapshot["hero"] = newValue?.snapshot
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
        Field("friends", type: .list(.object(Hero.Friend.self))),
        FragmentSpread(FriendsNames.self),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String, name: String, friends: [Friend?]? = nil) {
        self.snapshot = ["__typename": __typename, "name": name, "friends": friends]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot["name"] = newValue
        }
      }

      public var friends: [Friend?]? {
        get {
          return (snapshot["friends"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Friend(snapshot: $0) } } }
        }
        set {
          snapshot["friends"] = newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }
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
        public static let selections: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(__typename: String, name: String) {
          self.snapshot = ["__typename": __typename, "name": name]
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot["__typename"] = newValue
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot["name"] = newValue
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
    public static let selections: [Selection] = [
      Field("hero", type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.snapshot = ["hero": hero]
    }

    public var hero: Hero? {
      get {
        return Hero(snapshot: snapshot["hero"]! as! Snapshot)
      }
      set {
        snapshot["hero"] = newValue?.snapshot
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String, appearsIn: [Episode?]) {
        self.snapshot = ["__typename": __typename, "appearsIn": appearsIn]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var appearsIn: [Episode?] {
        get {
          return snapshot["appearsIn"]! as! [Episode?]
        }
        set {
          snapshot["appearsIn"] = newValue
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
    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.snapshot = ["hero": hero]
    }

    public var hero: Hero? {
      get {
        return Hero(snapshot: snapshot["hero"]! as! Snapshot)
      }
      set {
        snapshot["hero"] = newValue?.snapshot
      }
    }

    public struct Hero: GraphQLSelectionSet {
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

      public init(__typename: String, name: String) {
        self.snapshot = ["__typename": __typename, "name": name]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot["name"] = newValue
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

        public init(__typename: String, name: String, height: Double? = nil) {
          self.snapshot = ["__typename": __typename, "name": name, "height": height]
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot["__typename"] = newValue
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot["name"] = newValue
          }
        }

        public var height: Double? {
          get {
            return snapshot["height"]! as! Double?
          }
          set {
            snapshot["height"] = newValue
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

        public init(__typename: String, name: String, primaryFunction: String? = nil) {
          self.snapshot = ["__typename": __typename, "name": name, "primaryFunction": primaryFunction]
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot["__typename"] = newValue
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot["name"] = newValue
          }
        }

        public var primaryFunction: String? {
          get {
            return snapshot["primaryFunction"]! as! String?
          }
          set {
            snapshot["primaryFunction"] = newValue
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
    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.snapshot = ["hero": hero]
    }

    public var hero: Hero? {
      get {
        return Hero(snapshot: snapshot["hero"]! as! Snapshot)
      }
      set {
        snapshot["hero"] = newValue?.snapshot
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        FragmentSpread(HeroDetails.self),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String) {
        self.snapshot = ["__typename": __typename]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
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
    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.snapshot = ["hero": hero]
    }

    public var hero: Hero? {
      get {
        return Hero(snapshot: snapshot["hero"]! as! Snapshot)
      }
      set {
        snapshot["hero"] = newValue?.snapshot
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String, name: String) {
        self.snapshot = ["__typename": __typename, "name": name]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot["name"] = newValue
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
    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.snapshot = ["hero": hero]
    }

    public var hero: Hero? {
      get {
        return Hero(snapshot: snapshot["hero"]! as! Snapshot)
      }
      set {
        snapshot["hero"] = newValue?.snapshot
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("id", type: .nonNull(.scalar(GraphQLID.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String, id: GraphQLID, name: String) {
        self.snapshot = ["__typename": __typename, "id": id, "name": name]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot["id"] = newValue
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot["name"] = newValue
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
    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.snapshot = ["hero": hero]
    }

    public var hero: Hero? {
      get {
        return Hero(snapshot: snapshot["hero"]! as! Snapshot)
      }
      set {
        snapshot["hero"] = newValue?.snapshot
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String, name: String? = nil) {
        self.snapshot = ["__typename": __typename, "name": name]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var name: String? {
        get {
          return snapshot["name"]! as! String?
        }
        set {
          snapshot["name"] = newValue
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
    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.snapshot = ["hero": hero]
    }

    public var hero: Hero? {
      get {
        return Hero(snapshot: snapshot["hero"]! as! Snapshot)
      }
      set {
        snapshot["hero"] = newValue?.snapshot
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String, name: String? = nil) {
        self.snapshot = ["__typename": __typename, "name": name]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var name: String? {
        get {
          return snapshot["name"]! as! String?
        }
        set {
          snapshot["name"] = newValue
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
    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.snapshot = ["hero": hero]
    }

    public var hero: Hero? {
      get {
        return Hero(snapshot: snapshot["hero"]! as! Snapshot)
      }
      set {
        snapshot["hero"] = newValue?.snapshot
      }
    }

    public struct Hero: GraphQLSelectionSet {
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

      public init(__typename: String, name: String) {
        self.snapshot = ["__typename": __typename, "name": name]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot["name"] = newValue
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

        public init(__typename: String, name: String, friends: [Friend?]? = nil) {
          self.snapshot = ["__typename": __typename, "name": name, "friends": friends]
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot["__typename"] = newValue
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot["name"] = newValue
          }
        }

        public var friends: [Friend?]? {
          get {
            return (snapshot["friends"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Friend(snapshot: $0) } } }
          }
          set {
            snapshot["friends"] = newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }
          }
        }

        public struct Friend: GraphQLSelectionSet {
          public static let selections: [Selection] = [
            Field("__typename", type: .nonNull(.scalar(String.self))),
            Field("name", type: .nonNull(.scalar(String.self))),
            FragmentSpread(Friend.AsHuman.self),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(__typename: String, name: String) {
            self.snapshot = ["__typename": __typename, "name": name]
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot["__typename"] = newValue
            }
          }

          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot["name"] = newValue
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

            public init(__typename: String, name: String, height: Double? = nil) {
              self.snapshot = ["__typename": __typename, "name": name, "height": height]
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot["__typename"] = newValue
              }
            }

            public var name: String {
              get {
                return snapshot["name"]! as! String
              }
              set {
                snapshot["name"] = newValue
              }
            }

            public var height: Double? {
              get {
                return snapshot["height"]! as! Double?
              }
              set {
                snapshot["height"] = newValue
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

        public init(__typename: String, name: String, friends: [Friend?]? = nil) {
          self.snapshot = ["__typename": __typename, "name": name, "friends": friends]
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot["__typename"] = newValue
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot["name"] = newValue
          }
        }

        public var friends: [Friend?]? {
          get {
            return (snapshot["friends"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Friend(snapshot: $0) } } }
          }
          set {
            snapshot["friends"] = newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }
          }
        }

        public struct Friend: GraphQLSelectionSet {
          public static let selections: [Selection] = [
            Field("__typename", type: .nonNull(.scalar(String.self))),
            Field("name", type: .nonNull(.scalar(String.self))),
            FragmentSpread(Friend.AsHuman.self),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(__typename: String, name: String) {
            self.snapshot = ["__typename": __typename, "name": name]
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot["__typename"] = newValue
            }
          }

          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot["name"] = newValue
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

            public init(__typename: String, name: String, height: Double? = nil) {
              self.snapshot = ["__typename": __typename, "name": name, "height": height]
            }

            public var __typename: String {
              get {
                return snapshot["__typename"]! as! String
              }
              set {
                snapshot["__typename"] = newValue
              }
            }

            public var name: String {
              get {
                return snapshot["name"]! as! String
              }
              set {
                snapshot["name"] = newValue
              }
            }

            public var height: Double? {
              get {
                return snapshot["height"]! as! Double?
              }
              set {
                snapshot["height"] = newValue
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
    public static let selections: [Selection] = [
      Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil) {
      self.snapshot = ["hero": hero]
    }

    public var hero: Hero? {
      get {
        return Hero(snapshot: snapshot["hero"]! as! Snapshot)
      }
      set {
        snapshot["hero"] = newValue?.snapshot
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        FragmentSpread(Hero.AsHuman.self),
        FragmentSpread(Hero.AsDroid.self),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String) {
        self.snapshot = ["__typename": __typename]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
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

        public init(__typename: String, property: String? = nil) {
          self.snapshot = ["__typename": __typename, "property": property]
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot["__typename"] = newValue
          }
        }

        public var property: String? {
          get {
            return snapshot["property"]! as! String?
          }
          set {
            snapshot["property"] = newValue
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

        public init(__typename: String, property: String? = nil) {
          self.snapshot = ["__typename": __typename, "property": property]
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot["__typename"] = newValue
          }
        }

        public var property: String? {
          get {
            return snapshot["property"]! as! String?
          }
          set {
            snapshot["property"] = newValue
          }
        }
      }
    }
  }
}


public final class HumanWithNullMassQuery: GraphQLQuery {
  public static let operationString =
    "query HumanWithNullMass {" +
    "  human(id: 1004) {" +
    "    __typename" +
    "    name" +
    "    mass" +
    "  }" +
    "}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let selections: [Selection] = [
      Field("human", arguments: ["id": 1004], type: .object(Data.Human.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(human: Human? = nil) {
      self.snapshot = ["human": human]
    }

    public var human: Human? {
      get {
        return Human(snapshot: snapshot["human"]! as! Snapshot)
      }
      set {
        snapshot["human"] = newValue?.snapshot
      }
    }

    public struct Human: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
        Field("mass", type: .scalar(Double.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String, name: String, mass: Double? = nil) {
        self.snapshot = ["__typename": __typename, "name": name, "mass": mass]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot["name"] = newValue
        }
      }

      public var mass: Double? {
        get {
          return snapshot["mass"]! as! Double?
        }
        set {
          snapshot["mass"] = newValue
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
    public static let selections: [Selection] = [
      Field("hero", type: .object(Data.Hero.self)),
      Field("hero", alias: "r2", type: .object(Data.R2.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(hero: Hero? = nil, r2: R2? = nil) {
      self.snapshot = ["hero": hero, "r2": r2]
    }

    public var hero: Hero? {
      get {
        return Hero(snapshot: snapshot["hero"]! as! Snapshot)
      }
      set {
        snapshot["hero"] = newValue?.snapshot
      }
    }

    public var r2: R2? {
      get {
        return R2(snapshot: snapshot["r2"]! as! Snapshot)
      }
      set {
        snapshot["r2"] = newValue?.snapshot
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String, name: String) {
        self.snapshot = ["__typename": __typename, "name": name]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot["name"] = newValue
        }
      }
    }

    public struct R2: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String, appearsIn: [Episode?]) {
        self.snapshot = ["__typename": __typename, "appearsIn": appearsIn]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var appearsIn: [Episode?] {
        get {
          return snapshot["appearsIn"]! as! [Episode?]
        }
        set {
          snapshot["appearsIn"] = newValue
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
    public static let selections: [Selection] = [
      Field("starship", arguments: ["id": 3000], type: .object(Data.Starship.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(starship: Starship? = nil) {
      self.snapshot = ["starship": starship]
    }

    public var starship: Starship? {
      get {
        return Starship(snapshot: snapshot["starship"]! as! Snapshot)
      }
      set {
        snapshot["starship"] = newValue?.snapshot
      }
    }

    public struct Starship: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
        Field("coordinates", type: .list(.nonNull(.list(.nonNull(.scalar(Double.self)))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String, name: String, coordinates: [[Double]]? = nil) {
        self.snapshot = ["__typename": __typename, "name": name, "coordinates": coordinates]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot["name"] = newValue
        }
      }

      public var coordinates: [[Double]]? {
        get {
          return snapshot["coordinates"]! as! [[Double]]?
        }
        set {
          snapshot["coordinates"] = newValue
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
    public static let selections: [Selection] = [
      Field("hero", alias: "r2", type: .object(Data.R2.self)),
      Field("hero", alias: "luke", arguments: ["episode": "EMPIRE"], type: .object(Data.Luke.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(r2: R2? = nil, luke: Luke? = nil) {
      self.snapshot = ["r2": r2, "luke": luke]
    }

    public var r2: R2? {
      get {
        return R2(snapshot: snapshot["r2"]! as! Snapshot)
      }
      set {
        snapshot["r2"] = newValue?.snapshot
      }
    }

    public var luke: Luke? {
      get {
        return Luke(snapshot: snapshot["luke"]! as! Snapshot)
      }
      set {
        snapshot["luke"] = newValue?.snapshot
      }
    }

    public struct R2: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String, name: String) {
        self.snapshot = ["__typename": __typename, "name": name]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot["name"] = newValue
        }
      }
    }

    public struct Luke: GraphQLSelectionSet {
      public static let selections: [Selection] = [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(__typename: String, name: String) {
        self.snapshot = ["__typename": __typename, "name": name]
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot["__typename"] = newValue
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot["name"] = newValue
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

  public init(__typename: String, friends: [Friend?]? = nil) {
    self.snapshot = ["__typename": __typename, "friends": friends]
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot["__typename"] = newValue
    }
  }

  public var friends: [Friend?]? {
    get {
      return (snapshot["friends"]! as! [Snapshot?]?).flatMap { $0.map { $0.flatMap { Friend(snapshot: $0) } } }
    }
    set {
      snapshot["friends"] = newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }
    }
  }

  public struct Friend: GraphQLSelectionSet {
    public static let selections: [Selection] = [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(__typename: String, name: String) {
      self.snapshot = ["__typename": __typename, "name": name]
    }

    public var __typename: String {
      get {
        return snapshot["__typename"]! as! String
      }
      set {
        snapshot["__typename"] = newValue
      }
    }

    public var name: String {
      get {
        return snapshot["name"]! as! String
      }
      set {
        snapshot["name"] = newValue
      }
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

  public init(__typename: String, name: String) {
    self.snapshot = ["__typename": __typename, "name": name]
  }

  public var __typename: String {
    get {
      return snapshot["__typename"]! as! String
    }
    set {
      snapshot["__typename"] = newValue
    }
  }

  public var name: String {
    get {
      return snapshot["name"]! as! String
    }
    set {
      snapshot["name"] = newValue
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

    public init(__typename: String, name: String, height: Double? = nil) {
      self.snapshot = ["__typename": __typename, "name": name, "height": height]
    }

    public var __typename: String {
      get {
        return snapshot["__typename"]! as! String
      }
      set {
        snapshot["__typename"] = newValue
      }
    }

    public var name: String {
      get {
        return snapshot["name"]! as! String
      }
      set {
        snapshot["name"] = newValue
      }
    }

    public var height: Double? {
      get {
        return snapshot["height"]! as! Double?
      }
      set {
        snapshot["height"] = newValue
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

    public init(__typename: String, name: String, primaryFunction: String? = nil) {
      self.snapshot = ["__typename": __typename, "name": name, "primaryFunction": primaryFunction]
    }

    public var __typename: String {
      get {
        return snapshot["__typename"]! as! String
      }
      set {
        snapshot["__typename"] = newValue
      }
    }

    public var name: String {
      get {
        return snapshot["name"]! as! String
      }
      set {
        snapshot["name"] = newValue
      }
    }

    public var primaryFunction: String? {
      get {
        return snapshot["primaryFunction"]! as! String?
      }
      set {
        snapshot["primaryFunction"] = newValue
      }
    }
  }
}