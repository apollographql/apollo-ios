//  This file was automatically generated and should not be edited.

import Apollo

public enum Episode: String {
  case newhope = "NEWHOPE"
  case empire = "EMPIRE"
  case jedi = "JEDI"
}

extension Episode: JSONDecodable, JSONEncodable {}

public final class HeroAndFriendsNamesQuery: GraphQLQuery {
  public static let operationDefinition =
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

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMapConvertible {
    public let hero: Hero?

    public init(map: GraphQLMap) throws {
      hero = try map.optionalValue(forKey: "hero")
    }

    public struct Hero: GraphQLMapConvertible {
      public let __typename: String
      public let name: String
      public let friends: [Friend?]?

      public init(map: GraphQLMap) throws {
        __typename = try map.value(forKey: "__typename")
        name = try map.value(forKey: "name")
        friends = try map.optionalList(forKey: "friends")
      }

      public struct Friend: GraphQLMapConvertible {
        public let __typename: String
        public let name: String

        public init(map: GraphQLMap) throws {
          __typename = try map.value(forKey: "__typename")
          name = try map.value(forKey: "name")
        }
      }
    }
  }
}

public final class HeroAppearsInQuery: GraphQLQuery {
  public static let operationDefinition =
    "query HeroAppearsIn {" +
    "  hero {" +
    "    __typename" +
    "    name" +
    "    appearsIn" +
    "  }" +
    "}"

  public struct Data: GraphQLMapConvertible {
    public let hero: Hero?

    public init(map: GraphQLMap) throws {
      hero = try map.optionalValue(forKey: "hero")
    }

    public struct Hero: GraphQLMapConvertible {
      public let __typename: String
      public let name: String
      public let appearsIn: [Episode?]

      public init(map: GraphQLMap) throws {
        __typename = try map.value(forKey: "__typename")
        name = try map.value(forKey: "name")
        appearsIn = try map.list(forKey: "appearsIn")
      }
    }
  }
}

public final class HeroDetailsQuery: GraphQLQuery {
  public static let operationDefinition =
    "query HeroDetails($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    name" +
    "    ... on Human {" +
    "      height" +
    "    }" +
    "    ... on Droid {" +
    "      primaryFunction" +
    "    }" +
    "  }" +
    "}"

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMapConvertible {
    public let hero: Hero?

    public init(map: GraphQLMap) throws {
      hero = try map.optionalValue(forKey: "hero")
    }

    public struct Hero: GraphQLMapConvertible {
      public let __typename: String
      public let name: String

      public let asHuman: AsHuman?
      public let asDroid: AsDroid?

      public init(map: GraphQLMap) throws {
        __typename = try map.value(forKey: "__typename")
        name = try map.value(forKey: "name")

        asHuman = try AsHuman(map: map, ifTypeMatches: __typename)
        asDroid = try AsDroid(map: map, ifTypeMatches: __typename)
      }

      public struct AsHuman: GraphQLConditionalFragment {
        public static let possibleTypes = ["Human"]

        public let __typename = "Human"
        public let name: String
        public let height: Float?

        public init(map: GraphQLMap) throws {
          name = try map.value(forKey: "name")
          height = try map.optionalValue(forKey: "height")
        }
      }

      public struct AsDroid: GraphQLConditionalFragment {
        public static let possibleTypes = ["Droid"]

        public let __typename = "Droid"
        public let name: String
        public let primaryFunction: String?

        public init(map: GraphQLMap) throws {
          name = try map.value(forKey: "name")
          primaryFunction = try map.optionalValue(forKey: "primaryFunction")
        }
      }
    }
  }
}

public final class HeroDetailsWithFragmentQuery: GraphQLQuery {
  public static let operationDefinition =
    "query HeroDetailsWithFragment($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    ...HeroDetails" +
    "  }" +
    "}"
  public static let queryDocument = operationDefinition.appending(HeroDetails.fragmentDefinition)

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMapConvertible {
    public let hero: Hero?

    public init(map: GraphQLMap) throws {
      hero = try map.optionalValue(forKey: "hero")
    }

    public struct Hero: GraphQLMapConvertible {
      public let __typename: String

      public let fragments: Fragments

      public init(map: GraphQLMap) throws {
        __typename = try map.value(forKey: "__typename")

        let heroDetails = try HeroDetails(map: map)
        fragments = Fragments(heroDetails: heroDetails)
      }

      public struct Fragments {
        public let heroDetails: HeroDetails
      }
    }
  }
}

public final class HeroNameQuery: GraphQLQuery {
  public static let operationDefinition =
    "query HeroName {" +
    "  hero {" +
    "    __typename" +
    "    name" +
    "  }" +
    "}"

  public struct Data: GraphQLMapConvertible {
    public let hero: Hero?

    public init(map: GraphQLMap) throws {
      hero = try map.optionalValue(forKey: "hero")
    }

    public struct Hero: GraphQLMapConvertible {
      public let __typename: String
      public let name: String

      public init(map: GraphQLMap) throws {
        __typename = try map.value(forKey: "__typename")
        name = try map.value(forKey: "name")
      }
    }
  }
}

public final class TwoHeroesQuery: GraphQLQuery {
  public static let operationDefinition =
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

  public struct Data: GraphQLMapConvertible {
    public let r2: R2?
    public let luke: Luke?

    public init(map: GraphQLMap) throws {
      r2 = try map.optionalValue(forKey: "r2")
      luke = try map.optionalValue(forKey: "luke")
    }

    public struct R2: GraphQLMapConvertible {
      public let __typename: String
      public let name: String

      public init(map: GraphQLMap) throws {
        __typename = try map.value(forKey: "__typename")
        name = try map.value(forKey: "name")
      }
    }

    public struct Luke: GraphQLMapConvertible {
      public let __typename: String
      public let name: String

      public init(map: GraphQLMap) throws {
        __typename = try map.value(forKey: "__typename")
        name = try map.value(forKey: "name")
      }
    }
  }
}

public struct HeroDetails: GraphQLNamedFragment {
  public static let fragmentDefinition =
    "fragment HeroDetails on Character {" +
    "  __typename" +
    "  name" +
    "  ... on Human {" +
    "    height" +
    "  }" +
    "  ... on Droid {" +
    "    primaryFunction" +
    "  }" +
    "}"

  public static let possibleTypes = ["Human", "Droid"]

  public let __typename: String
  public let name: String

  public let asHuman: AsHuman?
  public let asDroid: AsDroid?

  public init(map: GraphQLMap) throws {
    __typename = try map.value(forKey: "__typename")
    name = try map.value(forKey: "name")

    asHuman = try AsHuman(map: map, ifTypeMatches: __typename)
    asDroid = try AsDroid(map: map, ifTypeMatches: __typename)
  }

  public struct AsHuman: GraphQLConditionalFragment {
    public static let possibleTypes = ["Human"]

    public let __typename = "Human"
    public let name: String
    public let height: Float?

    public init(map: GraphQLMap) throws {
      name = try map.value(forKey: "name")
      height = try map.optionalValue(forKey: "height")
    }
  }

  public struct AsDroid: GraphQLConditionalFragment {
    public static let possibleTypes = ["Droid"]

    public let __typename = "Droid"
    public let name: String
    public let primaryFunction: String?

    public init(map: GraphQLMap) throws {
      name = try map.value(forKey: "name")
      primaryFunction = try map.optionalValue(forKey: "primaryFunction")
    }
  }
}