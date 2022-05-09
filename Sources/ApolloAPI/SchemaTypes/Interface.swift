import Foundation
open class Interface: CacheEntity {

  public final let _object: Object
  final var underlyingType: Object.Type { Swift.type(of: _object) } // TODO: Delete?

  public required init(_ object: Object) throws {
    let objectType = type(of: object)
    guard objectType.__metadata.implements(Self.self) else {
      #warning("TODO!")
      throw NSError()
//      CacheError.Reason.invalidObjectType(objectType, forExpectedType: Self.self)
    }

    self._object = object
  }

  public required convenience init(_ interface: Interface) throws {
    try self.init(interface._object)
  }

}
