//
//  String+SHA.swift
//  Apollo
//
//  Created by Ellen Shapiro on 9/18/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
  
  var sha256Hash: String {
    let data = self.data(using: .utf8)!
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes {
      _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
    }
    
    var hashString = ""
    for byte in hash {
      hashString += String(format:"%02x", UInt8(byte))
    }
    return hashString
  }
}
