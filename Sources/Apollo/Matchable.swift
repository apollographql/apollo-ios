//
//  Matchable.swift
//  Apollo
//
//  Created by Ellen Shapiro on 10/29/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

public protocol Matchable {
  associatedtype Base
  static func ~=(pattern: Self, value: Base) -> Bool
}
