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

  public static let selectionSet: [Selection] = [
    Field("createReview", arguments: ["episode": Variable("episode"), "review": Variable("review")], type: .object(Data.CreateReview.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("stars", type: .nonNull(.scalar(Int.self))),
      Field("commentary", type: .scalar(String.self)),
    ]),
  ]

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

    public init(values: [Any?]) {
      createReview = values[0] as! CreateReview?
    }

    public struct CreateReview: GraphQLMappable {
      public let __typename: String
      public let stars: Int
      public let commentary: String?

      public init(values: [Any?]) {
        __typename = values[0] as! String
        stars = values[1] as! Int
        commentary = values[2] as! String?
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

  public static let selectionSet: [Selection] = [
    Field("createReview", arguments: ["episode": "JEDI", "review": ["stars": 10, "commentary": "This is awesome!"]], type: .object(Data.CreateReview.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("stars", type: .nonNull(.scalar(Int.self))),
      Field("commentary", type: .scalar(String.self)),
    ]),
  ]

  public init() {
  }

  public struct Data: GraphQLMappable {
    public let createReview: CreateReview?

    public init(values: [Any?]) {
      createReview = values[0] as! CreateReview?
    }

    public struct CreateReview: GraphQLMappable {
      public let __typename: String
      public let stars: Int
      public let commentary: String?

      public init(values: [Any?]) {
        __typename = values[0] as! String
        stars = values[1] as! Int
        commentary = values[2] as! String?
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

  public static let selectionSet: [Selection] = [
    Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
      Field("friends", type: .list(.object(Data.Hero.Friend.self)), selectionSet: [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]),
    ]),
  ]

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(values: [Any?]) {
      hero = values[0] as! Hero?
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let name: String
      public let friends: [Friend?]?

      public init(values: [Any?]) {
        __typename = values[0] as! String
        name = values[1] as! String
        friends = values[2] as! [Friend?]?
      }

      public struct Friend: GraphQLMappable {
        public let __typename: String
        public let name: String

        public init(values: [Any?]) {
          __typename = values[0] as! String
          name = values[1] as! String
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

  public static let selectionSet: [Selection] = [
    Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("id", type: .nonNull(.scalar(GraphQLID.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
      Field("friends", type: .list(.object(Data.Hero.Friend.self)), selectionSet: [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("id", type: .nonNull(.scalar(GraphQLID.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]),
    ]),
  ]

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(values: [Any?]) {
      hero = values[0] as! Hero?
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let id: GraphQLID
      public let name: String
      public let friends: [Friend?]?

      public init(values: [Any?]) {
        __typename = values[0] as! String
        id = values[1] as! GraphQLID
        name = values[2] as! String
        friends = values[3] as! [Friend?]?
      }

      public struct Friend: GraphQLMappable {
        public let __typename: String
        public let id: GraphQLID
        public let name: String

        public init(values: [Any?]) {
          __typename = values[0] as! String
          id = values[1] as! GraphQLID
          name = values[2] as! String
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

  public static let selectionSet: [Selection] = [
    Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("id", type: .nonNull(.scalar(GraphQLID.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
      Field("friends", type: .list(.object(Data.Hero.Friend.self)), selectionSet: [
        Field("__typename", type: .nonNull(.scalar(String.self))),
        Field("name", type: .nonNull(.scalar(String.self))),
      ]),
    ]),
  ]

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(values: [Any?]) {
      hero = values[0] as! Hero?
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let id: GraphQLID
      public let name: String
      public let friends: [Friend?]?

      public init(values: [Any?]) {
        __typename = values[0] as! String
        id = values[1] as! GraphQLID
        name = values[2] as! String
        friends = values[3] as! [Friend?]?
      }

      public struct Friend: GraphQLMappable {
        public let __typename: String
        public let name: String

        public init(values: [Any?]) {
          __typename = values[0] as! String
          name = values[1] as! String
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

  public static let selectionSet: [Selection] = [
    Field("hero", type: .object(Data.Hero.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
    ]),
  ]

  public init() {
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(values: [Any?]) {
      hero = values[0] as! Hero?
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let appearsIn: [Episode?]

      public init(values: [Any?]) {
        __typename = values[0] as! String
        appearsIn = values[1] as! [Episode?]
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

  public static let selectionSet: [Selection] = [
    Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
      FragmentSpread(Data.Hero.AsHuman.self),
      FragmentSpread(Data.Hero.AsDroid.self),
    ]),
  ]

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(values: [Any?]) {
      hero = values[0] as! Hero?
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let name: String
      public let asHuman: AsHuman?
      public let asDroid: AsDroid?

      public init(values: [Any?]) {
        __typename = values[0] as! String
        name = values[1] as! String
        asHuman = values[2] as! AsHuman?
        asDroid = values[3] as! AsDroid?
      }

      public struct AsHuman: GraphQLFragment {
        public static let possibleTypes = ["Human"]

        public static let selectionSet: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
          Field("height", type: .scalar(Double.self)),
        ]

        public let __typename: String
        public let name: String
        public let height: Double?

        public init(values: [Any?]) {
          __typename = values[0] as! String
          name = values[1] as! String
          height = values[2] as! Double?
        }
      }

      public struct AsDroid: GraphQLFragment {
        public static let possibleTypes = ["Droid"]

        public static let selectionSet: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
          Field("primaryFunction", type: .scalar(String.self)),
        ]

        public let __typename: String
        public let name: String
        public let primaryFunction: String?

        public init(values: [Any?]) {
          __typename = values[0] as! String
          name = values[1] as! String
          primaryFunction = values[2] as! String?
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

  public static let selectionSet: [Selection] = [
    Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      FragmentSpread(HeroDetails.self),
    ]),
  ]

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(values: [Any?]) {
      hero = values[0] as! Hero?
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String

      public let fragments: Fragments

      public init(values: [Any?]) {
        __typename = values[0] as! String
        let heroDetails = values[1] as! HeroDetails

        fragments = Fragments(heroDetails: heroDetails)
      }

      public struct Fragments {
        public let heroDetails: HeroDetails
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

  public static let selectionSet: [Selection] = [
    Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
    ]),
  ]

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(values: [Any?]) {
      hero = values[0] as! Hero?
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let name: String

      public init(values: [Any?]) {
        __typename = values[0] as! String
        name = values[1] as! String
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

  public static let selectionSet: [Selection] = [
    Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("id", type: .nonNull(.scalar(GraphQLID.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
    ]),
  ]

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(values: [Any?]) {
      hero = values[0] as! Hero?
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let id: GraphQLID
      public let name: String

      public init(values: [Any?]) {
        __typename = values[0] as! String
        id = values[1] as! GraphQLID
        name = values[2] as! String
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

  public static let selectionSet: [Selection] = [
    Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
    ]),
  ]

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

    public init(values: [Any?]) {
      hero = values[0] as! Hero?
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let name: String?

      public init(values: [Any?]) {
        __typename = values[0] as! String
        name = values[1] as! String?
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

  public static let selectionSet: [Selection] = [
    Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
    ]),
  ]

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

    public init(values: [Any?]) {
      hero = values[0] as! Hero?
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let name: String?

      public init(values: [Any?]) {
        __typename = values[0] as! String
        name = values[1] as! String?
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

  public static let selectionSet: [Selection] = [
    Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
      FragmentSpread(Data.Hero.AsHuman.self),
      FragmentSpread(Data.Hero.AsDroid.self),
    ]),
  ]

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(values: [Any?]) {
      hero = values[0] as! Hero?
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let name: String
      public let asHuman: AsHuman?
      public let asDroid: AsDroid?

      public init(values: [Any?]) {
        __typename = values[0] as! String
        name = values[1] as! String
        asHuman = values[2] as! AsHuman?
        asDroid = values[3] as! AsDroid?
      }

      public struct AsHuman: GraphQLFragment {
        public static let possibleTypes = ["Human"]

        public static let selectionSet: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
          Field("friends", type: .list(.object(AsHuman.Friend.self)), selectionSet: [
            Field("__typename", type: .nonNull(.scalar(String.self))),
            Field("name", type: .nonNull(.scalar(String.self))),
            FragmentSpread(AsHuman.Friend.AsHuman.self),
          ]),
        ]

        public let __typename: String
        public let name: String
        public let friends: [Friend?]?

        public init(values: [Any?]) {
          __typename = values[0] as! String
          name = values[1] as! String
          friends = values[2] as! [Friend?]?
        }

        public struct Friend: GraphQLMappable {
          public let __typename: String
          public let name: String
          public let asHuman: AsHuman?

          public init(values: [Any?]) {
            __typename = values[0] as! String
            name = values[1] as! String
            asHuman = values[2] as! AsHuman?
          }

          public struct AsHuman: GraphQLFragment {
            public static let possibleTypes = ["Human"]

            public static let selectionSet: [Selection] = [
              Field("__typename", type: .nonNull(.scalar(String.self))),
              Field("name", type: .nonNull(.scalar(String.self))),
              Field("height", arguments: ["unit": "FOOT"], type: .scalar(Double.self)),
            ]

            public let __typename: String
            public let name: String
            public let height: Double?

            public init(values: [Any?]) {
              __typename = values[0] as! String
              name = values[1] as! String
              height = values[2] as! Double?
            }
          }
        }
      }

      public struct AsDroid: GraphQLFragment {
        public static let possibleTypes = ["Droid"]

        public static let selectionSet: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("name", type: .nonNull(.scalar(String.self))),
          Field("friends", type: .list(.object(AsDroid.Friend.self)), selectionSet: [
            Field("__typename", type: .nonNull(.scalar(String.self))),
            Field("name", type: .nonNull(.scalar(String.self))),
            FragmentSpread(AsDroid.Friend.AsHuman.self),
          ]),
        ]

        public let __typename: String
        public let name: String
        public let friends: [Friend?]?

        public init(values: [Any?]) {
          __typename = values[0] as! String
          name = values[1] as! String
          friends = values[2] as! [Friend?]?
        }

        public struct Friend: GraphQLMappable {
          public let __typename: String
          public let name: String
          public let asHuman: AsHuman?

          public init(values: [Any?]) {
            __typename = values[0] as! String
            name = values[1] as! String
            asHuman = values[2] as! AsHuman?
          }

          public struct AsHuman: GraphQLFragment {
            public static let possibleTypes = ["Human"]

            public static let selectionSet: [Selection] = [
              Field("__typename", type: .nonNull(.scalar(String.self))),
              Field("name", type: .nonNull(.scalar(String.self))),
              Field("height", arguments: ["unit": "METER"], type: .scalar(Double.self)),
            ]

            public let __typename: String
            public let name: String
            public let height: Double?

            public init(values: [Any?]) {
              __typename = values[0] as! String
              name = values[1] as! String
              height = values[2] as! Double?
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

  public static let selectionSet: [Selection] = [
    Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      FragmentSpread(Data.Hero.AsHuman.self),
      FragmentSpread(Data.Hero.AsDroid.self),
    ]),
  ]

  public let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?

    public init(values: [Any?]) {
      hero = values[0] as! Hero?
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let asHuman: AsHuman?
      public let asDroid: AsDroid?

      public init(values: [Any?]) {
        __typename = values[0] as! String
        asHuman = values[1] as! AsHuman?
        asDroid = values[2] as! AsDroid?
      }

      public struct AsHuman: GraphQLFragment {
        public static let possibleTypes = ["Human"]

        public static let selectionSet: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("homePlanet", alias: "property", type: .scalar(String.self)),
        ]

        public let __typename: String
        public let property: String?

        public init(values: [Any?]) {
          __typename = values[0] as! String
          property = values[1] as! String?
        }
      }

      public struct AsDroid: GraphQLFragment {
        public static let possibleTypes = ["Droid"]

        public static let selectionSet: [Selection] = [
          Field("__typename", type: .nonNull(.scalar(String.self))),
          Field("primaryFunction", alias: "property", type: .scalar(String.self)),
        ]

        public let __typename: String
        public let property: String?

        public init(values: [Any?]) {
          __typename = values[0] as! String
          property = values[1] as! String?
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

  public static let selectionSet: [Selection] = [
    Field("human", arguments: ["id": 1004], type: .object(Data.Human.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
      Field("mass", type: .scalar(Double.self)),
    ]),
  ]

  public init() {
  }

  public struct Data: GraphQLMappable {
    public let human: Human?

    public init(values: [Any?]) {
      human = values[0] as! Human?
    }

    public struct Human: GraphQLMappable {
      public let __typename: String
      public let name: String
      public let mass: Double?

      public init(values: [Any?]) {
        __typename = values[0] as! String
        name = values[1] as! String
        mass = values[2] as! Double?
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

  public static let selectionSet: [Selection] = [
    Field("hero", type: .object(Data.Hero.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
    ]),
    Field("hero", alias: "r2", type: .object(Data.R2.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("appearsIn", type: .nonNull(.list(.scalar(Episode.self)))),
    ]),
  ]

  public init() {
  }

  public struct Data: GraphQLMappable {
    public let hero: Hero?
    public let r2: R2?

    public init(values: [Any?]) {
      hero = values[0] as! Hero?
      r2 = values[1] as! R2?
    }

    public struct Hero: GraphQLMappable {
      public let __typename: String
      public let name: String

      public init(values: [Any?]) {
        __typename = values[0] as! String
        name = values[1] as! String
      }
    }

    public struct R2: GraphQLMappable {
      public let __typename: String
      public let appearsIn: [Episode?]

      public init(values: [Any?]) {
        __typename = values[0] as! String
        appearsIn = values[1] as! [Episode?]
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

  public static let selectionSet: [Selection] = [
    Field("starship", arguments: ["id": 3000], type: .object(Data.Starship.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
      Field("coordinates", type: .list(.nonNull(.list(.nonNull(.scalar(Double.self)))))),
    ]),
  ]

  public init() {
  }

  public struct Data: GraphQLMappable {
    public let starship: Starship?

    public init(values: [Any?]) {
      starship = values[0] as! Starship?
    }

    public struct Starship: GraphQLMappable {
      public let __typename: String
      public let name: String
      public let coordinates: [[Double]]?

      public init(values: [Any?]) {
        __typename = values[0] as! String
        name = values[1] as! String
        coordinates = values[2] as! [[Double]]?
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

  public static let selectionSet: [Selection] = [
    Field("hero", alias: "r2", type: .object(Data.R2.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
    ]),
    Field("hero", alias: "luke", arguments: ["episode": "EMPIRE"], type: .object(Data.Luke.self), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
    ]),
  ]

  public init() {
  }

  public struct Data: GraphQLMappable {
    public let r2: R2?
    public let luke: Luke?

    public init(values: [Any?]) {
      r2 = values[0] as! R2?
      luke = values[1] as! Luke?
    }

    public struct R2: GraphQLMappable {
      public let __typename: String
      public let name: String

      public init(values: [Any?]) {
        __typename = values[0] as! String
        name = values[1] as! String
      }
    }

    public struct Luke: GraphQLMappable {
      public let __typename: String
      public let name: String

      public init(values: [Any?]) {
        __typename = values[0] as! String
        name = values[1] as! String
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

  public static let selectionSet: [Selection] = [
    Field("__typename", type: .nonNull(.scalar(String.self))),
    Field("name", type: .nonNull(.scalar(String.self))),
    FragmentSpread(HeroDetails.AsHuman.self),
    FragmentSpread(HeroDetails.AsDroid.self),
  ]

  public let __typename: String
  public let name: String
  public let asHuman: AsHuman?
  public let asDroid: AsDroid?

  public init(values: [Any?]) {
    __typename = values[0] as! String
    name = values[1] as! String
    asHuman = values[2] as! AsHuman?
    asDroid = values[3] as! AsDroid?
  }

  public struct AsHuman: GraphQLFragment {
    public static let possibleTypes = ["Human"]

    public static let selectionSet: [Selection] = [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
      Field("height", type: .scalar(Double.self)),
    ]

    public let __typename: String
    public let name: String
    public let height: Double?

    public init(values: [Any?]) {
      __typename = values[0] as! String
      name = values[1] as! String
      height = values[2] as! Double?
    }
  }

  public struct AsDroid: GraphQLFragment {
    public static let possibleTypes = ["Droid"]

    public static let selectionSet: [Selection] = [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("name", type: .nonNull(.scalar(String.self))),
      Field("primaryFunction", type: .scalar(String.self)),
    ]

    public let __typename: String
    public let name: String
    public let primaryFunction: String?

    public init(values: [Any?]) {
      __typename = values[0] as! String
      name = values[1] as! String
      primaryFunction = values[2] as! String?
    }
  }
}