//
//  Emptiable+Helpers.swift
//  Apollo
//
//  Created by Ellen Shapiro on 10/29/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

extension Collection {
  
  /// Convenience helper to make `guard` statements more readable
  ///
  /// - returns: `true` if the collection has contents.
  var isNotEmpty: Bool {
    return !self.isEmpty
  }
}

extension Optional where Wrapped: Collection {
  
  /// - returns: `true` if the collection is empty or nil
  var isEmptyOrNil: Bool {
    switch self {
    case .none:
      return true
    case .some(let collection):
      return collection.isEmpty
    }
  }
  
  /// - returns: `true` if the collection is non-nil AND has contents.
  var isNotEmpty: Bool {
    switch self {
    case .none:
      return false
    case .some(let collection):
      return collection.isNotEmpty
    }
  }
}
