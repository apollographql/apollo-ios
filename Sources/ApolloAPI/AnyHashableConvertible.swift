import Foundation
import CloudKit

public protocol AnyHashableConvertible {
  var asAnyHashable: AnyHashable { get }
}

extension AnyHashableConvertible where Self: Hashable {
  @inlinable public var asAnyHashable: AnyHashable { self }
}

extension AnyHashable: AnyHashableConvertible {}

extension Optional: AnyHashableConvertible where Wrapped: Hashable {}

extension JSONEncodableDictionary: AnyHashableConvertible where Value: Hashable {
  @inlinable public var asAnyHashable: AnyHashable { unsafeBitCast(self, to: AnyHashable.self) }
}

extension Array: AnyHashableConvertible where Element: Hashable {}
