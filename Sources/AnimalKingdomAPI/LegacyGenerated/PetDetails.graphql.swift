// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public struct PetDetails: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment PetDetails on Pet {
      __typename
      humanName
      favoriteToy
      owner {
        __typename
        firstName
      }
    }
    """

  public static let possibleTypes: [String] = ["Cat", "Dog", "Bird", "Fish", "Rat", "PetRock"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("humanName", type: .scalar(String.self)),
      GraphQLField("favoriteToy", type: .nonNull(.scalar(String.self))),
      GraphQLField("owner", type: .object(Owner.selections)),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeCat(humanName: String? = nil, favoriteToy: String, owner: Owner? = nil) -> PetDetails {
    return PetDetails(unsafeResultMap: ["__typename": "Cat", "humanName": humanName, "favoriteToy": favoriteToy, "owner": owner.flatMap { (value: Owner) -> ResultMap in value.resultMap }])
  }

  public static func makeDog(humanName: String? = nil, favoriteToy: String, owner: Owner? = nil) -> PetDetails {
    return PetDetails(unsafeResultMap: ["__typename": "Dog", "humanName": humanName, "favoriteToy": favoriteToy, "owner": owner.flatMap { (value: Owner) -> ResultMap in value.resultMap }])
  }

  public static func makeBird(humanName: String? = nil, favoriteToy: String, owner: Owner? = nil) -> PetDetails {
    return PetDetails(unsafeResultMap: ["__typename": "Bird", "humanName": humanName, "favoriteToy": favoriteToy, "owner": owner.flatMap { (value: Owner) -> ResultMap in value.resultMap }])
  }

  public static func makeFish(humanName: String? = nil, favoriteToy: String, owner: Owner? = nil) -> PetDetails {
    return PetDetails(unsafeResultMap: ["__typename": "Fish", "humanName": humanName, "favoriteToy": favoriteToy, "owner": owner.flatMap { (value: Owner) -> ResultMap in value.resultMap }])
  }

  public static func makeRat(humanName: String? = nil, favoriteToy: String, owner: Owner? = nil) -> PetDetails {
    return PetDetails(unsafeResultMap: ["__typename": "Rat", "humanName": humanName, "favoriteToy": favoriteToy, "owner": owner.flatMap { (value: Owner) -> ResultMap in value.resultMap }])
  }

  public static func makePetRock(humanName: String? = nil, favoriteToy: String, owner: Owner? = nil) -> PetDetails {
    return PetDetails(unsafeResultMap: ["__typename": "PetRock", "humanName": humanName, "favoriteToy": favoriteToy, "owner": owner.flatMap { (value: Owner) -> ResultMap in value.resultMap }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var humanName: String? {
    get {
      return resultMap["humanName"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "humanName")
    }
  }

  public var favoriteToy: String {
    get {
      return resultMap["favoriteToy"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "favoriteToy")
    }
  }

  public var owner: Owner? {
    get {
      return (resultMap["owner"] as? ResultMap).flatMap { Owner(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "owner")
    }
  }

  public struct Owner: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Human"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(firstName: String) {
      self.init(unsafeResultMap: ["__typename": "Human", "firstName": firstName])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var firstName: String {
      get {
        return resultMap["firstName"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "firstName")
      }
    }
  }
}
