//
//  TestCustomRequestCreator.swift
//  Apollo
//
//  Created by Kim de Vos on 02/10/2019.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Apollo

struct TestCustomRequestCreator: RequestCreator {
  public func requestBody<Operation: GraphQLOperation>(for operation: Operation, sendOperationIdentifiers: Bool) -> GraphQLMap {
    var body: GraphQLMap = [
      "test_variables": operation.variables,
      "test_operationName": operation.operationName,
    ]

    if sendOperationIdentifiers {
      guard let operationIdentifier = operation.operationIdentifier else {
        preconditionFailure("To send operation identifiers, Apollo types must be generated with operationIdentifiers")
      }

      body["test_id"] = operationIdentifier
    } else {
      body["test_query"] = operation.queryDocument
    }

    return body
  }

  public func requestMultipartFormData<Operation: GraphQLOperation>(for operation: Operation,
                                                                    files: [GraphQLFile],
                                                                    sendOperationIdentifiers: Bool,
                                                                    serializationFormat: JSONSerializationFormat.Type,
                                                                    manualBoundary: String?) throws -> MultipartFormData {
    let formData: MultipartFormData

    if let boundary = manualBoundary {
      formData = MultipartFormData(boundary: boundary)
    } else {
      formData = MultipartFormData()
    }

    let fields = requestBody(for: operation, sendOperationIdentifiers: false)
    for (name, data) in fields {
      if let data = data as? GraphQLMap {
        let data = try serializationFormat.serialize(value: data)
        formData.appendPart(data: data, name: name)
      } else if let data = data as? String {
        try formData.appendPart(string: data, name: name)
      } else {
        try formData.appendPart(string: data.debugDescription, name: name)
      }
    }

    try files.forEach {
      formData.appendPart(inputStream: try $0.generateInputStream(), contentLength: $0.contentLength, name: $0.fieldName, contentType: $0.mimeType, filename: $0.originalName)
    }

    return formData
  }
}
