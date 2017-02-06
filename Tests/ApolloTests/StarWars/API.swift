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
  public static let operationDefinition =
    "mutation CreateReviewForEpisode($episode: Episode!, $review: ReviewInput!) {" +
    "  createReview(episode: $episode, review: $review) {" +
    "    __typename" +
    "    stars" +
    "    commentary" +
    "  }" +
    "}"

  public let episode: Episode
  public let review: ReviewInput

  public init(episode: Episode, review: ReviewInput) {
    self.episode = episode
    self.review = review
  }

  public var variables: GraphQLMap? {
    return ["episode": episode, "review": review]
  }

  public struct Data: GraphQLMappable {
    public let createReview: CreateReview?

    public init(reader: GraphQLResultReader) throws {
      createReview = try reader.optionalValue(for: Field(responseName: "createReview", arguments: ["episode": reader.variables["episode"], "review": reader.variables["review"]]))
    }

    public struct CreateReview: GraphQLMappable {
      public let __typename: String
      public let stars: Int
      public let commentary: String?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        stars = try reader.value(for: Field(responseName: "stars"))
        commentary = try reader.optionalValue(for: Field(responseName: "commentary"))
      }
    }
  }
}

public final class CreateAwesomeReviewMutation: GraphQLMutation {
  public static let operationDefinition =
    "mutation CreateAwesomeReview {" +
    "  createReview(episode: JEDI, review: {stars: 10, commentary: \"This is awesome!\"}) {" +
    "    __typename" +
    "    stars" +
    "    commentary" +
    "  }" +
    "}"
  public init() {
  }

  public struct Data: GraphQLMappable {
    public let createReview: CreateReview?

    public init(reader: GraphQLResultReader) throws {
      createReview = try reader.optionalValue(for: Field(responseName: "createReview", arguments: ["episode": "JEDI", "review": ["stars": 10, "commentary": "This is awesome!"]]))
    }

    public struct CreateReview: GraphQLMappable {
      public let __typename: String
      public let stars: Int
      public let commentary: String?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        stars = try reader.value(for: Field(responseName: "stars"))
        commentary = try reader.optionalValue(for: Field(responseName: "commentary"))
      }
    }
  }
}

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

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(reader: GraphQLResultReader) throws {
      hero = try reader.optionalValue(for: Field(responseName: "hero", arguments: ["episode": reader.variables["episode"]]))
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let name: String
      public let friends: [Friend?]?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        name = try reader.value(for: Field(responseName: "name"))
        friends = try reader.optionalList(for: Field(responseName: "friends"))
      }

      public struct Friend: GraphQLMappable {
        public let __typename: String
        public let name: String

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          name = try reader.value(for: Field(responseName: "name"))
        }
      }
    }
  }
}

public final class HeroAndFriendsNamesWithIDsQuery: GraphQLQuery {
  public static let operationDefinition =
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

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(reader: GraphQLResultReader) throws {
      hero = try reader.optionalValue(for: Field(responseName: "hero", arguments: ["episode": reader.variables["episode"]]))
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let id: GraphQLID
      public let name: String
      public let friends: [Friend?]?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        id = try reader.value(for: Field(responseName: "id"))
        name = try reader.value(for: Field(responseName: "name"))
        friends = try reader.optionalList(for: Field(responseName: "friends"))
      }

      public struct Friend: GraphQLMappable {
        public let __typename: String
        public let id: GraphQLID
        public let name: String

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          id = try reader.value(for: Field(responseName: "id"))
          name = try reader.value(for: Field(responseName: "name"))
        }
      }
    }
  }
}

public final class HeroAndFriendsNamesWithIdForParentOnlyQuery: GraphQLQuery {
  public static let operationDefinition =
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

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(reader: GraphQLResultReader) throws {
      hero = try reader.optionalValue(for: Field(responseName: "hero", arguments: ["episode": reader.variables["episode"]]))
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let id: GraphQLID
      public let name: String
      public let friends: [Friend?]?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        id = try reader.value(for: Field(responseName: "id"))
        name = try reader.value(for: Field(responseName: "name"))
        friends = try reader.optionalList(for: Field(responseName: "friends"))
      }

      public struct Friend: GraphQLMappable {
        public let __typename: String
        public let name: String

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          name = try reader.value(for: Field(responseName: "name"))
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
    "    appearsIn" +
    "  }" +
    "}"
  public init() {
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(reader: GraphQLResultReader) throws {
      hero = try reader.optionalValue(for: Field(responseName: "hero"))
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let appearsIn: [Episode?]

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        appearsIn = try reader.list(for: Field(responseName: "appearsIn"))
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
    "      __typename" +
    "      height" +
    "    }" +
    "    ... on Droid {" +
    "      __typename" +
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

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(reader: GraphQLResultReader) throws {
      hero = try reader.optionalValue(for: Field(responseName: "hero", arguments: ["episode": reader.variables["episode"]]))
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let name: String

      public let asHuman: AsHuman?
      public let asDroid: AsDroid?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        name = try reader.value(for: Field(responseName: "name"))

        asHuman = try AsHuman(reader: reader, ifTypeMatches: __typename)
        asDroid = try AsDroid(reader: reader, ifTypeMatches: __typename)
      }

      public struct AsHuman: GraphQLConditionalFragment {
        public static let possibleTypes = ["Human"]

        public let __typename: String
        public let name: String
        public let height: Double?

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          name = try reader.value(for: Field(responseName: "name"))
          height = try reader.optionalValue(for: Field(responseName: "height"))
        }
      }

      public struct AsDroid: GraphQLConditionalFragment {
        public static let possibleTypes = ["Droid"]

        public let __typename: String
        public let name: String
        public let primaryFunction: String?

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          name = try reader.value(for: Field(responseName: "name"))
          primaryFunction = try reader.optionalValue(for: Field(responseName: "primaryFunction"))
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

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(reader: GraphQLResultReader) throws {
      hero = try reader.optionalValue(for: Field(responseName: "hero", arguments: ["episode": reader.variables["episode"]]))
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String

      public let fragments: Fragments

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))

        let heroDetails = try HeroDetails(reader: reader)
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
    "query HeroName($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    name" +
    "  }" +
    "}"

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(reader: GraphQLResultReader) throws {
      hero = try reader.optionalValue(for: Field(responseName: "hero", arguments: ["episode": reader.variables["episode"]]))
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let name: String

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        name = try reader.value(for: Field(responseName: "name"))
      }
    }
  }
}

public final class HeroNameWithIdQuery: GraphQLQuery {
  public static let operationDefinition =
    "query HeroNameWithID($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    id" +
    "    name" +
    "  }" +
    "}"

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(reader: GraphQLResultReader) throws {
      hero = try reader.optionalValue(for: Field(responseName: "hero", arguments: ["episode": reader.variables["episode"]]))
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let id: GraphQLID
      public let name: String

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        id = try reader.value(for: Field(responseName: "id"))
        name = try reader.value(for: Field(responseName: "name"))
      }
    }
  }
}

public final class HeroNameConditionalInclusionQuery: GraphQLQuery {
  public static let operationDefinition =
    "query HeroNameConditionalInclusion($episode: Episode, $includeName: Boolean!) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    name @include(if: $includeName)" +
    "  }" +
    "}"

  public let episode: Episode?
  public let includeName: Bool

  public init(episode: Episode? = nil, includeName: Bool) {
    self.episode = episode
    self.includeName = includeName
  }

  public var variables: GraphQLMap? {
    return ["episode": episode, "includeName": includeName]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(reader: GraphQLResultReader) throws {
      hero = try reader.optionalValue(for: Field(responseName: "hero", arguments: ["episode": reader.variables["episode"]]))
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let name: String?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        name = try reader.optionalValue(for: Field(responseName: "name"))
      }
    }
  }
}

public final class HeroNameConditionalExclusionQuery: GraphQLQuery {
  public static let operationDefinition =
    "query HeroNameConditionalExclusion($episode: Episode, $skipName: Boolean!) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    name @skip(if: $skipName)" +
    "  }" +
    "}"

  public let episode: Episode?
  public let skipName: Bool

  public init(episode: Episode? = nil, skipName: Bool) {
    self.episode = episode
    self.skipName = skipName
  }

  public var variables: GraphQLMap? {
    return ["episode": episode, "skipName": skipName]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(reader: GraphQLResultReader) throws {
      hero = try reader.optionalValue(for: Field(responseName: "hero", arguments: ["episode": reader.variables["episode"]]))
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let name: String?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        name = try reader.optionalValue(for: Field(responseName: "name"))
      }
    }
  }
}

public final class HeroParentTypeDependentFieldQuery: GraphQLQuery {
  public static let operationDefinition =
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

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(reader: GraphQLResultReader) throws {
      hero = try reader.optionalValue(for: Field(responseName: "hero", arguments: ["episode": reader.variables["episode"]]))
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let name: String

      public let asHuman: AsHuman?
      public let asDroid: AsDroid?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        name = try reader.value(for: Field(responseName: "name"))

        asHuman = try AsHuman(reader: reader, ifTypeMatches: __typename)
        asDroid = try AsDroid(reader: reader, ifTypeMatches: __typename)
      }

      public struct AsHuman: GraphQLConditionalFragment {
        public static let possibleTypes = ["Human"]

        public let __typename: String
        public let name: String
        public let friends: [Friend?]?

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          name = try reader.value(for: Field(responseName: "name"))
          friends = try reader.optionalList(for: Field(responseName: "friends"))
        }

        public struct Friend: GraphQLMappable {
          public let __typename: String
          public let name: String

          public let asHuman: AsHuman?

          public init(reader: GraphQLResultReader) throws {
            __typename = try reader.value(for: Field(responseName: "__typename"))
            name = try reader.value(for: Field(responseName: "name"))

            asHuman = try AsHuman(reader: reader, ifTypeMatches: __typename)
          }

          public struct AsHuman: GraphQLConditionalFragment {
            public static let possibleTypes = ["Human"]

            public let __typename: String
            public let name: String
            public let height: Double?

            public init(reader: GraphQLResultReader) throws {
              __typename = try reader.value(for: Field(responseName: "__typename"))
              name = try reader.value(for: Field(responseName: "name"))
              height = try reader.optionalValue(for: Field(responseName: "height", arguments: ["unit": "FOOT"]))
            }
          }
        }
      }

      public struct AsDroid: GraphQLConditionalFragment {
        public static let possibleTypes = ["Droid"]

        public let __typename: String
        public let name: String
        public let friends: [Friend?]?

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          name = try reader.value(for: Field(responseName: "name"))
          friends = try reader.optionalList(for: Field(responseName: "friends"))
        }

        public struct Friend: GraphQLMappable {
          public let __typename: String
          public let name: String

          public let asHuman: AsHuman?

          public init(reader: GraphQLResultReader) throws {
            __typename = try reader.value(for: Field(responseName: "__typename"))
            name = try reader.value(for: Field(responseName: "name"))

            asHuman = try AsHuman(reader: reader, ifTypeMatches: __typename)
          }

          public struct AsHuman: GraphQLConditionalFragment {
            public static let possibleTypes = ["Human"]

            public let __typename: String
            public let name: String
            public let height: Double?

            public init(reader: GraphQLResultReader) throws {
              __typename = try reader.value(for: Field(responseName: "__typename"))
              name = try reader.value(for: Field(responseName: "name"))
              height = try reader.optionalValue(for: Field(responseName: "height", arguments: ["unit": "METER"]))
            }
          }
        }
      }
    }
  }
}

public final class HeroTypeDependentAliasedFieldQuery: GraphQLQuery {
  public static let operationDefinition =
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

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(reader: GraphQLResultReader) throws {
      hero = try reader.optionalValue(for: Field(responseName: "hero", arguments: ["episode": reader.variables["episode"]]))
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String

      public let asHuman: AsHuman?
      public let asDroid: AsDroid?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))

        asHuman = try AsHuman(reader: reader, ifTypeMatches: __typename)
        asDroid = try AsDroid(reader: reader, ifTypeMatches: __typename)
      }

      public struct AsHuman: GraphQLConditionalFragment {
        public static let possibleTypes = ["Human"]

        public let __typename: String
        public let property: String?

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          property = try reader.optionalValue(for: Field(responseName: "property", fieldName: "homePlanet"))
        }
      }

      public struct AsDroid: GraphQLConditionalFragment {
        public static let possibleTypes = ["Droid"]

        public let __typename: String
        public let property: String?

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          property = try reader.optionalValue(for: Field(responseName: "property", fieldName: "primaryFunction"))
        }
      }
    }
  }
}

public final class HumanWithNullMassQuery: GraphQLQuery {
  public static let operationDefinition =
    "query HumanWithNullMass {" +
    "  human(id: 1004) {" +
    "    __typename" +
    "    name" +
    "    mass" +
    "  }" +
    "}"
  public init() {
  }

  public struct Data: GraphQLMappable {
    public let human: Human?

    public init(reader: GraphQLResultReader) throws {
      human = try reader.optionalValue(for: Field(responseName: "human", arguments: ["id": 1004]))
    }

    public struct Human: GraphQLMappable {
      public let __typename: String
      public let name: String
      public let mass: Double?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        name = try reader.value(for: Field(responseName: "name"))
        mass = try reader.optionalValue(for: Field(responseName: "mass"))
      }
    }
  }
}

public final class SameHeroTwiceQuery: GraphQLQuery {
  public static let operationDefinition =
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

  public struct Data: GraphQLMappable {
    public let hero: Hero?
    public let r2: R2?

    public init(reader: GraphQLResultReader) throws {
      hero = try reader.optionalValue(for: Field(responseName: "hero"))
      r2 = try reader.optionalValue(for: Field(responseName: "r2", fieldName: "hero"))
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let name: String

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        name = try reader.value(for: Field(responseName: "name"))
      }
    }

    public struct R2: GraphQLMappable {
      public let __typename: String
      public let appearsIn: [Episode?]

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        appearsIn = try reader.list(for: Field(responseName: "appearsIn"))
      }
    }
  }
}

public final class StarshipQuery: GraphQLQuery {
  public static let operationDefinition =
    "query Starship {" +
    "  starship(id: 3000) {" +
    "    __typename" +
    "    name" +
    "    coordinates" +
    "  }" +
    "}"
  public init() {
  }

  public struct Data: GraphQLMappable {
    public let starship: Starship?

    public init(reader: GraphQLResultReader) throws {
      starship = try reader.optionalValue(for: Field(responseName: "starship", arguments: ["id": 3000]))
    }

    public struct Starship: GraphQLMappable {
      public let __typename: String
      public let name: String
      public let coordinates: [[Double]]?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        name = try reader.value(for: Field(responseName: "name"))
        coordinates = try reader.optionalList(for: Field(responseName: "coordinates"))
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
  public init() {
  }

  public struct Data: GraphQLMappable {
    public let r2: R2?
    public let luke: Luke?

    public init(reader: GraphQLResultReader) throws {
      r2 = try reader.optionalValue(for: Field(responseName: "r2", fieldName: "hero"))
      luke = try reader.optionalValue(for: Field(responseName: "luke", fieldName: "hero", arguments: ["episode": "EMPIRE"]))
    }

    public struct R2: GraphQLMappable {
      public let __typename: String
      public let name: String

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        name = try reader.value(for: Field(responseName: "name"))
      }
    }

    public struct Luke: GraphQLMappable {
      public let __typename: String
      public let name: String

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        name = try reader.value(for: Field(responseName: "name"))
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
    "    __typename" +
    "    height" +
    "  }" +
    "  ... on Droid {" +
    "    __typename" +
    "    primaryFunction" +
    "  }" +
    "}"

  public static let possibleTypes = ["Human", "Droid"]

  public let __typename: String
  public let name: String

  public let asHuman: AsHuman?
  public let asDroid: AsDroid?

  public init(reader: GraphQLResultReader) throws {
    __typename = try reader.value(for: Field(responseName: "__typename"))
    name = try reader.value(for: Field(responseName: "name"))

    asHuman = try AsHuman(reader: reader, ifTypeMatches: __typename)
    asDroid = try AsDroid(reader: reader, ifTypeMatches: __typename)
  }

  public struct AsHuman: GraphQLConditionalFragment {
    public static let possibleTypes = ["Human"]

    public let __typename: String
    public let name: String
    public let height: Double?

    public init(reader: GraphQLResultReader) throws {
      __typename = try reader.value(for: Field(responseName: "__typename"))
      name = try reader.value(for: Field(responseName: "name"))
      height = try reader.optionalValue(for: Field(responseName: "height"))
    }
  }

  public struct AsDroid: GraphQLConditionalFragment {
    public static let possibleTypes = ["Droid"]

    public let __typename: String
    public let name: String
    public let primaryFunction: String?

    public init(reader: GraphQLResultReader) throws {
      __typename = try reader.value(for: Field(responseName: "__typename"))
      name = try reader.value(for: Field(responseName: "name"))
      primaryFunction = try reader.optionalValue(for: Field(responseName: "primaryFunction"))
    }
  }
}