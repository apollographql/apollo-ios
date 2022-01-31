// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public struct WarmBloodedDetails: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment WarmBloodedDetails on WarmBlooded {
      __typename
      bodyTemperature
      height {
        __typename
        meters
        yards
      }
    }
    """

  public static let possibleTypes: [String] = ["Human", "Cat", "Dog", "Bird"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("bodyTemperature", type: .nonNull(.scalar(Int.self))),
      GraphQLField("height", type: .nonNull(.object(Height.selections))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeHuman(bodyTemperature: Int, height: Height) -> WarmBloodedDetails {
    return WarmBloodedDetails(unsafeResultMap: ["__typename": "Human", "bodyTemperature": bodyTemperature, "height": height.resultMap])
  }

  public static func makeCat(bodyTemperature: Int, height: Height) -> WarmBloodedDetails {
    return WarmBloodedDetails(unsafeResultMap: ["__typename": "Cat", "bodyTemperature": bodyTemperature, "height": height.resultMap])
  }

  public static func makeDog(bodyTemperature: Int, height: Height) -> WarmBloodedDetails {
    return WarmBloodedDetails(unsafeResultMap: ["__typename": "Dog", "bodyTemperature": bodyTemperature, "height": height.resultMap])
  }

  public static func makeBird(bodyTemperature: Int, height: Height) -> WarmBloodedDetails {
    return WarmBloodedDetails(unsafeResultMap: ["__typename": "Bird", "bodyTemperature": bodyTemperature, "height": height.resultMap])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var bodyTemperature: Int {
    get {
      return resultMap["bodyTemperature"]! as! Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "bodyTemperature")
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
        GraphQLField("yards", type: .nonNull(.scalar(Int.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(meters: Int, yards: Int) {
      self.init(unsafeResultMap: ["__typename": "Height", "meters": meters, "yards": yards])
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

    public var yards: Int {
      get {
        return resultMap["yards"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "yards")
      }
    }
  }
}
