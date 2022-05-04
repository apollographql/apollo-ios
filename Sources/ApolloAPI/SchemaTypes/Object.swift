open class Object: ObjectType, Cacheable {
  public final let _transaction: CacheTransaction
  public internal(set) final var data: [String: Any]
  open class var __metadata: Metadata { Metadata.Empty }
  open class var __typename: StaticString { UnknownTypeName }
  open class var __cacheKeyProvider: CacheKeyProvider.Type? { nil }

  static let UnknownTypeName: StaticString = "∅__UnknownType"

  final var __typename: String { data["__typename"] as! String } // TODO: delete?

  public required init(transaction: CacheTransaction, data: [String: Any] = [:]) {
    self._transaction = transaction
    self.data = data

    if self.data["__typename"] == nil {
      self.data["__typename"] = Self.__typename
    }
  }

  public static func value(
    with cacheData: Any,
    in transaction: CacheTransaction
  ) throws -> Self {
    let object = try getObject(with: cacheData, in: transaction)
    guard let objectAsSelf = object as? Self else {
      throw CacheError.Reason.invalidObjectType(type(of: object), forExpectedType: Self.self)
    }
    return objectAsSelf
  }

  private static func getObject(
    with cacheData: Any,
    in transaction: CacheTransaction
  ) throws -> Object {
    switch cacheData {
    case let object as Object:
      return object

    case let key as CacheReference:
      guard let object = transaction.object(for: key) else {
        throw CacheError.Reason.objectNotFound(forCacheKey: key)
      }
      return object

    case let data as [String: Any]:
      return transaction.object(withData: data)

    case let interface as Interface:
      return interface.object

    case let union as AnyUnion:
      return union.object

    default:
      throw CacheError.Reason.unrecognizedCacheData(cacheData, forType: Self.self)
    }
  }

  public final func set<T: Cacheable>(value: T?, forField field: Field<T>) throws {
    let fieldName = field.field.description

    guard let value = value else {
      data[fieldName] = nil
      return
    }

    switch T.self {
    case is ObjectType.Type:
      // Check for field covariance
      if let covariantFieldType = Self.__metadata.fieldTypeIfCovariant(forField: fieldName) {
        try set(value: value, forCovariantField: fieldName, convertingToType: covariantFieldType)

      } else {
        //        data[fieldName] = value // TODO: write tests
      }

    //    case is ScalarType.Type:
    //    break
    //    case is CustomScalarType.Type:
    //    break
    //    case is GraphQLEnum.Type:
    //    break
    default: break
    }
  }

  private func set(
    value: Cacheable,
    forCovariantField fieldName: String,
    convertingToType covariantFieldType: ObjectType.Type
  ) throws {
    do {
      switch covariantFieldType {
      case let interfaceType as Interface.Type:
        data[fieldName] = try interfaceType.value(with: value, in: _transaction)

      case let objectType as Object.Type:
        data[fieldName] = try objectType.value(with: value, in: _transaction)

      default: break // TODO: throw error or fatal error?
      }

    } catch {
      throw CacheError.Reason.invalidValue(value, forCovariantFieldOfType: covariantFieldType)
    }
  }
}

extension Object {
  public struct Metadata {
    private let implementedInterfaces: [Interface.Type]?
    private let covariantFields: [String: ObjectType.Type]?

    fileprivate static let Empty = Metadata()

    public init(implements: [Interface.Type]? = nil,
                covariantFields: [String: ObjectType.Type]? = nil) {
      self.implementedInterfaces = implements
      self.covariantFields = covariantFields
    }

    func fieldTypeIfCovariant(forField field: String) -> ObjectType.Type? {
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

public enum MockError: Error {
  case mock // TODO
}
