//
//  TestFileHelper.swift
//  ApolloTests
//
//  Created by Ellen Shapiro on 3/18/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import Foundation
import Apollo

public struct TestFileHelper {
  
  public static func testParentFolder(for file: StaticString = #file) -> URL {
    let fileAsString = file.withUTF8Buffer {
        String(decoding: $0, as: UTF8.self)
    }
    let url = URL(fileURLWithPath: fileAsString)
    return url.deletingLastPathComponent()
  }
  
  public static func uploadServerFolder(from file: StaticString = #file) -> URL {
    self.testParentFolder(for: file)
      .deletingLastPathComponent() // test root
      .deletingLastPathComponent() // source root
      .appendingPathComponent("SimpleUploadServer")
  }
  
  public static func uploadsFolder(from file: StaticString = #file) -> URL {
    self.uploadServerFolder(from: file)
      .appendingPathComponent("uploads")
  }
  
  public static func fileURLForFile(named name: String, extension fileExtension: String) -> URL {
    return self.testParentFolder()
        .appendingPathComponent("Resources")
        .appendingPathComponent(name)
        .appendingPathExtension(fileExtension)
  }
}
