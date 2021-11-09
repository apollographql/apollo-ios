// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class ClassroomPetsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query ClassroomPets {
      classroomPets {
        __typename
        ...ClassroomPetDetails
      }
    }
    """

  public let operationName: String = "ClassroomPets"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + ClassroomPetDetails.fragmentDefinition)
    return document
  }

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("classroomPets", type: .nonNull(.list(.nonNull(.object(ClassroomPet.selections))))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(classroomPets: [ClassroomPet]) {
      self.init(unsafeResultMap: ["__typename": "Query", "classroomPets": classroomPets.map { (value: ClassroomPet) -> ResultMap in value.resultMap }])
    }

    public var classroomPets: [ClassroomPet] {
      get {
        return (resultMap["classroomPets"] as! [ResultMap]).map { (value: ResultMap) -> ClassroomPet in ClassroomPet(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: ClassroomPet) -> ResultMap in value.resultMap }, forKey: "classroomPets")
      }
    }

    public struct ClassroomPet: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Cat", "Bird", "Rat", "PetRock"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLTypeCase(
            variants: ["Cat": AsCat.selections, "Bird": AsBird.selections, "Rat": AsRat.selections, "PetRock": AsPetRock.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("humanName", type: .scalar(String.self)),
            ]
          )
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public static func makeCat(humanName: String? = nil, species: String, laysEggs: Bool, bodyTemperature: Int, isJellicle: Bool) -> ClassroomPet {
        return ClassroomPet(unsafeResultMap: ["__typename": "Cat", "humanName": humanName, "species": species, "laysEggs": laysEggs, "bodyTemperature": bodyTemperature, "isJellicle": isJellicle])
      }

      public static func makeBird(humanName: String? = nil, species: String, laysEggs: Bool, wingspan: Int) -> ClassroomPet {
        return ClassroomPet(unsafeResultMap: ["__typename": "Bird", "humanName": humanName, "species": species, "laysEggs": laysEggs, "wingspan": wingspan])
      }

      public static func makeRat(humanName: String? = nil, species: String) -> ClassroomPet {
        return ClassroomPet(unsafeResultMap: ["__typename": "Rat", "humanName": humanName, "species": species])
      }

      public static func makePetRock(humanName: String? = nil, favoriteToy: String) -> ClassroomPet {
        return ClassroomPet(unsafeResultMap: ["__typename": "PetRock", "humanName": humanName, "favoriteToy": favoriteToy])
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

        public var classroomPetDetails: ClassroomPetDetails {
          get {
            return ClassroomPetDetails(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
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
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("humanName", type: .scalar(String.self)),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("species", type: .nonNull(.scalar(String.self))),
            GraphQLField("humanName", type: .scalar(String.self)),
            GraphQLField("laysEggs", type: .nonNull(.scalar(Bool.self))),
            GraphQLField("bodyTemperature", type: .nonNull(.scalar(Int.self))),
            GraphQLField("isJellicle", type: .nonNull(.scalar(Bool.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(humanName: String? = nil, species: String, laysEggs: Bool, bodyTemperature: Int, isJellicle: Bool) {
          self.init(unsafeResultMap: ["__typename": "Cat", "humanName": humanName, "species": species, "laysEggs": laysEggs, "bodyTemperature": bodyTemperature, "isJellicle": isJellicle])
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

        public var species: String {
          get {
            return resultMap["species"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "species")
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

        public var bodyTemperature: Int {
          get {
            return resultMap["bodyTemperature"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "bodyTemperature")
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

          public var classroomPetDetails: ClassroomPetDetails {
            get {
              return ClassroomPetDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
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
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("humanName", type: .scalar(String.self)),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("species", type: .nonNull(.scalar(String.self))),
            GraphQLField("humanName", type: .scalar(String.self)),
            GraphQLField("laysEggs", type: .nonNull(.scalar(Bool.self))),
            GraphQLField("wingspan", type: .nonNull(.scalar(Int.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(humanName: String? = nil, species: String, laysEggs: Bool, wingspan: Int) {
          self.init(unsafeResultMap: ["__typename": "Bird", "humanName": humanName, "species": species, "laysEggs": laysEggs, "wingspan": wingspan])
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

        public var species: String {
          get {
            return resultMap["species"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "species")
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

        public var wingspan: Int {
          get {
            return resultMap["wingspan"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "wingspan")
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

          public var classroomPetDetails: ClassroomPetDetails {
            get {
              return ClassroomPetDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public var asRat: AsRat? {
        get {
          if !AsRat.possibleTypes.contains(__typename) { return nil }
          return AsRat(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsRat: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Rat"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("humanName", type: .scalar(String.self)),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("species", type: .nonNull(.scalar(String.self))),
            GraphQLField("humanName", type: .scalar(String.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(humanName: String? = nil, species: String) {
          self.init(unsafeResultMap: ["__typename": "Rat", "humanName": humanName, "species": species])
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

        public var species: String {
          get {
            return resultMap["species"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "species")
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

          public var classroomPetDetails: ClassroomPetDetails {
            get {
              return ClassroomPetDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public var asPetRock: AsPetRock? {
        get {
          if !AsPetRock.possibleTypes.contains(__typename) { return nil }
          return AsPetRock(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap = newValue.resultMap
        }
      }

      public struct AsPetRock: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["PetRock"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("humanName", type: .scalar(String.self)),
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("humanName", type: .scalar(String.self)),
            GraphQLField("favoriteToy", type: .nonNull(.scalar(String.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(humanName: String? = nil, favoriteToy: String) {
          self.init(unsafeResultMap: ["__typename": "PetRock", "humanName": humanName, "favoriteToy": favoriteToy])
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

          public var classroomPetDetails: ClassroomPetDetails {
            get {
              return ClassroomPetDetails(unsafeResultMap: resultMap)
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

public struct ClassroomPetDetails: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment ClassroomPetDetails on ClassroomPet {
      __typename
      ... on Animal {
        species
      }
      ... on Pet {
        humanName
      }
      ... on WarmBlooded {
        laysEggs
      }
      ... on Cat {
        bodyTemperature
        isJellicle
      }
      ... on Bird {
        wingspan
      }
      ... on PetRock {
        favoriteToy
      }
    }
    """

  public static let possibleTypes: [String] = ["Cat", "Bird", "Rat", "PetRock"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLTypeCase(
        variants: ["Cat": AsCat.selections, "Bird": AsBird.selections, "Rat": AsRat.selections, "PetRock": AsPetRock.selections],
        default: [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("humanName", type: .scalar(String.self)),
        ]
      )
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeCat(species: String, humanName: String? = nil, laysEggs: Bool, bodyTemperature: Int, isJellicle: Bool) -> ClassroomPetDetails {
    return ClassroomPetDetails(unsafeResultMap: ["__typename": "Cat", "species": species, "humanName": humanName, "laysEggs": laysEggs, "bodyTemperature": bodyTemperature, "isJellicle": isJellicle])
  }

  public static func makeBird(species: String, humanName: String? = nil, laysEggs: Bool, wingspan: Int) -> ClassroomPetDetails {
    return ClassroomPetDetails(unsafeResultMap: ["__typename": "Bird", "species": species, "humanName": humanName, "laysEggs": laysEggs, "wingspan": wingspan])
  }

  public static func makeRat(species: String, humanName: String? = nil) -> ClassroomPetDetails {
    return ClassroomPetDetails(unsafeResultMap: ["__typename": "Rat", "species": species, "humanName": humanName])
  }

  public static func makePetRock(humanName: String? = nil, favoriteToy: String) -> ClassroomPetDetails {
    return ClassroomPetDetails(unsafeResultMap: ["__typename": "PetRock", "humanName": humanName, "favoriteToy": favoriteToy])
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
        GraphQLField("species", type: .nonNull(.scalar(String.self))),
        GraphQLField("humanName", type: .scalar(String.self)),
        GraphQLField("laysEggs", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("bodyTemperature", type: .nonNull(.scalar(Int.self))),
        GraphQLField("isJellicle", type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(species: String, humanName: String? = nil, laysEggs: Bool, bodyTemperature: Int, isJellicle: Bool) {
      self.init(unsafeResultMap: ["__typename": "Cat", "species": species, "humanName": humanName, "laysEggs": laysEggs, "bodyTemperature": bodyTemperature, "isJellicle": isJellicle])
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

    public var humanName: String? {
      get {
        return resultMap["humanName"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "humanName")
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

    public var bodyTemperature: Int {
      get {
        return resultMap["bodyTemperature"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "bodyTemperature")
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
        GraphQLField("species", type: .nonNull(.scalar(String.self))),
        GraphQLField("humanName", type: .scalar(String.self)),
        GraphQLField("laysEggs", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("wingspan", type: .nonNull(.scalar(Int.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(species: String, humanName: String? = nil, laysEggs: Bool, wingspan: Int) {
      self.init(unsafeResultMap: ["__typename": "Bird", "species": species, "humanName": humanName, "laysEggs": laysEggs, "wingspan": wingspan])
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

    public var humanName: String? {
      get {
        return resultMap["humanName"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "humanName")
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

    public var wingspan: Int {
      get {
        return resultMap["wingspan"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "wingspan")
      }
    }
  }

  public var asRat: AsRat? {
    get {
      if !AsRat.possibleTypes.contains(__typename) { return nil }
      return AsRat(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsRat: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Rat"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("species", type: .nonNull(.scalar(String.self))),
        GraphQLField("humanName", type: .scalar(String.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(species: String, humanName: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "Rat", "species": species, "humanName": humanName])
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

    public var humanName: String? {
      get {
        return resultMap["humanName"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "humanName")
      }
    }
  }

  public var asPetRock: AsPetRock? {
    get {
      if !AsPetRock.possibleTypes.contains(__typename) { return nil }
      return AsPetRock(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsPetRock: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["PetRock"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("humanName", type: .scalar(String.self)),
        GraphQLField("favoriteToy", type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(humanName: String? = nil, favoriteToy: String) {
      self.init(unsafeResultMap: ["__typename": "PetRock", "humanName": humanName, "favoriteToy": favoriteToy])
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
  }
}
