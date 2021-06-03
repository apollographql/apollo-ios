import Foundation

/// A request class allowing for a multipart-upload request.
open class UploadRequest<Operation: GraphQLOperation>: HTTPRequest<Operation> {
  
  public let requestBodyCreator: RequestBodyCreator
  public let files: [GraphQLFile]
  public let manualBoundary: String?
  
  public let serializationFormat = JSONSerializationFormat.self
  
  /// Designated Initializer
  ///
  /// - Parameters:
  ///   - graphQLEndpoint: The endpoint to make a GraphQL request to
  ///   - operation: The GraphQL Operation to execute
  ///   - clientName: The name of the client to send with the `"apollographql-client-name"` header
  ///   - clientVersion:  The version of the client to send with the `"apollographql-client-version"` header
  ///   - additionalHeaders: Any additional headers you wish to add by default to this request. Defaults to an empty dictionary.
  ///   - files: The array of files to upload for all `Upload` parameters in the mutation.
  ///   - manualBoundary: [optional] A manual boundary to pass in. A default boundary will be used otherwise. Defaults to nil.
  ///   - requestBodyCreator: An object conforming to the `RequestBodyCreator` protocol to assist with creating the request body. Defaults to the provided `ApolloRequestBodyCreator` implementation.
  public init(graphQLEndpoint: URL,
              operation: Operation,
              clientName: String,
              clientVersion: String,
              additionalHeaders: [String: String] = [:],
              files: [GraphQLFile],
              manualBoundary: String? = nil,
              requestBodyCreator: RequestBodyCreator = ApolloRequestBodyCreator()) {
    self.requestBodyCreator = requestBodyCreator
    self.files = files
    self.manualBoundary = manualBoundary
    super.init(graphQLEndpoint: graphQLEndpoint,
               operation: operation,
               contentType: "multipart/form-data",
               clientName: clientName,
               clientVersion: clientVersion,
               additionalHeaders: additionalHeaders)
  }
  
  public override func toURLRequest() throws -> URLRequest {
    let formData = try self.requestMultipartFormData()
    self.updateContentType(to: "multipart/form-data; boundary=\(formData.boundary)")
    var request = try super.toURLRequest()
    request.httpBody = try formData.encode()
    request.httpMethod = GraphQLHTTPMethod.POST.rawValue
    
    return request
  }
  
  /// Creates the `MultipartFormData` object to use when creating the URL Request.
  ///
  /// This method follows the [GraphQL Multipart Request Spec](https://github.com/jaydenseric/graphql-multipart-request-spec) Override this method to use a different upload spec.
  ///
  /// - Throws: Any error arising from creating the form data
  /// - Returns: The created form data
  open func requestMultipartFormData() throws -> MultipartFormData {
    let shouldSendOperationID = (self.operation.operationIdentifier != nil)

    let formData: MultipartFormData

    if let boundary = manualBoundary {
      formData = MultipartFormData(boundary: boundary)
    } else {
      formData = MultipartFormData()
    }

    // Make sure all fields for files are set to null, or the server won't look
    // for the files in the rest of the form data
    let fieldsForFiles = Set(files.map { $0.fieldName }).sorted()
    var fields = self.requestBodyCreator.requestBody(for: operation,
                                                     sendOperationIdentifiers: shouldSendOperationID,
                                                     sendQueryDocument: true,
                                                     autoPersistQuery: false)
    var variables = fields["variables"] as? GraphQLMap ?? GraphQLMap()
    for fieldName in fieldsForFiles {
      if
        let value = variables[fieldName],
        let arrayValue = value as? [JSONEncodable] {
        let arrayOfNils: [JSONEncodable?] = arrayValue.map { _ in nil }
          variables.updateValue(arrayOfNils, forKey: fieldName)
      } else {
        variables.updateValue(nil, forKey: fieldName)
      }
    }
    fields["variables"] = variables

    let operationData = try serializationFormat.serialize(value: fields)
    formData.appendPart(data: operationData, name: "operations")

    // If there are multiple files for the same field, make sure to include them with indexes for the field. If there are multiple files for different fields, just use the field name.
    var map = [String: [String]]()
    var currentIndex = 0
    
    var sortedFiles = [GraphQLFile]()
    for fieldName in fieldsForFiles {
      let filesForField = files.filter { $0.fieldName == fieldName }
      if filesForField.count == 1 {
        let firstFile = filesForField.first!
        map["\(currentIndex)"] = ["variables.\(firstFile.fieldName)"]
        sortedFiles.append(firstFile)
        currentIndex += 1
      } else {
        for (index, file) in filesForField.enumerated() {
          map["\(currentIndex)"] = ["variables.\(file.fieldName).\(index)"]
          sortedFiles.append(file)
          currentIndex += 1
        }
      }
    }
    
    assert(sortedFiles.count == files.count, "Number of sorted files did not equal the number of incoming files - some field name has been left out.")

    let mapData = try serializationFormat.serialize(value: map)
    formData.appendPart(data: mapData, name: "map")

    for (index, file) in sortedFiles.enumerated() {
      formData.appendPart(inputStream: try file.generateInputStream(),
                          contentLength: file.contentLength,
                          name: "\(index)",
                          contentType: file.mimeType,
                          filename: file.originalName)
    }

    return formData
  }
}
