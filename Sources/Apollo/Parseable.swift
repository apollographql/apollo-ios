import Foundation

public protocol Parseable {
    
    init<T: FlexibleDecoder>(from data: Data, decoder: T) throws
}

public extension Parseable where Self: Decodable {
    
    init<T: FlexibleDecoder>(from data: Data, decoder: T) throws {
        self = try decoder.decode(Self.self, from: data)
    }
}
