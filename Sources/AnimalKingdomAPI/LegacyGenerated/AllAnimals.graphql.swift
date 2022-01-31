// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class AllAnimalsQueryQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query AllAnimalsQuery {
      allAnimals {
        __typename
        height {
          __typename
          feet
          inches
        }
        ...HeightInMeters
        ...WarmBloodedDetails
        species
        skinCovering
        ... on Pet {
          ...PetDetails
          ...WarmBloodedDetails
          ... on Animal {
            height {
              __typename
              relativeSize
              centimeters
            }
          }
        }
        ... on Cat {
          isJellicle
        }
        ... on ClassroomPet {
          ... on Bird {
            wingspan
          }
        }
        predators {
          __typename
          species
          ... on WarmBlooded {
            ...WarmBloodedDetails
            laysEggs
          }
        }
      }
    }
    """

  public let operationName: String = "AllAnimalsQuery"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + HeightInMeters.fragmentDefinition)
    document.append("\n" + WarmBloodedDetails.fragmentDefinition)
    document.append("\n" + PetDetails.fragmentDefinition)
    return document
  }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("allAnimals", type: .nonNull(.list(.nonNull(.object(AllAnimal.selections))))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(allAnimals: [AllAnimal]) {
      self.init(unsafeResultMap: ["__typename": "Query", "allAnimals": allAnimals.map { (value: AllAnimal) -> ResultMap in value.resultMap }])
    }

    public var allAnimals: [AllAnimal] {
      get {
        return (resultMap["allAnimals"] as! [ResultMap]).map { (value: ResultMap) -> AllAnimal in AllAnimal(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: AllAnimal) -> ResultMap in value.resultMap }, forKey: "allAnimals")
      }
    }

    public struct AllAnimal: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Human", "Cat", "Dog", "Bird", "Fish", "Rat", "Crocodile"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLTypeCase(
            variants: ["Human": AsHuman.selections, "Cat": AsCat.selections, "Dog": AsDog.selections, "Bird": AsBird.selections, "Fish": AsFishOrRat.selections, "Rat": AsFishOrRat.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("height", type: .nonNull(.object(Height.selections))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("height", type: .nonNull(.object(Height.selections))),
              GraphQLField("species", type: .nonNull(.scalar(String.self))),
              GraphQLField("skinCovering", type: .scalar(SkinCovering.self)),
              GraphQLField("predators", type: .nonNull(.list(.nonNull(.object(Predator.selections))))),
            ]
          )
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
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

      public var species: String {
        get {
          return resultMap["species"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "species")
        }
      }

      public var skinCovering: SkinCovering? {
        get {
          return resultMap["skinCovering"] as? SkinCovering
        }
        set {
          resultMap.updateValue(newValue, forKey: "skinCovering")
        }
      }

      public var predators: [Predator] {
        get {
          return (resultMap["predators"] as! [ResultMap]).map { (value: ResultMap) -> Predator in Predator(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Predator) -> ResultMap in value.resultMap }, forKey: "predators")
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

        public var heightInMeters: HeightInMeters {
          get {
            return HeightInMeters(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public var warmBloodedDetails: WarmBloodedDetails? {
          get {
            if !WarmBloodedDetails.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return WarmBloodedDetails(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }
      }

      public struct Height: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Height"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("feet", type: .nonNull(.scalar(Int.self))),
            GraphQLField("inches", type: .nonNull(.scalar(Int.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("meters", type: .nonNull(.scalar(Int.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(feet: Int, inches: Int, meters: Int) {
          self.init(unsafeResultMap: ["__typename": "Height", "feet": feet, "inches": inches, "meters": meters])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var feet: Int {
          get {
            return resultMap["feet"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "feet")
          }
        }

        public var inches: Int {
          get {
            return resultMap["inches"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "inches")
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

      public struct Predator: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Human", "Cat", "Dog", "Bird", "Fish", "Rat", "Crocodile"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLTypeCase(
              variants: ["Human": AsHumanOrCatOrDogOrBird.selections, "Cat": AsHumanOrCatOrDogOrBird.selections, "Dog": AsHumanOrCatOrDogOrBird.selections, "Bird": AsHumanOrCatOrDogOrBird.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("species", type: .nonNull(.scalar(String.self))),
              ]
            )
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeFish(species: String) -> Predator {
          return Predator(unsafeResultMap: ["__typename": "Fish", "species": species])
        }

        public static func makeRat(species: String) -> Predator {
          return Predator(unsafeResultMap: ["__typename": "Rat", "species": species])
        }

        public static func makeCrocodile(species: String) -> Predator {
          return Predator(unsafeResultMap: ["__typename": "Crocodile", "species": species])
        }

        public static func makeHuman(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
          return Predator(unsafeResultMap: ["__typename": "Human", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
        }

        public static func makeCat(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
          return Predator(unsafeResultMap: ["__typename": "Cat", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
        }

        public static func makeDog(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
          return Predator(unsafeResultMap: ["__typename": "Dog", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
        }

        public static func makeBird(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
          return Predator(unsafeResultMap: ["__typename": "Bird", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var species: String {
          get {
            return resultMap["species"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "species")
          }
        }

        public var asHumanOrCatOrDogOrBird: AsHumanOrCatOrDogOrBird? {
          get {
            if !AsHumanOrCatOrDogOrBird.possibleTypes.contains(__typename) { return nil }
            return AsHumanOrCatOrDogOrBird(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsHumanOrCatOrDogOrBird: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Human", "Cat", "Dog", "Bird"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("species", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("bodyTemperature", type: .nonNull(.scalar(Int.self))),
              GraphQLField("height", type: .nonNull(.object(Height.selections))),
              GraphQLField("laysEggs", type: .nonNull(.scalar(Bool.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeHuman(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
            return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Human", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeCat(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
            return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Cat", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeDog(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
            return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Dog", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeBird(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
            return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Bird", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var species: String {
            get {
              return resultMap["species"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "species")
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

          public var laysEggs: Bool {
            get {
              return resultMap["laysEggs"]! as! Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "laysEggs")
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

            public var warmBloodedDetails: WarmBloodedDetails {
              get {
                return WarmBloodedDetails(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
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
        public static let possibleTypes: [String] = ["Human"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("bodyTemperature", type: .nonNull(.scalar(Int.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("species", type: .nonNull(.scalar(String.self))),
            GraphQLField("skinCovering", type: .scalar(SkinCovering.self)),
            GraphQLField("predators", type: .nonNull(.list(.nonNull(.object(Predator.selections))))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(height: Height, bodyTemperature: Int, species: String, skinCovering: SkinCovering? = nil, predators: [Predator]) {
          self.init(unsafeResultMap: ["__typename": "Human", "height": height.resultMap, "bodyTemperature": bodyTemperature, "species": species, "skinCovering": skinCovering, "predators": predators.map { (value: Predator) -> ResultMap in value.resultMap }])
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

        public var bodyTemperature: Int {
          get {
            return resultMap["bodyTemperature"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "bodyTemperature")
          }
        }

        public var species: String {
          get {
            return resultMap["species"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "species")
          }
        }

        public var skinCovering: SkinCovering? {
          get {
            return resultMap["skinCovering"] as? SkinCovering
          }
          set {
            resultMap.updateValue(newValue, forKey: "skinCovering")
          }
        }

        public var predators: [Predator] {
          get {
            return (resultMap["predators"] as! [ResultMap]).map { (value: ResultMap) -> Predator in Predator(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: Predator) -> ResultMap in value.resultMap }, forKey: "predators")
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

          public var heightInMeters: HeightInMeters {
            get {
              return HeightInMeters(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public var warmBloodedDetails: WarmBloodedDetails {
            get {
              return WarmBloodedDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Height: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Height"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("feet", type: .nonNull(.scalar(Int.self))),
              GraphQLField("inches", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("meters", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("meters", type: .nonNull(.scalar(Int.self))),
              GraphQLField("yards", type: .nonNull(.scalar(Int.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(feet: Int, inches: Int, meters: Int, yards: Int) {
            self.init(unsafeResultMap: ["__typename": "Height", "feet": feet, "inches": inches, "meters": meters, "yards": yards])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var feet: Int {
            get {
              return resultMap["feet"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "feet")
            }
          }

          public var inches: Int {
            get {
              return resultMap["inches"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "inches")
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

        public struct Predator: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Human", "Cat", "Dog", "Bird", "Fish", "Rat", "Crocodile"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLTypeCase(
                variants: ["Human": AsHumanOrCatOrDogOrBird.selections, "Cat": AsHumanOrCatOrDogOrBird.selections, "Dog": AsHumanOrCatOrDogOrBird.selections, "Bird": AsHumanOrCatOrDogOrBird.selections],
                default: [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("species", type: .nonNull(.scalar(String.self))),
                ]
              )
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeFish(species: String) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Fish", "species": species])
          }

          public static func makeRat(species: String) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Rat", "species": species])
          }

          public static func makeCrocodile(species: String) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Crocodile", "species": species])
          }

          public static func makeHuman(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Human", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeCat(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Cat", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeDog(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Dog", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeBird(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Bird", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var species: String {
            get {
              return resultMap["species"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "species")
            }
          }

          public var asHumanOrCatOrDogOrBird: AsHumanOrCatOrDogOrBird? {
            get {
              if !AsHumanOrCatOrDogOrBird.possibleTypes.contains(__typename) { return nil }
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsHumanOrCatOrDogOrBird: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Human", "Cat", "Dog", "Bird"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("species", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("bodyTemperature", type: .nonNull(.scalar(Int.self))),
                GraphQLField("height", type: .nonNull(.object(Height.selections))),
                GraphQLField("laysEggs", type: .nonNull(.scalar(Bool.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public static func makeHuman(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Human", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public static func makeCat(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Cat", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public static func makeDog(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Dog", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public static func makeBird(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Bird", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var species: String {
              get {
                return resultMap["species"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "species")
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

            public var laysEggs: Bool {
              get {
                return resultMap["laysEggs"]! as! Bool
              }
              set {
                resultMap.updateValue(newValue, forKey: "laysEggs")
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

              public var warmBloodedDetails: WarmBloodedDetails {
                get {
                  return WarmBloodedDetails(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
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
        }
      }

      public var asCat: AsCat? {
        get {
          if !AsCat.possibleTypes.contains(__typename) { return nil }
          return AsCat(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsCat: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Cat"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("bodyTemperature", type: .nonNull(.scalar(Int.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("species", type: .nonNull(.scalar(String.self))),
            GraphQLField("skinCovering", type: .scalar(SkinCovering.self)),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("humanName", type: .scalar(String.self)),
            GraphQLField("favoriteToy", type: .nonNull(.scalar(String.self))),
            GraphQLField("owner", type: .object(Owner.selections)),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("humanName", type: .scalar(String.self)),
            GraphQLField("favoriteToy", type: .nonNull(.scalar(String.self))),
            GraphQLField("owner", type: .object(Owner.selections)),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("bodyTemperature", type: .nonNull(.scalar(Int.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("isJellicle", type: .nonNull(.scalar(Bool.self))),
            GraphQLField("predators", type: .nonNull(.list(.nonNull(.object(Predator.selections))))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(height: Height, bodyTemperature: Int, species: String, skinCovering: SkinCovering? = nil, humanName: String? = nil, favoriteToy: String, owner: Owner? = nil, isJellicle: Bool, predators: [Predator]) {
          self.init(unsafeResultMap: ["__typename": "Cat", "height": height.resultMap, "bodyTemperature": bodyTemperature, "species": species, "skinCovering": skinCovering, "humanName": humanName, "favoriteToy": favoriteToy, "owner": owner.flatMap { (value: Owner) -> ResultMap in value.resultMap }, "isJellicle": isJellicle, "predators": predators.map { (value: Predator) -> ResultMap in value.resultMap }])
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

        public var bodyTemperature: Int {
          get {
            return resultMap["bodyTemperature"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "bodyTemperature")
          }
        }

        public var species: String {
          get {
            return resultMap["species"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "species")
          }
        }

        public var skinCovering: SkinCovering? {
          get {
            return resultMap["skinCovering"] as? SkinCovering
          }
          set {
            resultMap.updateValue(newValue, forKey: "skinCovering")
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

        public var isJellicle: Bool {
          get {
            return resultMap["isJellicle"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "isJellicle")
          }
        }

        public var predators: [Predator] {
          get {
            return (resultMap["predators"] as! [ResultMap]).map { (value: ResultMap) -> Predator in Predator(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: Predator) -> ResultMap in value.resultMap }, forKey: "predators")
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

          public var heightInMeters: HeightInMeters {
            get {
              return HeightInMeters(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public var warmBloodedDetails: WarmBloodedDetails {
            get {
              return WarmBloodedDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public var petDetails: PetDetails {
            get {
              return PetDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Height: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Height"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("feet", type: .nonNull(.scalar(Int.self))),
              GraphQLField("inches", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("meters", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("meters", type: .nonNull(.scalar(Int.self))),
              GraphQLField("yards", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("relativeSize", type: .nonNull(.scalar(RelativeSize.self))),
              GraphQLField("centimeters", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("meters", type: .nonNull(.scalar(Int.self))),
              GraphQLField("yards", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("relativeSize", type: .nonNull(.scalar(RelativeSize.self))),
              GraphQLField("centimeters", type: .nonNull(.scalar(Int.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(feet: Int, inches: Int, meters: Int, yards: Int, relativeSize: RelativeSize, centimeters: Int) {
            self.init(unsafeResultMap: ["__typename": "Height", "feet": feet, "inches": inches, "meters": meters, "yards": yards, "relativeSize": relativeSize, "centimeters": centimeters])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var feet: Int {
            get {
              return resultMap["feet"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "feet")
            }
          }

          public var inches: Int {
            get {
              return resultMap["inches"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "inches")
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

          public var relativeSize: RelativeSize {
            get {
              return resultMap["relativeSize"]! as! RelativeSize
            }
            set {
              resultMap.updateValue(newValue, forKey: "relativeSize")
            }
          }

          public var centimeters: Int {
            get {
              return resultMap["centimeters"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "centimeters")
            }
          }
        }

        public struct Owner: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Human"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
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

        public struct Predator: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Human", "Cat", "Dog", "Bird", "Fish", "Rat", "Crocodile"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLTypeCase(
                variants: ["Human": AsHumanOrCatOrDogOrBird.selections, "Cat": AsHumanOrCatOrDogOrBird.selections, "Dog": AsHumanOrCatOrDogOrBird.selections, "Bird": AsHumanOrCatOrDogOrBird.selections],
                default: [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("species", type: .nonNull(.scalar(String.self))),
                ]
              )
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeFish(species: String) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Fish", "species": species])
          }

          public static func makeRat(species: String) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Rat", "species": species])
          }

          public static func makeCrocodile(species: String) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Crocodile", "species": species])
          }

          public static func makeHuman(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Human", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeCat(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Cat", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeDog(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Dog", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeBird(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Bird", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var species: String {
            get {
              return resultMap["species"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "species")
            }
          }

          public var asHumanOrCatOrDogOrBird: AsHumanOrCatOrDogOrBird? {
            get {
              if !AsHumanOrCatOrDogOrBird.possibleTypes.contains(__typename) { return nil }
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsHumanOrCatOrDogOrBird: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Human", "Cat", "Dog", "Bird"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("species", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("bodyTemperature", type: .nonNull(.scalar(Int.self))),
                GraphQLField("height", type: .nonNull(.object(Height.selections))),
                GraphQLField("laysEggs", type: .nonNull(.scalar(Bool.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public static func makeHuman(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Human", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public static func makeCat(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Cat", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public static func makeDog(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Dog", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public static func makeBird(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Bird", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var species: String {
              get {
                return resultMap["species"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "species")
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

            public var laysEggs: Bool {
              get {
                return resultMap["laysEggs"]! as! Bool
              }
              set {
                resultMap.updateValue(newValue, forKey: "laysEggs")
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

              public var warmBloodedDetails: WarmBloodedDetails {
                get {
                  return WarmBloodedDetails(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
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
        }
      }

      public var asDog: AsDog? {
        get {
          if !AsDog.possibleTypes.contains(__typename) { return nil }
          return AsDog(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsDog: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Dog"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("bodyTemperature", type: .nonNull(.scalar(Int.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("species", type: .nonNull(.scalar(String.self))),
            GraphQLField("skinCovering", type: .scalar(SkinCovering.self)),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("humanName", type: .scalar(String.self)),
            GraphQLField("favoriteToy", type: .nonNull(.scalar(String.self))),
            GraphQLField("owner", type: .object(Owner.selections)),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("humanName", type: .scalar(String.self)),
            GraphQLField("favoriteToy", type: .nonNull(.scalar(String.self))),
            GraphQLField("owner", type: .object(Owner.selections)),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("bodyTemperature", type: .nonNull(.scalar(Int.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("predators", type: .nonNull(.list(.nonNull(.object(Predator.selections))))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(height: Height, bodyTemperature: Int, species: String, skinCovering: SkinCovering? = nil, humanName: String? = nil, favoriteToy: String, owner: Owner? = nil, predators: [Predator]) {
          self.init(unsafeResultMap: ["__typename": "Dog", "height": height.resultMap, "bodyTemperature": bodyTemperature, "species": species, "skinCovering": skinCovering, "humanName": humanName, "favoriteToy": favoriteToy, "owner": owner.flatMap { (value: Owner) -> ResultMap in value.resultMap }, "predators": predators.map { (value: Predator) -> ResultMap in value.resultMap }])
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

        public var bodyTemperature: Int {
          get {
            return resultMap["bodyTemperature"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "bodyTemperature")
          }
        }

        public var species: String {
          get {
            return resultMap["species"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "species")
          }
        }

        public var skinCovering: SkinCovering? {
          get {
            return resultMap["skinCovering"] as? SkinCovering
          }
          set {
            resultMap.updateValue(newValue, forKey: "skinCovering")
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

        public var predators: [Predator] {
          get {
            return (resultMap["predators"] as! [ResultMap]).map { (value: ResultMap) -> Predator in Predator(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: Predator) -> ResultMap in value.resultMap }, forKey: "predators")
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

          public var heightInMeters: HeightInMeters {
            get {
              return HeightInMeters(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public var warmBloodedDetails: WarmBloodedDetails {
            get {
              return WarmBloodedDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public var petDetails: PetDetails {
            get {
              return PetDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Height: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Height"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("feet", type: .nonNull(.scalar(Int.self))),
              GraphQLField("inches", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("meters", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("meters", type: .nonNull(.scalar(Int.self))),
              GraphQLField("yards", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("relativeSize", type: .nonNull(.scalar(RelativeSize.self))),
              GraphQLField("centimeters", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("meters", type: .nonNull(.scalar(Int.self))),
              GraphQLField("yards", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("relativeSize", type: .nonNull(.scalar(RelativeSize.self))),
              GraphQLField("centimeters", type: .nonNull(.scalar(Int.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(feet: Int, inches: Int, meters: Int, yards: Int, relativeSize: RelativeSize, centimeters: Int) {
            self.init(unsafeResultMap: ["__typename": "Height", "feet": feet, "inches": inches, "meters": meters, "yards": yards, "relativeSize": relativeSize, "centimeters": centimeters])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var feet: Int {
            get {
              return resultMap["feet"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "feet")
            }
          }

          public var inches: Int {
            get {
              return resultMap["inches"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "inches")
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

          public var relativeSize: RelativeSize {
            get {
              return resultMap["relativeSize"]! as! RelativeSize
            }
            set {
              resultMap.updateValue(newValue, forKey: "relativeSize")
            }
          }

          public var centimeters: Int {
            get {
              return resultMap["centimeters"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "centimeters")
            }
          }
        }

        public struct Owner: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Human"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
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

        public struct Predator: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Human", "Cat", "Dog", "Bird", "Fish", "Rat", "Crocodile"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLTypeCase(
                variants: ["Human": AsHumanOrCatOrDogOrBird.selections, "Cat": AsHumanOrCatOrDogOrBird.selections, "Dog": AsHumanOrCatOrDogOrBird.selections, "Bird": AsHumanOrCatOrDogOrBird.selections],
                default: [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("species", type: .nonNull(.scalar(String.self))),
                ]
              )
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeFish(species: String) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Fish", "species": species])
          }

          public static func makeRat(species: String) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Rat", "species": species])
          }

          public static func makeCrocodile(species: String) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Crocodile", "species": species])
          }

          public static func makeHuman(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Human", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeCat(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Cat", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeDog(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Dog", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeBird(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Bird", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var species: String {
            get {
              return resultMap["species"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "species")
            }
          }

          public var asHumanOrCatOrDogOrBird: AsHumanOrCatOrDogOrBird? {
            get {
              if !AsHumanOrCatOrDogOrBird.possibleTypes.contains(__typename) { return nil }
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsHumanOrCatOrDogOrBird: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Human", "Cat", "Dog", "Bird"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("species", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("bodyTemperature", type: .nonNull(.scalar(Int.self))),
                GraphQLField("height", type: .nonNull(.object(Height.selections))),
                GraphQLField("laysEggs", type: .nonNull(.scalar(Bool.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public static func makeHuman(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Human", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public static func makeCat(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Cat", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public static func makeDog(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Dog", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public static func makeBird(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Bird", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var species: String {
              get {
                return resultMap["species"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "species")
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

            public var laysEggs: Bool {
              get {
                return resultMap["laysEggs"]! as! Bool
              }
              set {
                resultMap.updateValue(newValue, forKey: "laysEggs")
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

              public var warmBloodedDetails: WarmBloodedDetails {
                get {
                  return WarmBloodedDetails(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
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
        }
      }

      public var asBird: AsBird? {
        get {
          if !AsBird.possibleTypes.contains(__typename) { return nil }
          return AsBird(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsBird: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Bird"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("bodyTemperature", type: .nonNull(.scalar(Int.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("species", type: .nonNull(.scalar(String.self))),
            GraphQLField("skinCovering", type: .scalar(SkinCovering.self)),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("humanName", type: .scalar(String.self)),
            GraphQLField("favoriteToy", type: .nonNull(.scalar(String.self))),
            GraphQLField("owner", type: .object(Owner.selections)),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("humanName", type: .scalar(String.self)),
            GraphQLField("favoriteToy", type: .nonNull(.scalar(String.self))),
            GraphQLField("owner", type: .object(Owner.selections)),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("bodyTemperature", type: .nonNull(.scalar(Int.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("wingspan", type: .nonNull(.scalar(Int.self))),
            GraphQLField("predators", type: .nonNull(.list(.nonNull(.object(Predator.selections))))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(height: Height, bodyTemperature: Int, species: String, skinCovering: SkinCovering? = nil, humanName: String? = nil, favoriteToy: String, owner: Owner? = nil, wingspan: Int, predators: [Predator]) {
          self.init(unsafeResultMap: ["__typename": "Bird", "height": height.resultMap, "bodyTemperature": bodyTemperature, "species": species, "skinCovering": skinCovering, "humanName": humanName, "favoriteToy": favoriteToy, "owner": owner.flatMap { (value: Owner) -> ResultMap in value.resultMap }, "wingspan": wingspan, "predators": predators.map { (value: Predator) -> ResultMap in value.resultMap }])
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

        public var bodyTemperature: Int {
          get {
            return resultMap["bodyTemperature"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "bodyTemperature")
          }
        }

        public var species: String {
          get {
            return resultMap["species"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "species")
          }
        }

        public var skinCovering: SkinCovering? {
          get {
            return resultMap["skinCovering"] as? SkinCovering
          }
          set {
            resultMap.updateValue(newValue, forKey: "skinCovering")
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

        public var wingspan: Int {
          get {
            return resultMap["wingspan"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "wingspan")
          }
        }

        public var predators: [Predator] {
          get {
            return (resultMap["predators"] as! [ResultMap]).map { (value: ResultMap) -> Predator in Predator(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: Predator) -> ResultMap in value.resultMap }, forKey: "predators")
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

          public var heightInMeters: HeightInMeters {
            get {
              return HeightInMeters(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public var warmBloodedDetails: WarmBloodedDetails {
            get {
              return WarmBloodedDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public var petDetails: PetDetails {
            get {
              return PetDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Height: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Height"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("feet", type: .nonNull(.scalar(Int.self))),
              GraphQLField("inches", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("meters", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("meters", type: .nonNull(.scalar(Int.self))),
              GraphQLField("yards", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("relativeSize", type: .nonNull(.scalar(RelativeSize.self))),
              GraphQLField("centimeters", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("meters", type: .nonNull(.scalar(Int.self))),
              GraphQLField("yards", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("relativeSize", type: .nonNull(.scalar(RelativeSize.self))),
              GraphQLField("centimeters", type: .nonNull(.scalar(Int.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(feet: Int, inches: Int, meters: Int, yards: Int, relativeSize: RelativeSize, centimeters: Int) {
            self.init(unsafeResultMap: ["__typename": "Height", "feet": feet, "inches": inches, "meters": meters, "yards": yards, "relativeSize": relativeSize, "centimeters": centimeters])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var feet: Int {
            get {
              return resultMap["feet"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "feet")
            }
          }

          public var inches: Int {
            get {
              return resultMap["inches"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "inches")
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

          public var relativeSize: RelativeSize {
            get {
              return resultMap["relativeSize"]! as! RelativeSize
            }
            set {
              resultMap.updateValue(newValue, forKey: "relativeSize")
            }
          }

          public var centimeters: Int {
            get {
              return resultMap["centimeters"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "centimeters")
            }
          }
        }

        public struct Owner: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Human"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
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

        public struct Predator: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Human", "Cat", "Dog", "Bird", "Fish", "Rat", "Crocodile"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLTypeCase(
                variants: ["Human": AsHumanOrCatOrDogOrBird.selections, "Cat": AsHumanOrCatOrDogOrBird.selections, "Dog": AsHumanOrCatOrDogOrBird.selections, "Bird": AsHumanOrCatOrDogOrBird.selections],
                default: [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("species", type: .nonNull(.scalar(String.self))),
                ]
              )
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeFish(species: String) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Fish", "species": species])
          }

          public static func makeRat(species: String) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Rat", "species": species])
          }

          public static func makeCrocodile(species: String) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Crocodile", "species": species])
          }

          public static func makeHuman(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Human", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeCat(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Cat", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeDog(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Dog", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeBird(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Bird", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var species: String {
            get {
              return resultMap["species"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "species")
            }
          }

          public var asHumanOrCatOrDogOrBird: AsHumanOrCatOrDogOrBird? {
            get {
              if !AsHumanOrCatOrDogOrBird.possibleTypes.contains(__typename) { return nil }
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsHumanOrCatOrDogOrBird: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Human", "Cat", "Dog", "Bird"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("species", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("bodyTemperature", type: .nonNull(.scalar(Int.self))),
                GraphQLField("height", type: .nonNull(.object(Height.selections))),
                GraphQLField("laysEggs", type: .nonNull(.scalar(Bool.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public static func makeHuman(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Human", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public static func makeCat(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Cat", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public static func makeDog(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Dog", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public static func makeBird(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Bird", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var species: String {
              get {
                return resultMap["species"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "species")
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

            public var laysEggs: Bool {
              get {
                return resultMap["laysEggs"]! as! Bool
              }
              set {
                resultMap.updateValue(newValue, forKey: "laysEggs")
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

              public var warmBloodedDetails: WarmBloodedDetails {
                get {
                  return WarmBloodedDetails(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
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
        }
      }

      public var asFishOrRat: AsFishOrRat? {
        get {
          if !AsFishOrRat.possibleTypes.contains(__typename) { return nil }
          return AsFishOrRat(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsFishOrRat: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Fish", "Rat"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("species", type: .nonNull(.scalar(String.self))),
            GraphQLField("skinCovering", type: .scalar(SkinCovering.self)),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("humanName", type: .scalar(String.self)),
            GraphQLField("favoriteToy", type: .nonNull(.scalar(String.self))),
            GraphQLField("owner", type: .object(Owner.selections)),
            GraphQLField("height", type: .nonNull(.object(Height.selections))),
            GraphQLField("predators", type: .nonNull(.list(.nonNull(.object(Predator.selections))))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeFish(height: Height, species: String, skinCovering: SkinCovering? = nil, humanName: String? = nil, favoriteToy: String, owner: Owner? = nil, predators: [Predator]) -> AsFishOrRat {
          return AsFishOrRat(unsafeResultMap: ["__typename": "Fish", "height": height.resultMap, "species": species, "skinCovering": skinCovering, "humanName": humanName, "favoriteToy": favoriteToy, "owner": owner.flatMap { (value: Owner) -> ResultMap in value.resultMap }, "predators": predators.map { (value: Predator) -> ResultMap in value.resultMap }])
        }

        public static func makeRat(height: Height, species: String, skinCovering: SkinCovering? = nil, humanName: String? = nil, favoriteToy: String, owner: Owner? = nil, predators: [Predator]) -> AsFishOrRat {
          return AsFishOrRat(unsafeResultMap: ["__typename": "Rat", "height": height.resultMap, "species": species, "skinCovering": skinCovering, "humanName": humanName, "favoriteToy": favoriteToy, "owner": owner.flatMap { (value: Owner) -> ResultMap in value.resultMap }, "predators": predators.map { (value: Predator) -> ResultMap in value.resultMap }])
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

        public var species: String {
          get {
            return resultMap["species"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "species")
          }
        }

        public var skinCovering: SkinCovering? {
          get {
            return resultMap["skinCovering"] as? SkinCovering
          }
          set {
            resultMap.updateValue(newValue, forKey: "skinCovering")
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

        public var predators: [Predator] {
          get {
            return (resultMap["predators"] as! [ResultMap]).map { (value: ResultMap) -> Predator in Predator(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: Predator) -> ResultMap in value.resultMap }, forKey: "predators")
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

          public var heightInMeters: HeightInMeters {
            get {
              return HeightInMeters(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public var warmBloodedDetails: WarmBloodedDetails? {
            get {
              if !WarmBloodedDetails.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return WarmBloodedDetails(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var petDetails: PetDetails {
            get {
              return PetDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Height: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Height"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("feet", type: .nonNull(.scalar(Int.self))),
              GraphQLField("inches", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("meters", type: .nonNull(.scalar(Int.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("relativeSize", type: .nonNull(.scalar(RelativeSize.self))),
              GraphQLField("centimeters", type: .nonNull(.scalar(Int.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(feet: Int, inches: Int, meters: Int, relativeSize: RelativeSize, centimeters: Int) {
            self.init(unsafeResultMap: ["__typename": "Height", "feet": feet, "inches": inches, "meters": meters, "relativeSize": relativeSize, "centimeters": centimeters])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var feet: Int {
            get {
              return resultMap["feet"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "feet")
            }
          }

          public var inches: Int {
            get {
              return resultMap["inches"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "inches")
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

          public var relativeSize: RelativeSize {
            get {
              return resultMap["relativeSize"]! as! RelativeSize
            }
            set {
              resultMap.updateValue(newValue, forKey: "relativeSize")
            }
          }

          public var centimeters: Int {
            get {
              return resultMap["centimeters"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "centimeters")
            }
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

        public struct Predator: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Human", "Cat", "Dog", "Bird", "Fish", "Rat", "Crocodile"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLTypeCase(
                variants: ["Human": AsHumanOrCatOrDogOrBird.selections, "Cat": AsHumanOrCatOrDogOrBird.selections, "Dog": AsHumanOrCatOrDogOrBird.selections, "Bird": AsHumanOrCatOrDogOrBird.selections],
                default: [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("species", type: .nonNull(.scalar(String.self))),
                ]
              )
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeFish(species: String) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Fish", "species": species])
          }

          public static func makeRat(species: String) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Rat", "species": species])
          }

          public static func makeCrocodile(species: String) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Crocodile", "species": species])
          }

          public static func makeHuman(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Human", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeCat(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Cat", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeDog(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Dog", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public static func makeBird(species: String, bodyTemperature: Int, height: AsHumanOrCatOrDogOrBird.Height, laysEggs: Bool) -> Predator {
            return Predator(unsafeResultMap: ["__typename": "Bird", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var species: String {
            get {
              return resultMap["species"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "species")
            }
          }

          public var asHumanOrCatOrDogOrBird: AsHumanOrCatOrDogOrBird? {
            get {
              if !AsHumanOrCatOrDogOrBird.possibleTypes.contains(__typename) { return nil }
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsHumanOrCatOrDogOrBird: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Human", "Cat", "Dog", "Bird"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("species", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("bodyTemperature", type: .nonNull(.scalar(Int.self))),
                GraphQLField("height", type: .nonNull(.object(Height.selections))),
                GraphQLField("laysEggs", type: .nonNull(.scalar(Bool.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public static func makeHuman(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Human", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public static func makeCat(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Cat", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public static func makeDog(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Dog", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public static func makeBird(species: String, bodyTemperature: Int, height: Height, laysEggs: Bool) -> AsHumanOrCatOrDogOrBird {
              return AsHumanOrCatOrDogOrBird(unsafeResultMap: ["__typename": "Bird", "species": species, "bodyTemperature": bodyTemperature, "height": height.resultMap, "laysEggs": laysEggs])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var species: String {
              get {
                return resultMap["species"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "species")
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

            public var laysEggs: Bool {
              get {
                return resultMap["laysEggs"]! as! Bool
              }
              set {
                resultMap.updateValue(newValue, forKey: "laysEggs")
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

              public var warmBloodedDetails: WarmBloodedDetails {
                get {
                  return WarmBloodedDetails(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
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
        }
      }
    }
  }
}
