//  This file was automatically generated and should not be edited.

import Apollo

public enum Episode: String {
  case newhope = "NEWHOPE"
  case empire = "EMPIRE"
  case jedi = "JEDI"
}

extension Episode: JSONDecodable, JSONEncodable {}

public final class HeroAndFriendsNamesQuery: GraphQLQuery {
  public let episode: Episode?
  
  public init(episode: Episode? = nil) {
    self.episode = episode
  }
  
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
  
  public var variables: GraphQLMap? {
    return ["episode": episode]
  }
  
  public struct Data: GraphQLMapConvertible {
    public let hero: Hero?
    
    public init(map: GraphQLMap) throws {
      hero = try map.optionalValue(forKey: "hero")
    }
    
    public struct Hero: GraphQLMapConvertible {
      public let name: String
      public let friends: [Friend?]?
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
        friends = try map.optionalList(forKey: "friends")
      }
      
      public struct Friend: GraphQLMapConvertible {
        public let name: String
        
        public init(map: GraphQLMap) throws {
          name = try map.value(forKey: "name")
        }
      }
    }
  }
}

public final class HeroAppearsInQuery: GraphQLQuery {
  public init() {}
  
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
      public let name: String
      public let appearsIn: [Episode?]
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
        appearsIn = try map.list(forKey: "appearsIn")
      }
    }
  }
}

public final class HeroDetailsQuery: GraphQLQuery {
  public let episode: Episode?
  
  public init(episode: Episode? = nil) {
    self.episode = episode
  }
  
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
  
  public var variables: GraphQLMap? {
    return ["episode": episode]
  }
  
  public struct Data: GraphQLMapConvertible {
    public let hero: Hero?
    
    public init(map: GraphQLMap) throws {
      hero = try map.optionalValue(forKey: "hero", baseType: Hero$Base.self, subTypes: ["Human": Hero$Human.self, "Droid": Hero$Droid.self])
    }
    
    public typealias Hero = HeroDetailsQuery_Data_Hero
    
    public struct Hero$Base: GraphQLMapConvertible, Hero {
      public let name: String
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
      }
    }
    
    public struct Hero$Human: GraphQLMapConvertible, Hero {
      public let name: String
      public let height: Float?
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
        height = try map.optionalValue(forKey: "height")
      }
    }
    
    public struct Hero$Droid: GraphQLMapConvertible, Hero {
      public let name: String
      public let primaryFunction: String?
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
        primaryFunction = try map.optionalValue(forKey: "primaryFunction")
      }
    }
  }
}

public protocol HeroDetailsQuery_Data_Hero {
  var name: String { get }
}

public extension HeroDetailsQuery_Data_Hero {
  var isHuman: Bool { return self is HeroDetailsQuery.Data.Hero$Human }
  var asHuman: HeroDetailsQuery.Data.Hero$Human? { return self as? HeroDetailsQuery.Data.Hero$Human }
  var isDroid: Bool { return self is HeroDetailsQuery.Data.Hero$Droid }
  var asDroid: HeroDetailsQuery.Data.Hero$Droid? { return self as? HeroDetailsQuery.Data.Hero$Droid }
}

public final class HeroDetailsWithFragmentQuery: GraphQLQuery {
  public let episode: Episode?
  
  public init(episode: Episode? = nil) {
    self.episode = episode
  }
  
  public static let operationDefinition =
    "query HeroDetailsWithFragment($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    __typename" +
    "    ...HeroDetails" +
    "  }" +
    "}"
  
  public static let queryDocument = operationDefinition.appending(HeroDetailsFragment.fragmentDefinition)
  
  public var variables: GraphQLMap? {
    return ["episode": episode]
  }
  
  public struct Data: GraphQLMapConvertible {
    public let hero: Hero?
    
    public init(map: GraphQLMap) throws {
      hero = try map.optionalValue(forKey: "hero", baseType: Hero$Base.self, subTypes: ["Human": Hero$Human.self, "Droid": Hero$Droid.self])
    }
    
    public typealias Hero = HeroDetailsWithFragmentQuery_Data_Hero
    
    public struct Hero$Base: GraphQLMapConvertible, Hero {
      public let name: String
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
      }
    }
    
    public struct Hero$Human: GraphQLMapConvertible, Hero {
      public let name: String
      public let height: Float?
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
        height = try map.optionalValue(forKey: "height")
      }
    }
    
    public struct Hero$Droid: GraphQLMapConvertible, Hero {
      public let name: String
      public let primaryFunction: String?
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
        primaryFunction = try map.optionalValue(forKey: "primaryFunction")
      }
    }
  }
}

public protocol HeroDetailsWithFragmentQuery_Data_Hero: HeroDetails {
  var name: String { get }
}

public extension HeroDetailsWithFragmentQuery_Data_Hero {
  var isHuman: Bool { return self is HeroDetailsWithFragmentQuery.Data.Hero$Human }
  var asHuman: HeroDetailsWithFragmentQuery.Data.Hero$Human? { return self as? HeroDetailsWithFragmentQuery.Data.Hero$Human }
  var isDroid: Bool { return self is HeroDetailsWithFragmentQuery.Data.Hero$Droid }
  var asDroid: HeroDetailsWithFragmentQuery.Data.Hero$Droid? { return self as? HeroDetailsWithFragmentQuery.Data.Hero$Droid }
}

public final class HeroNameQuery: GraphQLQuery {
  public init() {}
  
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
      public let name: String
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
      }
    }
  }
}

public final class TwoHeroesQuery: GraphQLQuery {
  public init() {}
  
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
      public let name: String
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
      }
    }
    
    public struct Luke: GraphQLMapConvertible {
      public let name: String
      
      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
      }
    }
  }
}

public final class HeroDetailsFragment: GraphQLFragment {
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
    
  public typealias Data = HeroDetails
}

public protocol HeroDetails {
  var name: String { get }
}
