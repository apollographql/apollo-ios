//
//  TestFileHelper.swift
//  ApolloTests
//
//  Created by Ellen Shapiro on 3/18/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import Foundation

struct TestFileHelper {
  
  static func testParentFolder(for file: StaticString = #file) -> URL {
    let fileAsString = file.withUTF8Buffer {
        String(decoding: $0, as: UTF8.self)
    }
    let url = URL(fileURLWithPath: fileAsString)
    return url.deletingLastPathComponent()
  }
}
