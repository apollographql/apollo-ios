import struct Foundation.TimeInterval

extension TimeInterval {
  public static var oneHour: Self { 3600 }
  public static var oneDay: Self { 86400 }
  public static var oneYear: Self { Self.oneDay * 365 }
}
