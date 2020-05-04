//
//  ASTVariableType+TestHelpers.swift
//  Apollo
//
//  Created by Ellen Shapiro on 5/4/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import Foundation
@testable import ApolloCodegenLib

extension ASTVariableType {
  
  static func named(_ name: String) -> ASTVariableType {
    let name = ASTVariableType(kind: .Name,
                               name: nil,
                               type: nil,
                               value: name)
    
    return ASTVariableType(kind: .NamedType,
                           name: name,
                           type: nil,
                           value: nil)
  }
  
  static func nonNullNamed(_ name: String) -> ASTVariableType {
    ASTVariableType(kind: .NonNullType,
                    name: nil,
                    type: .named(name),
                    value: nil)
  }
  
  static func list(of type: ASTVariableType) -> ASTVariableType {
    ASTVariableType(kind: .ListType,
                    name: nil,
                    type: type,
                    value: nil)
  }
  
  static func nonNullList(of type: ASTVariableType) -> ASTVariableType {
    ASTVariableType(kind: .NonNullType,
                    name: nil,
                    type: type,
                    value: nil)
  }
}
