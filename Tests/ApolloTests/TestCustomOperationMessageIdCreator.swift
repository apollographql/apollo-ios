//
//  TestCustomOperationMessageIdCreator.swift
//  ApolloTests
//
//  Created by Clark McNally on 8/24/21.
//  Copyright © 2021 Apollo GraphQL. All rights reserved.
//

import Apollo

struct TestCustomOperationMessageIdCreator: OperationMessageIdCreator {
  func requestId() -> String {
    return "12345678"
  }
}
