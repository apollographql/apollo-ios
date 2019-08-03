//  This file was automatically generated and should not be edited.

import Apollo

/// The episodes in the Star Wars trilogy
public enum Episode: RawRepresentable, Equatable, Hashable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Star Wars Episode IV: A New Hope, released in 1977.
  case newhope
  /// Star Wars Episode V: The Empire Strikes Back, released in 1980.
  case empire
  /// Star Wars Episode VI: Return of the Jedi, released in 1983.
  case jedi
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "NEWHOPE": self = .newhope
      case "EMPIRE": self = .empire
      case "JEDI": self = .jedi
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .newhope: return "NEWHOPE"
      case .empire: return "EMPIRE"
      case .jedi: return "JEDI"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: Episode, rhs: Episode) -> Bool {
    switch (lhs, rhs) {
      case (.newhope, .newhope): return true
      case (.empire, .empire): return true
      case (.jedi, .jedi): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

/// The input object sent when someone is creating a new review
public struct ReviewInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(stars: Int, commentary: Swift.Optional<String?> = nil, favoriteColor: Swift.Optional<ColorInput?> = nil) {
    graphQLMap = ["stars": stars, "commentary": commentary, "favorite_color": favoriteColor]
  }

  /// 0-5 stars
  public var stars: Int {
    get {
      return graphQLMap["stars"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "stars")
    }
  }

  /// Comment about the movie, optional
  public var commentary: Swift.Optional<String?> {
    get {
      return graphQLMap["commentary"] as! Swift.Optional<String?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "commentary")
    }
  }

  /// Favorite color, optional
  public var favoriteColor: Swift.Optional<ColorInput?> {
    get {
      return graphQLMap["favorite_color"] as! Swift.Optional<ColorInput?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "favorite_color")
    }
  }
}

/// The input object sent when passing in a color
public struct ColorInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(red: Int, green: Int, blue: Int) {
    graphQLMap = ["red": red, "green": green, "blue": blue]
  }

  public var red: Int {
    get {
      return graphQLMap["red"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "red")
    }
  }

  public var green: Int {
    get {
      return graphQLMap["green"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "green")
    }
  }

  public var blue: Int {
    get {
      return graphQLMap["blue"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "blue")
    }
  }
}

public final class HeroAndFriendsNamesQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroAndFriendsNames($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    name\n    friends {\n      __typename\n      name\n    }\n  }\n}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("friends", type: .list(.object(Friend.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? {
        get {
          return (resultMap["friends"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Friend?] in value.map { (value: ResultMap?) -> Friend? in value.flatMap { (value: ResultMap) -> Friend in Friend(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }, forKey: "friends")
        }
      }

      public struct Friend: GraphQLSelectionSet {
        public static let possibleTypes = ["Human", "Droid"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeHuman(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
        }

        public static func makeDroid(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The name of the character
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }
      }
    }
  }
}

public final class HeroAndFriendsNamesWithIDsQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroAndFriendsNamesWithIDs($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    id\n    name\n    friends {\n      __typename\n      id\n      name\n    }\n  }\n}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("friends", type: .list(.object(Friend.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(id: GraphQLID, name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "id": id, "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(id: GraphQLID, name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "id": id, "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The ID of the character
      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? {
        get {
          return (resultMap["friends"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Friend?] in value.map { (value: ResultMap?) -> Friend? in value.flatMap { (value: ResultMap) -> Friend in Friend(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }, forKey: "friends")
        }
      }

      public struct Friend: GraphQLSelectionSet {
        public static let possibleTypes = ["Human", "Droid"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeHuman(id: GraphQLID, name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "id": id, "name": name])
        }

        public static func makeDroid(id: GraphQLID, name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "id": id, "name": name])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The ID of the character
        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        /// The name of the character
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }
      }
    }
  }
}

public final class HeroAndFriendsNamesWithIdForParentOnlyQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroAndFriendsNamesWithIDForParentOnly($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    id\n    name\n    friends {\n      __typename\n      name\n    }\n  }\n}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("friends", type: .list(.object(Friend.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(id: GraphQLID, name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "id": id, "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(id: GraphQLID, name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "id": id, "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The ID of the character
      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? {
        get {
          return (resultMap["friends"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Friend?] in value.map { (value: ResultMap?) -> Friend? in value.flatMap { (value: ResultMap) -> Friend in Friend(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }, forKey: "friends")
        }
      }

      public struct Friend: GraphQLSelectionSet {
        public static let possibleTypes = ["Human", "Droid"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeHuman(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
        }

        public static func makeDroid(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The name of the character
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }
      }
    }
  }
}

public final class HeroAndFriendsNamesWithFragmentQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroAndFriendsNamesWithFragment($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    name\n    ...FriendsNames\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(FriendsNames.fragmentDefinition) }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("friends", type: .list(.object(Friend.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(name: String, friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      /// The friends of the character, or an empty list if they have none
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
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
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

      public struct Friend: GraphQLSelectionSet {
        public static let possibleTypes = ["Human", "Droid"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeHuman(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
        }

        public static func makeDroid(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The name of the character
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }
      }
    }
  }
}

public final class HeroAndFriendsNamesWithFragmentTwiceQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroAndFriendsNamesWithFragmentTwice($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    friends {\n      __typename\n      ...CharacterName\n    }\n    ... on Droid {\n      friends {\n        __typename\n        ...CharacterName\n      }\n    }\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(CharacterName.fragmentDefinition) }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["Droid": AsDroid.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("friends", type: .list(.object(Friend.selections))),
          ]
        )
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(friends: [AsDroid.Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "friends": friends.flatMap { (value: [AsDroid.Friend?]) -> [ResultMap?] in value.map { (value: AsDroid.Friend?) -> ResultMap? in value.flatMap { (value: AsDroid.Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? {
        get {
          return (resultMap["friends"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Friend?] in value.map { (value: ResultMap?) -> Friend? in value.flatMap { (value: ResultMap) -> Friend in Friend(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }, forKey: "friends")
        }
      }

      public struct Friend: GraphQLSelectionSet {
        public static let possibleTypes = ["Human", "Droid"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeHuman(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
        }

        public static func makeDroid(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The name of the character
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
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
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

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

      public struct AsDroid: GraphQLSelectionSet {
        public static let possibleTypes = ["Droid"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("friends", type: .list(.object(Friend.selections))),
          GraphQLField("friends", type: .list(.object(Friend.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(friends: [Friend?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "Droid", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// This droid's friends, or an empty list if they have none
        public var friends: [Friend?]? {
          get {
            return (resultMap["friends"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Friend?] in value.map { (value: ResultMap?) -> Friend? in value.flatMap { (value: ResultMap) -> Friend in Friend(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }, forKey: "friends")
          }
        }

        public struct Friend: GraphQLSelectionSet {
          public static let possibleTypes = ["Human", "Droid"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeHuman(name: String) -> Friend {
            return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
          }

          public static func makeDroid(name: String) -> Friend {
            return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// The name of the character
          public var name: String {
            get {
              return resultMap["name"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
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
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

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

public final class HeroFriendsOfFriendsNamesQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroFriendsOfFriendsNames($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    friends {\n      __typename\n      id\n      friends {\n        __typename\n        name\n      }\n    }\n  }\n}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("friends", type: .list(.object(Friend.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? {
        get {
          return (resultMap["friends"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Friend?] in value.map { (value: ResultMap?) -> Friend? in value.flatMap { (value: ResultMap) -> Friend in Friend(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }, forKey: "friends")
        }
      }

      public struct Friend: GraphQLSelectionSet {
        public static let possibleTypes = ["Human", "Droid"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("friends", type: .list(.object(Friend.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeHuman(id: GraphQLID, friends: [Friend?]? = nil) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "id": id, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
        }

        public static func makeDroid(id: GraphQLID, friends: [Friend?]? = nil) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "id": id, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The ID of the character
        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        /// The friends of the character, or an empty list if they have none
        public var friends: [Friend?]? {
          get {
            return (resultMap["friends"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Friend?] in value.map { (value: ResultMap?) -> Friend? in value.flatMap { (value: ResultMap) -> Friend in Friend(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }, forKey: "friends")
          }
        }

        public struct Friend: GraphQLSelectionSet {
          public static let possibleTypes = ["Human", "Droid"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeHuman(name: String) -> Friend {
            return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
          }

          public static func makeDroid(name: String) -> Friend {
            return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// The name of the character
          public var name: String {
            get {
              return resultMap["name"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }
        }
      }
    }
  }
}

public final class HeroNameAndAppearsInWithFragmentQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroNameAndAppearsInWithFragment($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    ...CharacterNameAndAppearsIn\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(CharacterNameAndAppearsIn.fragmentDefinition) }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String, appearsIn: [Episode?]) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "appearsIn": appearsIn])
      }

      public static func makeDroid(name: String, appearsIn: [Episode?]) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      /// The movies this character appears in
      public var appearsIn: [Episode?] {
        get {
          return resultMap["appearsIn"]! as! [Episode?]
        }
        set {
          resultMap.updateValue(newValue, forKey: "appearsIn")
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
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

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

public final class StarshipQuery: GraphQLQuery {
  public let operationDefinition =
    "query Starship {\n  starship(id: 3000) {\n    __typename\n    name\n    coordinates\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("starship", arguments: ["id": 3000], type: .object(Starship.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(starship: Starship? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "starship": starship.flatMap { (value: Starship) -> ResultMap in value.resultMap }])
    }

    public var starship: Starship? {
      get {
        return (resultMap["starship"] as? ResultMap).flatMap { Starship(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "starship")
      }
    }

    public struct Starship: GraphQLSelectionSet {
      public static let possibleTypes = ["Starship"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("coordinates", type: .list(.nonNull(.list(.nonNull(.scalar(Double.self)))))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(name: String, coordinates: [[Double]]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Starship", "name": name, "coordinates": coordinates])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the starship
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

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

public final class HeroAppearsInQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroAppearsIn {\n  hero {\n    __typename\n    appearsIn\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(appearsIn: [Episode?]) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "appearsIn": appearsIn])
      }

      public static func makeDroid(appearsIn: [Episode?]) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "appearsIn": appearsIn])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The movies this character appears in
      public var appearsIn: [Episode?] {
        get {
          return resultMap["appearsIn"]! as! [Episode?]
        }
        set {
          resultMap.updateValue(newValue, forKey: "appearsIn")
        }
      }
    }
  }
}

public final class HeroAppearsInWithFragmentQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroAppearsInWithFragment($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    ...CharacterAppearsIn\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(CharacterAppearsIn.fragmentDefinition) }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(appearsIn: [Episode?]) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "appearsIn": appearsIn])
      }

      public static func makeDroid(appearsIn: [Episode?]) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "appearsIn": appearsIn])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The movies this character appears in
      public var appearsIn: [Episode?] {
        get {
          return resultMap["appearsIn"]! as! [Episode?]
        }
        set {
          resultMap.updateValue(newValue, forKey: "appearsIn")
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
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
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
  }
}

public final class HeroDetailsQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroDetails($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    name\n    ... on Human {\n      height\n    }\n    ... on Droid {\n      primaryFunction\n    }\n  }\n}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["Human": AsHuman.selections, "Droid": AsDroid.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String, height: Double? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
      }

      public static func makeDroid(name: String, primaryFunction: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
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

      public struct AsHuman: GraphQLSelectionSet {
        public static let possibleTypes = ["Human"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("height", type: .scalar(Double.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, height: Double? = nil) {
          self.init(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// What this human calls themselves
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

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

      public struct AsDroid: GraphQLSelectionSet {
        public static let possibleTypes = ["Droid"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("primaryFunction", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, primaryFunction: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// What others call this droid
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

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
  }
}

public final class HeroDetailsWithFragmentQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroDetailsWithFragment($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    ...HeroDetails\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(HeroDetails.fragmentDefinition) }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["Human": AsHuman.selections, "Droid": AsDroid.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String, height: Double? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
      }

      public static func makeDroid(name: String, primaryFunction: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
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
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

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

      public struct AsHuman: GraphQLSelectionSet {
        public static let possibleTypes = ["Human"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("height", type: .scalar(Double.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, height: Double? = nil) {
          self.init(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// What this human calls themselves
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        /// Height in the preferred unit, default is meters
        public var height: Double? {
          get {
            return resultMap["height"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "height")
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
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

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

      public struct AsDroid: GraphQLSelectionSet {
        public static let possibleTypes = ["Droid"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("primaryFunction", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, primaryFunction: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// What others call this droid
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

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
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

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
  public let operationDefinition =
    "query DroidDetailsWithFragment($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    ...DroidDetails\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(DroidDetails.fragmentDefinition) }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["Droid": AsDroid.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman() -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human"])
      }

      public static func makeDroid(name: String, primaryFunction: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
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
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

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

      public struct AsDroid: GraphQLSelectionSet {
        public static let possibleTypes = ["Droid"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("primaryFunction", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, primaryFunction: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// What others call this droid
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

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
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

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

public final class SameHeroTwiceQuery: GraphQLQuery {
  public let operationDefinition =
    "query SameHeroTwice {\n  hero {\n    __typename\n    name\n  }\n  r2: hero {\n    __typename\n    appearsIn\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", type: .object(Hero.selections)),
      GraphQLField("hero", alias: "r2", type: .object(R2.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil, r2: R2? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }, "r2": r2.flatMap { (value: R2) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public var r2: R2? {
      get {
        return (resultMap["r2"] as? ResultMap).flatMap { R2(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "r2")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }
    }

    public struct R2: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(appearsIn: [Episode?]) -> R2 {
        return R2(unsafeResultMap: ["__typename": "Human", "appearsIn": appearsIn])
      }

      public static func makeDroid(appearsIn: [Episode?]) -> R2 {
        return R2(unsafeResultMap: ["__typename": "Droid", "appearsIn": appearsIn])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The movies this character appears in
      public var appearsIn: [Episode?] {
        get {
          return resultMap["appearsIn"]! as! [Episode?]
        }
        set {
          resultMap.updateValue(newValue, forKey: "appearsIn")
        }
      }
    }
  }
}

public final class TwoHeroesQuery: GraphQLQuery {
  public let operationDefinition =
    "query TwoHeroes {\n  r2: hero {\n    __typename\n    name\n  }\n  luke: hero(episode: EMPIRE) {\n    __typename\n    name\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", alias: "r2", type: .object(R2.selections)),
      GraphQLField("hero", alias: "luke", arguments: ["episode": "EMPIRE"], type: .object(Luke.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(r2: R2? = nil, luke: Luke? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "r2": r2.flatMap { (value: R2) -> ResultMap in value.resultMap }, "luke": luke.flatMap { (value: Luke) -> ResultMap in value.resultMap }])
    }

    public var r2: R2? {
      get {
        return (resultMap["r2"] as? ResultMap).flatMap { R2(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "r2")
      }
    }

    public var luke: Luke? {
      get {
        return (resultMap["luke"] as? ResultMap).flatMap { Luke(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "luke")
      }
    }

    public struct R2: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String) -> R2 {
        return R2(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> R2 {
        return R2(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }
    }

    public struct Luke: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String) -> Luke {
        return Luke(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Luke {
        return Luke(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}

public final class HeroNameConditionalExclusionQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroNameConditionalExclusion($skipName: Boolean!) {\n  hero {\n    __typename\n    name @skip(if: $skipName)\n  }\n}"

  public var skipName: Bool

  public init(skipName: Bool) {
    self.skipName = skipName
  }

  public var variables: GraphQLMap? {
    return ["skipName": skipName]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLBooleanCondition(variableName: "skipName", inverted: true, selections: [
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String? {
        get {
          return resultMap["name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}

public final class HeroNameConditionalInclusionQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroNameConditionalInclusion($includeName: Boolean!) {\n  hero {\n    __typename\n    name @include(if: $includeName)\n  }\n}"

  public var includeName: Bool

  public init(includeName: Bool) {
    self.includeName = includeName
  }

  public var variables: GraphQLMap? {
    return ["includeName": includeName]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLBooleanCondition(variableName: "includeName", inverted: false, selections: [
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String? {
        get {
          return resultMap["name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}

public final class HeroNameConditionalBothQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroNameConditionalBoth($skipName: Boolean!, $includeName: Boolean!) {\n  hero {\n    __typename\n    name @skip(if: $skipName) @include(if: $includeName)\n  }\n}"

  public var skipName: Bool
  public var includeName: Bool

  public init(skipName: Bool, includeName: Bool) {
    self.skipName = skipName
    self.includeName = includeName
  }

  public var variables: GraphQLMap? {
    return ["skipName": skipName, "includeName": includeName]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLBooleanCondition(variableName: "includeName", inverted: false, selections: [
          GraphQLBooleanCondition(variableName: "skipName", inverted: true, selections: [
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
          ]),
        ]),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String? {
        get {
          return resultMap["name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}

public final class HeroNameConditionalBothSeparateQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroNameConditionalBothSeparate($skipName: Boolean!, $includeName: Boolean!) {\n  hero {\n    __typename\n    name @skip(if: $skipName)\n    name @include(if: $includeName)\n  }\n}"

  public var skipName: Bool
  public var includeName: Bool

  public init(skipName: Bool, includeName: Bool) {
    self.skipName = skipName
    self.includeName = includeName
  }

  public var variables: GraphQLMap? {
    return ["skipName": skipName, "includeName": includeName]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLBooleanCondition(variableName: "skipName", inverted: true, selections: [
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]),
        GraphQLBooleanCondition(variableName: "includeName", inverted: false, selections: [
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String? {
        get {
          return resultMap["name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}

public final class HeroDetailsInlineConditionalInclusionQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroDetailsInlineConditionalInclusion($includeDetails: Boolean!) {\n  hero {\n    __typename\n    ... @include(if: $includeDetails) {\n      name\n      appearsIn\n    }\n  }\n}"

  public var includeDetails: Bool

  public init(includeDetails: Bool) {
    self.includeDetails = includeDetails
  }

  public var variables: GraphQLMap? {
    return ["includeDetails": includeDetails]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLBooleanCondition(variableName: "includeDetails", inverted: false, selections: [
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
        ]),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String? = nil, appearsIn: [Episode?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "appearsIn": appearsIn])
      }

      public static func makeDroid(name: String? = nil, appearsIn: [Episode?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String? {
        get {
          return resultMap["name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      /// The movies this character appears in
      public var appearsIn: [Episode?]? {
        get {
          return resultMap["appearsIn"] as? [Episode?]
        }
        set {
          resultMap.updateValue(newValue, forKey: "appearsIn")
        }
      }
    }
  }
}

public final class HeroDetailsFragmentConditionalInclusionQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroDetailsFragmentConditionalInclusion($includeDetails: Boolean!) {\n  hero {\n    __typename\n    ...HeroDetails @include(if: $includeDetails)\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(HeroDetails.fragmentDefinition) }

  public var includeDetails: Bool

  public init(includeDetails: Bool) {
    self.includeDetails = includeDetails
  }

  public var variables: GraphQLMap? {
    return ["includeDetails": includeDetails]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["Human": AsHuman.selections, "Droid": AsDroid.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLBooleanCondition(variableName: "includeDetails", inverted: false, selections: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("name", type: .nonNull(.scalar(String.self))),
            ]),
          ]
        )
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String? = nil, height: Double? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
      }

      public static func makeDroid(name: String? = nil, primaryFunction: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String? {
        get {
          return resultMap["name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
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
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

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

      public struct AsHuman: GraphQLSelectionSet {
        public static let possibleTypes = ["Human"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLBooleanCondition(variableName: "includeDetails", inverted: false, selections: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
          ]),
          GraphQLBooleanCondition(variableName: "includeDetails", inverted: false, selections: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("height", type: .scalar(Double.self)),
          ]),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String? = nil, height: Double? = nil) {
          self.init(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// What this human calls themselves
        public var name: String? {
          get {
            return resultMap["name"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        /// Height in the preferred unit, default is meters
        public var height: Double? {
          get {
            return resultMap["height"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "height")
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
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

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

      public struct AsDroid: GraphQLSelectionSet {
        public static let possibleTypes = ["Droid"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLBooleanCondition(variableName: "includeDetails", inverted: false, selections: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
          ]),
          GraphQLBooleanCondition(variableName: "includeDetails", inverted: false, selections: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("primaryFunction", type: .scalar(String.self)),
          ]),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String? = nil, primaryFunction: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// What others call this droid
        public var name: String? {
          get {
            return resultMap["name"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

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
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

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
  public let operationDefinition =
    "query HeroNameTypeSpecificConditionalInclusion($episode: Episode, $includeName: Boolean!) {\n  hero(episode: $episode) {\n    __typename\n    name @include(if: $includeName)\n    ... on Droid {\n      name\n    }\n  }\n}"

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

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["Droid": AsDroid.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLBooleanCondition(variableName: "includeName", inverted: false, selections: [
              GraphQLField("name", type: .nonNull(.scalar(String.self))),
            ]),
          ]
        )
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String? {
        get {
          return resultMap["name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
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

      public struct AsDroid: GraphQLSelectionSet {
        public static let possibleTypes = ["Droid"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLBooleanCondition(variableName: "includeName", inverted: false, selections: [
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
          ]),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String) {
          self.init(unsafeResultMap: ["__typename": "Droid", "name": name])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// What others call this droid
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }
      }
    }
  }
}

public final class HeroFriendsDetailsConditionalInclusionQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroFriendsDetailsConditionalInclusion($includeFriendsDetails: Boolean!) {\n  hero {\n    __typename\n    friends @include(if: $includeFriendsDetails) {\n      __typename\n      name\n      ... on Droid {\n        primaryFunction\n      }\n    }\n  }\n}"

  public var includeFriendsDetails: Bool

  public init(includeFriendsDetails: Bool) {
    self.includeFriendsDetails = includeFriendsDetails
  }

  public var variables: GraphQLMap? {
    return ["includeFriendsDetails": includeFriendsDetails]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLBooleanCondition(variableName: "includeFriendsDetails", inverted: false, selections: [
          GraphQLField("friends", type: .list(.object(Friend.selections))),
        ]),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? {
        get {
          return (resultMap["friends"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Friend?] in value.map { (value: ResultMap?) -> Friend? in value.flatMap { (value: ResultMap) -> Friend in Friend(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }, forKey: "friends")
        }
      }

      public struct Friend: GraphQLSelectionSet {
        public static let possibleTypes = ["Human", "Droid"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["Droid": AsDroid.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("name", type: .nonNull(.scalar(String.self))),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeHuman(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
        }

        public static func makeDroid(name: String, primaryFunction: String? = nil) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The name of the character
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
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

        public struct AsDroid: GraphQLSelectionSet {
          public static let possibleTypes = ["Droid"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("primaryFunction", type: .scalar(String.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(name: String, primaryFunction: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// What others call this droid
          public var name: String {
            get {
              return resultMap["name"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

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
    }
  }
}

public final class HeroFriendsDetailsUnconditionalAndConditionalInclusionQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroFriendsDetailsUnconditionalAndConditionalInclusion($includeFriendsDetails: Boolean!) {\n  hero {\n    __typename\n    friends {\n      __typename\n      name\n    }\n    friends @include(if: $includeFriendsDetails) {\n      __typename\n      name\n      ... on Droid {\n        primaryFunction\n      }\n    }\n  }\n}"

  public var includeFriendsDetails: Bool

  public init(includeFriendsDetails: Bool) {
    self.includeFriendsDetails = includeFriendsDetails
  }

  public var variables: GraphQLMap? {
    return ["includeFriendsDetails": includeFriendsDetails]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("friends", type: .list(.object(Friend.selections))),
        GraphQLBooleanCondition(variableName: "includeFriendsDetails", inverted: false, selections: [
          GraphQLField("friends", type: .list(.object(Friend.selections))),
        ]),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(friends: [Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? {
        get {
          return (resultMap["friends"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Friend?] in value.map { (value: ResultMap?) -> Friend? in value.flatMap { (value: ResultMap) -> Friend in Friend(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }, forKey: "friends")
        }
      }

      public struct Friend: GraphQLSelectionSet {
        public static let possibleTypes = ["Human", "Droid"]

        public static let selections: [GraphQLSelection] = [
          GraphQLTypeCase(
            variants: ["Droid": AsDroid.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("name", type: .nonNull(.scalar(String.self))),
              GraphQLBooleanCondition(variableName: "includeFriendsDetails", inverted: false, selections: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("name", type: .nonNull(.scalar(String.self))),
              ]),
            ]
          )
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeHuman(name: String) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
        }

        public static func makeDroid(name: String, primaryFunction: String? = nil) -> Friend {
          return Friend(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The name of the character
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
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

        public struct AsDroid: GraphQLSelectionSet {
          public static let possibleTypes = ["Droid"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLBooleanCondition(variableName: "includeFriendsDetails", inverted: false, selections: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("name", type: .nonNull(.scalar(String.self))),
            ]),
            GraphQLBooleanCondition(variableName: "includeFriendsDetails", inverted: false, selections: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("name", type: .nonNull(.scalar(String.self))),
              GraphQLField("primaryFunction", type: .scalar(String.self)),
            ]),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(name: String, primaryFunction: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// What others call this droid
          public var name: String {
            get {
              return resultMap["name"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

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
    }
  }
}

public final class HumanQuery: GraphQLQuery {
  public let operationDefinition =
    "query Human($id: ID!) {\n  human(id: $id) {\n    __typename\n    name\n    mass\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("human", arguments: ["id": GraphQLVariable("id")], type: .object(Human.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(human: Human? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "human": human.flatMap { (value: Human) -> ResultMap in value.resultMap }])
    }

    public var human: Human? {
      get {
        return (resultMap["human"] as? ResultMap).flatMap { Human(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "human")
      }
    }

    public struct Human: GraphQLSelectionSet {
      public static let possibleTypes = ["Human"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("mass", type: .scalar(Double.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(name: String, mass: Double? = nil) {
        self.init(unsafeResultMap: ["__typename": "Human", "name": name, "mass": mass])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// What this human calls themselves
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

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

public final class HeroNameQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroName($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    name\n  }\n}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}

public final class HeroNameWithIdQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroNameWithID($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    id\n    name\n  }\n}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(id: GraphQLID, name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "id": id, "name": name])
      }

      public static func makeDroid(id: GraphQLID, name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "id": id, "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The ID of the character
      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}

public final class HeroNameWithFragmentQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroNameWithFragment($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    ...CharacterName\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(CharacterName.fragmentDefinition) }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
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
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

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
  public let operationDefinition =
    "query HeroNameWithFragmentAndID($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    id\n    ...CharacterName\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(CharacterName.fragmentDefinition) }

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(id: GraphQLID, name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "id": id, "name": name])
      }

      public static func makeDroid(id: GraphQLID, name: String) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "id": id, "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The ID of the character
      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
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
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

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

public final class HeroTypeDependentAliasedFieldQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroTypeDependentAliasedField($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    ... on Human {\n      property: homePlanet\n    }\n    ... on Droid {\n      property: primaryFunction\n    }\n  }\n}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["Human": AsHuman.selections, "Droid": AsDroid.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(property: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "property": property])
      }

      public static func makeDroid(property: String? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "property": property])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
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

      public struct AsHuman: GraphQLSelectionSet {
        public static let possibleTypes = ["Human"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("homePlanet", alias: "property", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(property: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Human", "property": property])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

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

      public struct AsDroid: GraphQLSelectionSet {
        public static let possibleTypes = ["Droid"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("primaryFunction", alias: "property", type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(property: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Droid", "property": property])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

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

public final class ReviewAddedSubscription: GraphQLSubscription {
  public let operationDefinition =
    "subscription ReviewAdded($episode: Episode) {\n  reviewAdded(episode: $episode) {\n    __typename\n    episode\n    stars\n    commentary\n  }\n}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("reviewAdded", arguments: ["episode": GraphQLVariable("episode")], type: .object(ReviewAdded.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(reviewAdded: ReviewAdded? = nil) {
      self.init(unsafeResultMap: ["__typename": "Subscription", "reviewAdded": reviewAdded.flatMap { (value: ReviewAdded) -> ResultMap in value.resultMap }])
    }

    public var reviewAdded: ReviewAdded? {
      get {
        return (resultMap["reviewAdded"] as? ResultMap).flatMap { ReviewAdded(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "reviewAdded")
      }
    }

    public struct ReviewAdded: GraphQLSelectionSet {
      public static let possibleTypes = ["Review"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("episode", type: .scalar(Episode.self)),
        GraphQLField("stars", type: .nonNull(.scalar(Int.self))),
        GraphQLField("commentary", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(episode: Episode? = nil, stars: Int, commentary: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Review", "episode": episode, "stars": stars, "commentary": commentary])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

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
      public var stars: Int {
        get {
          return resultMap["stars"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "stars")
        }
      }

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

public final class HeroParentTypeDependentFieldQuery: GraphQLQuery {
  public let operationDefinition =
    "query HeroParentTypeDependentField($episode: Episode) {\n  hero(episode: $episode) {\n    __typename\n    name\n    ... on Human {\n      friends {\n        __typename\n        name\n        ... on Human {\n          height(unit: FOOT)\n        }\n      }\n    }\n    ... on Droid {\n      friends {\n        __typename\n        name\n        ... on Human {\n          height(unit: METER)\n        }\n      }\n    }\n  }\n}"

  public var episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hero", arguments: ["episode": GraphQLVariable("episode")], type: .object(Hero.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hero: Hero? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hero": hero.flatMap { (value: Hero) -> ResultMap in value.resultMap }])
    }

    public var hero: Hero? {
      get {
        return (resultMap["hero"] as? ResultMap).flatMap { Hero(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "hero")
      }
    }

    public struct Hero: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["Human": AsHuman.selections, "Droid": AsDroid.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String, friends: [AsHuman.Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Human", "name": name, "friends": friends.flatMap { (value: [AsHuman.Friend?]) -> [ResultMap?] in value.map { (value: AsHuman.Friend?) -> ResultMap? in value.flatMap { (value: AsHuman.Friend) -> ResultMap in value.resultMap } } }])
      }

      public static func makeDroid(name: String, friends: [AsDroid.Friend?]? = nil) -> Hero {
        return Hero(unsafeResultMap: ["__typename": "Droid", "name": name, "friends": friends.flatMap { (value: [AsDroid.Friend?]) -> [ResultMap?] in value.map { (value: AsDroid.Friend?) -> ResultMap? in value.flatMap { (value: AsDroid.Friend) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
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

      public struct AsHuman: GraphQLSelectionSet {
        public static let possibleTypes = ["Human"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("friends", type: .list(.object(Friend.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, friends: [Friend?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "Human", "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// What this human calls themselves
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        /// This human's friends, or an empty list if they have none
        public var friends: [Friend?]? {
          get {
            return (resultMap["friends"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Friend?] in value.map { (value: ResultMap?) -> Friend? in value.flatMap { (value: ResultMap) -> Friend in Friend(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }, forKey: "friends")
          }
        }

        public struct Friend: GraphQLSelectionSet {
          public static let possibleTypes = ["Human", "Droid"]

          public static let selections: [GraphQLSelection] = [
            GraphQLTypeCase(
              variants: ["Human": AsHuman.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("name", type: .nonNull(.scalar(String.self))),
              ]
            )
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeDroid(name: String) -> Friend {
            return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
          }

          public static func makeHuman(name: String, height: Double? = nil) -> Friend {
            return Friend(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// The name of the character
          public var name: String {
            get {
              return resultMap["name"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
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

          public struct AsHuman: GraphQLSelectionSet {
            public static let possibleTypes = ["Human"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("name", type: .nonNull(.scalar(String.self))),
              GraphQLField("height", arguments: ["unit": "FOOT"], type: .scalar(Double.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(name: String, height: Double? = nil) {
              self.init(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// What this human calls themselves
            public var name: String {
              get {
                return resultMap["name"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "name")
              }
            }

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

      public struct AsDroid: GraphQLSelectionSet {
        public static let possibleTypes = ["Droid"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("friends", type: .list(.object(Friend.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, friends: [Friend?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "Droid", "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// What others call this droid
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        /// This droid's friends, or an empty list if they have none
        public var friends: [Friend?]? {
          get {
            return (resultMap["friends"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Friend?] in value.map { (value: ResultMap?) -> Friend? in value.flatMap { (value: ResultMap) -> Friend in Friend(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }, forKey: "friends")
          }
        }

        public struct Friend: GraphQLSelectionSet {
          public static let possibleTypes = ["Human", "Droid"]

          public static let selections: [GraphQLSelection] = [
            GraphQLTypeCase(
              variants: ["Human": AsHuman.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("name", type: .nonNull(.scalar(String.self))),
              ]
            )
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeDroid(name: String) -> Friend {
            return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
          }

          public static func makeHuman(name: String, height: Double? = nil) -> Friend {
            return Friend(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// The name of the character
          public var name: String {
            get {
              return resultMap["name"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
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

          public struct AsHuman: GraphQLSelectionSet {
            public static let possibleTypes = ["Human"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("name", type: .nonNull(.scalar(String.self))),
              GraphQLField("height", arguments: ["unit": "METER"], type: .scalar(Double.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(name: String, height: Double? = nil) {
              self.init(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// What this human calls themselves
            public var name: String {
              get {
                return resultMap["name"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "name")
              }
            }

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

public final class CreateReviewForEpisodeMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation CreateReviewForEpisode($episode: Episode!, $review: ReviewInput!) {\n  createReview(episode: $episode, review: $review) {\n    __typename\n    stars\n    commentary\n  }\n}"

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

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createReview", arguments: ["episode": GraphQLVariable("episode"), "review": GraphQLVariable("review")], type: .object(CreateReview.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createReview: CreateReview? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createReview": createReview.flatMap { (value: CreateReview) -> ResultMap in value.resultMap }])
    }

    public var createReview: CreateReview? {
      get {
        return (resultMap["createReview"] as? ResultMap).flatMap { CreateReview(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "createReview")
      }
    }

    public struct CreateReview: GraphQLSelectionSet {
      public static let possibleTypes = ["Review"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("stars", type: .nonNull(.scalar(Int.self))),
        GraphQLField("commentary", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(stars: Int, commentary: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Review", "stars": stars, "commentary": commentary])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The number of stars this review gave, 1-5
      public var stars: Int {
        get {
          return resultMap["stars"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "stars")
        }
      }

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

public final class CreateAwesomeReviewMutation: GraphQLMutation {
  public let operationDefinition =
    "mutation CreateAwesomeReview {\n  createReview(episode: JEDI, review: {stars: 10, commentary: \"This is awesome!\"}) {\n    __typename\n    stars\n    commentary\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createReview", arguments: ["episode": "JEDI", "review": ["stars": 10, "commentary": "This is awesome!"]], type: .object(CreateReview.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createReview: CreateReview? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createReview": createReview.flatMap { (value: CreateReview) -> ResultMap in value.resultMap }])
    }

    public var createReview: CreateReview? {
      get {
        return (resultMap["createReview"] as? ResultMap).flatMap { CreateReview(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "createReview")
      }
    }

    public struct CreateReview: GraphQLSelectionSet {
      public static let possibleTypes = ["Review"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("stars", type: .nonNull(.scalar(Int.self))),
        GraphQLField("commentary", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(stars: Int, commentary: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Review", "stars": stars, "commentary": commentary])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The number of stars this review gave, 1-5
      public var stars: Int {
        get {
          return resultMap["stars"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "stars")
        }
      }

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

public struct FriendsNames: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment FriendsNames on Character {\n  __typename\n  friends {\n    __typename\n    name\n  }\n}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("friends", type: .list(.object(Friend.selections))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeHuman(friends: [Friend?]? = nil) -> FriendsNames {
    return FriendsNames(unsafeResultMap: ["__typename": "Human", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
  }

  public static func makeDroid(friends: [Friend?]? = nil) -> FriendsNames {
    return FriendsNames(unsafeResultMap: ["__typename": "Droid", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The friends of the character, or an empty list if they have none
  public var friends: [Friend?]? {
    get {
      return (resultMap["friends"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Friend?] in value.map { (value: ResultMap?) -> Friend? in value.flatMap { (value: ResultMap) -> Friend in Friend(unsafeResultMap: value) } } }
    }
    set {
      resultMap.updateValue(newValue.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }, forKey: "friends")
    }
  }

  public struct Friend: GraphQLSelectionSet {
    public static let possibleTypes = ["Human", "Droid"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("name", type: .nonNull(.scalar(String.self))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeHuman(name: String) -> Friend {
      return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
    }

    public static func makeDroid(name: String) -> Friend {
      return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// The name of the character
    public var name: String {
      get {
        return resultMap["name"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }
  }
}

public struct CharacterNameAndAppearsIn: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment CharacterNameAndAppearsIn on Character {\n  __typename\n  name\n  appearsIn\n}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("name", type: .nonNull(.scalar(String.self))),
    GraphQLField("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeHuman(name: String, appearsIn: [Episode?]) -> CharacterNameAndAppearsIn {
    return CharacterNameAndAppearsIn(unsafeResultMap: ["__typename": "Human", "name": name, "appearsIn": appearsIn])
  }

  public static func makeDroid(name: String, appearsIn: [Episode?]) -> CharacterNameAndAppearsIn {
    return CharacterNameAndAppearsIn(unsafeResultMap: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The name of the character
  public var name: String {
    get {
      return resultMap["name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }

  /// The movies this character appears in
  public var appearsIn: [Episode?] {
    get {
      return resultMap["appearsIn"]! as! [Episode?]
    }
    set {
      resultMap.updateValue(newValue, forKey: "appearsIn")
    }
  }
}

public struct CharacterAppearsIn: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment CharacterAppearsIn on Character {\n  __typename\n  appearsIn\n}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeHuman(appearsIn: [Episode?]) -> CharacterAppearsIn {
    return CharacterAppearsIn(unsafeResultMap: ["__typename": "Human", "appearsIn": appearsIn])
  }

  public static func makeDroid(appearsIn: [Episode?]) -> CharacterAppearsIn {
    return CharacterAppearsIn(unsafeResultMap: ["__typename": "Droid", "appearsIn": appearsIn])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The movies this character appears in
  public var appearsIn: [Episode?] {
    get {
      return resultMap["appearsIn"]! as! [Episode?]
    }
    set {
      resultMap.updateValue(newValue, forKey: "appearsIn")
    }
  }
}

public struct HeroDetails: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment HeroDetails on Character {\n  __typename\n  name\n  ... on Human {\n    height\n  }\n  ... on Droid {\n    primaryFunction\n  }\n}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [GraphQLSelection] = [
    GraphQLTypeCase(
      variants: ["Human": AsHuman.selections, "Droid": AsDroid.selections],
      default: [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]
    )
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeHuman(name: String, height: Double? = nil) -> HeroDetails {
    return HeroDetails(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
  }

  public static func makeDroid(name: String, primaryFunction: String? = nil) -> HeroDetails {
    return HeroDetails(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The name of the character
  public var name: String {
    get {
      return resultMap["name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
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

  public struct AsHuman: GraphQLSelectionSet {
    public static let possibleTypes = ["Human"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("name", type: .nonNull(.scalar(String.self))),
      GraphQLField("height", type: .scalar(Double.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(name: String, height: Double? = nil) {
      self.init(unsafeResultMap: ["__typename": "Human", "name": name, "height": height])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// What this human calls themselves
    public var name: String {
      get {
        return resultMap["name"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }

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

  public struct AsDroid: GraphQLSelectionSet {
    public static let possibleTypes = ["Droid"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("name", type: .nonNull(.scalar(String.self))),
      GraphQLField("primaryFunction", type: .scalar(String.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(name: String, primaryFunction: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// What others call this droid
    public var name: String {
      get {
        return resultMap["name"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }

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
  public static let fragmentDefinition =
    "fragment DroidDetails on Droid {\n  __typename\n  name\n  primaryFunction\n}"

  public static let possibleTypes = ["Droid"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("name", type: .nonNull(.scalar(String.self))),
    GraphQLField("primaryFunction", type: .scalar(String.self)),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(name: String, primaryFunction: String? = nil) {
    self.init(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// What others call this droid
  public var name: String {
    get {
      return resultMap["name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }

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
  public static let fragmentDefinition =
    "fragment CharacterName on Character {\n  __typename\n  name\n}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("name", type: .nonNull(.scalar(String.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeHuman(name: String) -> CharacterName {
    return CharacterName(unsafeResultMap: ["__typename": "Human", "name": name])
  }

  public static func makeDroid(name: String) -> CharacterName {
    return CharacterName(unsafeResultMap: ["__typename": "Droid", "name": name])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The name of the character
  public var name: String {
    get {
      return resultMap["name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }
}

public struct DroidNameAndPrimaryFunction: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment DroidNameAndPrimaryFunction on Droid {\n  __typename\n  ...CharacterName\n  ...DroidPrimaryFunction\n}"

  public static let possibleTypes = ["Droid"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("name", type: .nonNull(.scalar(String.self))),
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("primaryFunction", type: .scalar(String.self)),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(name: String, primaryFunction: String? = nil) {
    self.init(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// What others call this droid
  public var name: String {
    get {
      return resultMap["name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }

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
    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

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
  public static let fragmentDefinition =
    "fragment CharacterNameAndDroidPrimaryFunction on Character {\n  __typename\n  ...CharacterName\n  ...DroidPrimaryFunction\n}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [GraphQLSelection] = [
    GraphQLTypeCase(
      variants: ["Droid": AsDroid.selections],
      default: [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]
    )
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeHuman(name: String) -> CharacterNameAndDroidPrimaryFunction {
    return CharacterNameAndDroidPrimaryFunction(unsafeResultMap: ["__typename": "Human", "name": name])
  }

  public static func makeDroid(name: String, primaryFunction: String? = nil) -> CharacterNameAndDroidPrimaryFunction {
    return CharacterNameAndDroidPrimaryFunction(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The name of the character
  public var name: String {
    get {
      return resultMap["name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
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
    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

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

  public struct AsDroid: GraphQLSelectionSet {
    public static let possibleTypes = ["Droid"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("name", type: .nonNull(.scalar(String.self))),
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("primaryFunction", type: .scalar(String.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(name: String, primaryFunction: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "Droid", "name": name, "primaryFunction": primaryFunction])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// What others call this droid
    public var name: String {
      get {
        return resultMap["name"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }

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
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

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
  public static let fragmentDefinition =
    "fragment CharacterNameAndDroidAppearsIn on Character {\n  __typename\n  name\n  ... on Droid {\n    appearsIn\n  }\n}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [GraphQLSelection] = [
    GraphQLTypeCase(
      variants: ["Droid": AsDroid.selections],
      default: [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]
    )
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeHuman(name: String) -> CharacterNameAndDroidAppearsIn {
    return CharacterNameAndDroidAppearsIn(unsafeResultMap: ["__typename": "Human", "name": name])
  }

  public static func makeDroid(name: String, appearsIn: [Episode?]) -> CharacterNameAndDroidAppearsIn {
    return CharacterNameAndDroidAppearsIn(unsafeResultMap: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The name of the character
  public var name: String {
    get {
      return resultMap["name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
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

  public struct AsDroid: GraphQLSelectionSet {
    public static let possibleTypes = ["Droid"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("name", type: .nonNull(.scalar(String.self))),
      GraphQLField("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(name: String, appearsIn: [Episode?]) {
      self.init(unsafeResultMap: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// What others call this droid
    public var name: String {
      get {
        return resultMap["name"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }

    /// The movies this droid appears in
    public var appearsIn: [Episode?] {
      get {
        return resultMap["appearsIn"]! as! [Episode?]
      }
      set {
        resultMap.updateValue(newValue, forKey: "appearsIn")
      }
    }
  }
}

public struct DroidName: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment DroidName on Droid {\n  __typename\n  name\n}"

  public static let possibleTypes = ["Droid"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("name", type: .nonNull(.scalar(String.self))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(name: String) {
    self.init(unsafeResultMap: ["__typename": "Droid", "name": name])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// What others call this droid
  public var name: String {
    get {
      return resultMap["name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }
}

public struct DroidPrimaryFunction: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment DroidPrimaryFunction on Droid {\n  __typename\n  primaryFunction\n}"

  public static let possibleTypes = ["Droid"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("primaryFunction", type: .scalar(String.self)),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(primaryFunction: String? = nil) {
    self.init(unsafeResultMap: ["__typename": "Droid", "primaryFunction": primaryFunction])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

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
  public static let fragmentDefinition =
    "fragment HumanHeightWithVariable on Human {\n  __typename\n  height(unit: $heightUnit)\n}"

  public static let possibleTypes = ["Human"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("height", arguments: ["unit": GraphQLVariable("heightUnit")], type: .scalar(Double.self)),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(height: Double? = nil) {
    self.init(unsafeResultMap: ["__typename": "Human", "height": height])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

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
  public static let fragmentDefinition =
    "fragment CharacterNameAndAppearsInWithNestedFragments on Character {\n  __typename\n  ...CharacterNameWithNestedAppearsInFragment\n}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("name", type: .nonNull(.scalar(String.self))),
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeHuman(name: String, appearsIn: [Episode?]) -> CharacterNameAndAppearsInWithNestedFragments {
    return CharacterNameAndAppearsInWithNestedFragments(unsafeResultMap: ["__typename": "Human", "name": name, "appearsIn": appearsIn])
  }

  public static func makeDroid(name: String, appearsIn: [Episode?]) -> CharacterNameAndAppearsInWithNestedFragments {
    return CharacterNameAndAppearsInWithNestedFragments(unsafeResultMap: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The name of the character
  public var name: String {
    get {
      return resultMap["name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }

  /// The movies this character appears in
  public var appearsIn: [Episode?] {
    get {
      return resultMap["appearsIn"]! as! [Episode?]
    }
    set {
      resultMap.updateValue(newValue, forKey: "appearsIn")
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
    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

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
  public static let fragmentDefinition =
    "fragment CharacterNameWithNestedAppearsInFragment on Character {\n  __typename\n  name\n  ...CharacterAppearsIn\n}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("name", type: .nonNull(.scalar(String.self))),
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeHuman(name: String, appearsIn: [Episode?]) -> CharacterNameWithNestedAppearsInFragment {
    return CharacterNameWithNestedAppearsInFragment(unsafeResultMap: ["__typename": "Human", "name": name, "appearsIn": appearsIn])
  }

  public static func makeDroid(name: String, appearsIn: [Episode?]) -> CharacterNameWithNestedAppearsInFragment {
    return CharacterNameWithNestedAppearsInFragment(unsafeResultMap: ["__typename": "Droid", "name": name, "appearsIn": appearsIn])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The name of the character
  public var name: String {
    get {
      return resultMap["name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }

  /// The movies this character appears in
  public var appearsIn: [Episode?] {
    get {
      return resultMap["appearsIn"]! as! [Episode?]
    }
    set {
      resultMap.updateValue(newValue, forKey: "appearsIn")
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
    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
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

public struct CharacterNameWithInlineFragment: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment CharacterNameWithInlineFragment on Character {\n  __typename\n  ... on Human {\n    friends {\n      __typename\n      appearsIn\n    }\n  }\n  ... on Droid {\n    ...CharacterName\n    ...FriendsNames\n  }\n}"

  public static let possibleTypes = ["Human", "Droid"]

  public static let selections: [GraphQLSelection] = [
    GraphQLTypeCase(
      variants: ["Human": AsHuman.selections, "Droid": AsDroid.selections],
      default: [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      ]
    )
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeHuman(friends: [AsHuman.Friend?]? = nil) -> CharacterNameWithInlineFragment {
    return CharacterNameWithInlineFragment(unsafeResultMap: ["__typename": "Human", "friends": friends.flatMap { (value: [AsHuman.Friend?]) -> [ResultMap?] in value.map { (value: AsHuman.Friend?) -> ResultMap? in value.flatMap { (value: AsHuman.Friend) -> ResultMap in value.resultMap } } }])
  }

  public static func makeDroid(name: String, friends: [AsDroid.Friend?]? = nil) -> CharacterNameWithInlineFragment {
    return CharacterNameWithInlineFragment(unsafeResultMap: ["__typename": "Droid", "name": name, "friends": friends.flatMap { (value: [AsDroid.Friend?]) -> [ResultMap?] in value.map { (value: AsDroid.Friend?) -> ResultMap? in value.flatMap { (value: AsDroid.Friend) -> ResultMap in value.resultMap } } }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
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

  public struct AsHuman: GraphQLSelectionSet {
    public static let possibleTypes = ["Human"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("friends", type: .list(.object(Friend.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(friends: [Friend?]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Human", "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// This human's friends, or an empty list if they have none
    public var friends: [Friend?]? {
      get {
        return (resultMap["friends"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Friend?] in value.map { (value: ResultMap?) -> Friend? in value.flatMap { (value: ResultMap) -> Friend in Friend(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }, forKey: "friends")
      }
    }

    public struct Friend: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(appearsIn: [Episode?]) -> Friend {
        return Friend(unsafeResultMap: ["__typename": "Human", "appearsIn": appearsIn])
      }

      public static func makeDroid(appearsIn: [Episode?]) -> Friend {
        return Friend(unsafeResultMap: ["__typename": "Droid", "appearsIn": appearsIn])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The movies this character appears in
      public var appearsIn: [Episode?] {
        get {
          return resultMap["appearsIn"]! as! [Episode?]
        }
        set {
          resultMap.updateValue(newValue, forKey: "appearsIn")
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

  public struct AsDroid: GraphQLSelectionSet {
    public static let possibleTypes = ["Droid"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("name", type: .nonNull(.scalar(String.self))),
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("friends", type: .list(.object(Friend.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(name: String, friends: [Friend?]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Droid", "name": name, "friends": friends.flatMap { (value: [Friend?]) -> [ResultMap?] in value.map { (value: Friend?) -> ResultMap? in value.flatMap { (value: Friend) -> ResultMap in value.resultMap } } }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// What others call this droid
    public var name: String {
      get {
        return resultMap["name"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }

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
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

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

    public struct Friend: GraphQLSelectionSet {
      public static let possibleTypes = ["Human", "Droid"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeHuman(name: String) -> Friend {
        return Friend(unsafeResultMap: ["__typename": "Human", "name": name])
      }

      public static func makeDroid(name: String) -> Friend {
        return Friend(unsafeResultMap: ["__typename": "Droid", "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the character
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}