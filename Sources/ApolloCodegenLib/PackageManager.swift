//
//  PackageManager.swift
//  ApolloCodegenLib
//
//  Created by Ellen Shapiro on 12/11/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

/// How are you integrating the Apollo library?
public enum PackageManager {
  case swiftPackageManager
  case cocoaPods
  case carthage
  
  /// - parameter scriptsFolderURL: The direct URL to the checked out `apollo-ios/scripts` folder.
  case custom(scriptsFolderURL: URL)
}
