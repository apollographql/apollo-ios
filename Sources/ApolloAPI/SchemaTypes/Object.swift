public protocol CacheEntity: AnyObject {}

public protocol ObjectExtensionsProtocol {
  static var __cacheKeyProvider: CacheKeyProvider? { get }
}
extension ObjectExtensionsProtocol {
  public static var __cacheKeyProvider: CacheKeyProvider? { nil }
}

open class Object: CacheEntity, ObjectExtensionsProtocol {

  open class var __implementedInterfaces: [Interface.Type]? { nil }
  open class var __typename: StaticString { UnknownTypeName }

  static let UnknownTypeName: StaticString = "∅__UnknownType"

  public final class func _canBeConverted(to otherType: ParentType) -> Bool {
    switch otherType {
    case .Object(let otherType):
      return self == otherType

    case .Interface(let interface):
      return Self.implements(interface)

    case .Union(let union):
      return union.possibleTypes.contains(where: { $0 == self })
    }
  }

  public final class func implements(_ interface: Interface.Type) -> Bool {
    __implementedInterfaces?.contains(where: { $0 == interface }) ?? false
  }
}
