//
//  ApolloFileHelper.swift
//  Apollo
//
//  Created by Ellen Shapiro on 10/22/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

struct ApolloFilePathHelper {
  
  static func apolloFolderURL(fromScripts scriptsFolderURL: URL) -> URL {
    return scriptsFolderURL.appendingPathComponent("apollo")
  }
  
  static func zipFileURL(fromScripts scriptsFolderURL: URL) -> URL {
    return scriptsFolderURL.appendingPathComponent("apollo.tar.gz")
  }
  
  static func binaryFolderURL(fromApollo apolloFolderURL: URL) -> URL {
    return apolloFolderURL.appendingPathComponent("bin")
  }
  
  static func binaryURL(fromBinaryFolder binaryFolderURL: URL) -> URL {
    return binaryFolderURL.appendingPathComponent("run")
  }
  
  static func shasumFileURL(fromApollo apolloFolderURL: URL) -> URL {
    return apolloFolderURL.appendingPathComponent(".shasum")
  }
}
