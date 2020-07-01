import Foundation
#if !COCOAPODS
import ApolloCore
#endif

extension Bundle: ApolloCompatible {}

extension ApolloExtension where Base == Bundle {

  /// Type-safe getter for info dictionary key objects
  ///
  /// - Parameter key: The key to try to grab an object for
  /// - Returns: The object of the desired type, or nil if it is not present or of the incorrect type.
  func bundleValue<T>(forKey key: String) -> T? {
    return base.object(forInfoDictionaryKey: key) as? T
  }

  /// The bundle identifier of this bundle, or nil if not present.
  var bundleIdentifier: String? {
    return self.bundleValue(forKey: String(kCFBundleIdentifierKey))
  }

  /// The build number of this bundle (kCFBundleVersion) as a string, or nil if not present.
  var buildNumber: String? {
    return self.bundleValue(forKey: String(kCFBundleVersionKey))
  }

  /// The short version string for this bundle, or nil if not present.
  var shortVersion: String? {
    return self.bundleValue(forKey: "CFBundleShortVersionString")
  }
}
