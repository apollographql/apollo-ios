public protocol CacheEntity: AnyObject {}

open class Object: CacheEntity, JSONEncodable {

  open class var __metadata: Metadata { Metadata.Empty }
  open class var __typename: StaticString { UnknownTypeName }
  open class var __cacheKeyProvider: CacheKeyProvider.Type? { nil }

  static let UnknownTypeName: StaticString = "∅__UnknownType"

  public var jsonValue: JSONValue { "" }
}

extension Object {
  public struct Metadata {
    private let implementedInterfaces: [Interface.Type]?
    private let covariantFields: [String: CacheEntity.Type]?

    fileprivate static let Empty = Metadata()

    public init(implements: [Interface.Type]? = nil,
                covariantFields: [String: CacheEntity.Type]? = nil) {
      self.implementedInterfaces = implements
      self.covariantFields = covariantFields
    }

    func fieldTypeIfCovariant(forField field: String) -> CacheEntity.Type? {
      covariantFields?[field]
    }

    func implements(_ interface: Interface.Type) -> Bool {
      implementedInterfaces?.contains(where: { $0 == interface }) ?? false
    }
  }

  public static func _canBeConverted(to otherType: ParentType) -> Bool {
    switch otherType {
    case .Object(let otherType):
      return self == otherType

    case .Interface(let interface):
      return Self.__metadata.implements(interface)

    case .Union(let union):
      return union.possibleTypes.contains(where: { $0 == self })
    }
  }
}
