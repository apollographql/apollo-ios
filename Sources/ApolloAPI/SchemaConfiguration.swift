public protocol SchemaConfiguration {
  static func objectType(forTypename typename: String) -> Object?
  static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo?
}

extension SchemaConfiguration {

  @inlinable public static func cacheKeyInfo(
    for type: Object,
    object: JSONObject
  ) -> CacheKeyInfo? {
    nil
  }

  @inlinable public static func graphQLType(for object: JSONObject) -> Object? {
    guard let typename = object["__typename"] as? String else {
      return nil
    }
    return objectType(forTypename: typename)
  }

  @inlinable public static func cacheKey(for object: JSONObject) -> CacheReference? {
    guard let type = graphQLType(for: object),
          let info = cacheKeyInfo(for: type, object: object) else {
      return nil
    }
    return CacheReference("\(info.uniqueKeyGroupId ?? type.typename):\(info.key)")
  }
}

public struct CacheKeyInfo {
  public let key: String
  public let uniqueKeyGroupId: String?

  @inlinable public init(jsonValue: JSONValue?, uniqueKeyGroupId: String? = nil) throws {
    guard let jsonValue = jsonValue else {
      throw JSONDecodingError.missingValue
    }

    self.init(key: try String(jsonValue: jsonValue), uniqueKeyGroupId: uniqueKeyGroupId)
  }

  @inlinable public init(key: String, uniqueKeyGroupId: String? = nil) {
    self.key = key
    self.uniqueKeyGroupId = uniqueKeyGroupId
  }
}

// EXAMPLE

struct FakeSchema: SchemaConfiguration {
  static func objectType(forTypename typename: String) -> Object? {
    switch typename {
    case "Dog": return Dog.type
    default:
      return Object(typename: typename, implementedInterfaces: [])
    }
  }
}

extension FakeSchema {
  struct Interfaces {
    static let Pet = Interface(name: "Pet")
  }
}

extension FakeSchema {
  public final class Dog: Object {
    static let type = Dog()
    private init() {
      super.init(typename: "Dog",
                 implementedInterfaces: [Interfaces.Pet])
    }
  }
}

//
//struct Interfaces {}
//struct Objects {}
//struct Unions {}
//
//  // GENERATED FOR YOU ^^^
//
//extension FakeSchema {
//
//  public static func cacheKeyInfo(for type: Object, object: JSONObject) -> CacheKeyInfo? {
//    switch type {
//    case type.__implementedInterfaces?.contains(Interfaces.Pet.self):
//      return IDCacheKeyProvider()
//
//    case is Types.Dog:
//      return try? CacheKeyInfo(jsonValue: jsonObject["petName"], uniqueKeyGroupId: "Pet")
//
//    case let unknownObject as UnknownObject:
//      let id = unknownObject.jsonObject["id"]
//      switch type.__typename {
//
//      }
//    default: return nil
//    }
//  }
//
////  static func cacheKey(for object: JSONObject) -> CacheKeyInfo? {
////    if let id = object["id"] {
////      return (id, nil)
////    } else {
////      return nil
////    }
////  }
//}

