import Foundation

/// A representation of a timestamp in miliseconds
public typealias Timestamp = Int64

public extension Date {
  var milisecondsSince1970: Timestamp {
    return Timestamp(timeIntervalSince1970 * 1000)
  }
}
