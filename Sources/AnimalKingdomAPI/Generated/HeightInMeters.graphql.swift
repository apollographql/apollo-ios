// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public struct HeightInMeters: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment HeightInMeters on Animal {
      __typename
      height {
        __typename
        meters
      }
    }
    """

  public static let possibleTypes: [String] = ["Human", "Cat", "Dog", "Bird", "Fish", "Rat", "Crocodile"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("height", type: .nonNull(.object(Height.selections))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeHuman(height: Height) -> HeightInMeters {
    return HeightInMeters(unsafeResultMap: ["__typename": "Human", "height": height.resultMap])
  }

  public static func makeCat(height: Height) -> HeightInMeters {
    return HeightInMeters(unsafeResultMap: ["__typename": "Cat", "height": height.resultMap])
  }

  public static func makeDog(height: Height) -> HeightInMeters {
    return HeightInMeters(unsafeResultMap: ["__typename": "Dog", "height": height.resultMap])
  }

  public static func makeBird(height: Height) -> HeightInMeters {
    return HeightInMeters(unsafeResultMap: ["__typename": "Bird", "height": height.resultMap])
  }

  public static func makeFish(height: Height) -> HeightInMeters {
    return HeightInMeters(unsafeResultMap: ["__typename": "Fish", "height": height.resultMap])
  }

  public static func makeRat(height: Height) -> HeightInMeters {
    return HeightInMeters(unsafeResultMap: ["__typename": "Rat", "height": height.resultMap])
  }

  public static func makeCrocodile(height: Height) -> HeightInMeters {
    return HeightInMeters(unsafeResultMap: ["__typename": "Crocodile", "height": height.resultMap])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var height: Height {
    get {
      return Height(unsafeResultMap: resultMap["height"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "height")
    }
  }

  public struct Height: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Height"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("meters", type: .nonNull(.scalar(Int.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(meters: Int) {
      self.init(unsafeResultMap: ["__typename": "Height", "meters": meters])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var meters: Int {
      get {
        return resultMap["meters"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "meters")
      }
    }
  }
}
