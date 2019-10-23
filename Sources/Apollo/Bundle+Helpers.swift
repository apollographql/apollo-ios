//
//  Bundle+Helpers.swift
//  Apollo
//
//  Created by Ellen Shapiro on 10/23/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

extension Bundle {
  
  /// Type-safe getter for info dictionary key objects
  ///
  /// - Parameter key: The key to try to grab an object for
  /// - Returns: The object of the desired type, or nil if it is not present or of the incorrect type.
  func bundleValue<T>(forKey key: String) -> T? {
    return object(forInfoDictionaryKey: key) as? T
  }
  
  /// The bundle identifier of this bundle, or nil if not present.
  var bundleIdentifier: String? {
    return self.bundleValue(forKey: String(kCFBundleIdentifierKey))
  }
  
  var buildNumber: String? {
    return self.bundleValue(forKey: String(kCFBundleVersionKey))
  }
  
  var shortVersion: String? {
    return self.bundleValue(forKey: "CFBundleShortVersionString")
  }
}
