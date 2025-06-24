import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// A request class allowing for a multipart-upload request.
public struct UploadRequest<Operation: GraphQLOperation>: GraphQLRequest {

  /// The endpoint to make a GraphQL request to
  public var graphQLEndpoint: URL

  /// The GraphQL Operation to execute
  public var operation: Operation

  /// Any additional headers you wish to add to this request
  public var additionalHeaders: [String: String] = [:]

  /// The `FetchBehavior` to use for this request. Determines if fetching will include cache/network.
  public var fetchBehavior: FetchBehavior

  /// [optional] A context that is being passed through the request chain.
  public var context: (any RequestContext)?

  public let requestBodyCreator: any JSONRequestBodyCreator

  public let files: [GraphQLFile]

  public let multipartBoundary: String

  public let serializationFormat = JSONSerializationFormat.self

  /// The telemetry metadata about the client. This is used by GraphOS Studio's
  /// [client awareness](https://www.apollographql.com/docs/graphos/platform/insights/client-segmentation)
  /// feature.
  public var clientAwarenessMetadata: ClientAwarenessMetadata

  /// Designated Initializer
  ///
  /// - Parameters:
  ///   - operation: The GraphQL Operation to execute
  ///   - graphQLEndpoint: The endpoint to make a GraphQL request to
  ///   - files: The array of files to upload for all `Upload` parameters in the mutation.
  ///   - multipartBoundary: [optional] A boundary to use for the multipart request.
  ///   - context: [optional] A context that is being passed through the request chain. Should default to `nil`.
  ///   - requestBodyCreator: An object conforming to the `RequestBodyCreator` protocol to assist with creating the request body. Defaults to the provided `ApolloRequestBodyCreator` implementation.
  public init(
    operation: Operation,
    graphQLEndpoint: URL,
    files: [GraphQLFile],
    multipartBoundary: String? = nil,
    context: (any RequestContext)? = nil,
    requestBodyCreator: any JSONRequestBodyCreator = DefaultRequestBodyCreator(),
    clientAwarenessMetadata: ClientAwarenessMetadata = ClientAwarenessMetadata()
  ) {
    self.operation = operation
    self.graphQLEndpoint = graphQLEndpoint
    self.cachePolicy = .default
    self.context = context
    self.requestBodyCreator = requestBodyCreator
    self.files = files
    self.multipartBoundary = multipartBoundary ?? "apollo-ios.boundary.\(UUID().uuidString)"
    self.clientAwarenessMetadata = clientAwarenessMetadata

    self.addHeader(name: "Content-Type", value: "multipart/form-data; boundary=\(self.multipartBoundary)")
  }
  
  public func toURLRequest() throws -> URLRequest {
    let formData = try self.requestMultipartFormData()
    var request = createDefaultRequest()
    request.httpBody = try formData.encode()
    
    return request
  }
  
  /// Creates the `MultipartFormData` object to use when creating the URL Request.
  ///
  /// This method follows the [GraphQL Multipart Request Spec](https://github.com/jaydenseric/graphql-multipart-request-spec) Override this method to use a different upload spec.
  ///
  /// - Throws: Any error arising from creating the form data
  /// - Returns: The created form data
  public func requestMultipartFormData() throws -> MultipartFormData {
    let formData = MultipartFormData(boundary: multipartBoundary)

    // Make sure all fields for files are set to null, or the server won't look
    // for the files in the rest of the form data
    let fieldsForFiles = Set(files.map { $0.fieldName }).sorted()
    var fields = self.requestBodyCreator.requestBody(for: self,
                                                     sendQueryDocument: true,
                                                     autoPersistQuery: false)
    var variables = fields["variables"] as? JSONEncodableDictionary ?? JSONEncodableDictionary()
    for fieldName in fieldsForFiles {
      if let value = variables[fieldName],
         let arrayValue = value as? [any JSONEncodable] {
        let arrayOfNils: [NSNull?] = arrayValue.map { _ in NSNull() }
        variables.updateValue(arrayOfNils, forKey: fieldName)
      } else {
        variables.updateValue(NSNull(), forKey: fieldName)
      }
    }
    fields["variables"] = variables    

    let operationData = try JSONSerializationFormat.serialize(value: fields)
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

    let mapData = try JSONSerializationFormat.serialize(value: map)
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

  // MARK: - Equtable/Hashable Conformance

  public static func == (lhs: UploadRequest<Operation>, rhs: UploadRequest<Operation>) -> Bool {
    lhs.graphQLEndpoint == rhs.graphQLEndpoint &&
    lhs.operation == rhs.operation &&
    lhs.additionalHeaders == rhs.additionalHeaders &&
    lhs.fetchBehavior == rhs.fetchBehavior &&
    type(of: lhs.requestBodyCreator) == type(of: rhs.requestBodyCreator) &&
    lhs.files == rhs.files &&
    lhs.multipartBoundary == rhs.multipartBoundary
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(graphQLEndpoint)
    hasher.combine(operation)
    hasher.combine(additionalHeaders)
    hasher.combine(fetchBehavior)
    hasher.combine("\(type(of: requestBodyCreator))")
    hasher.combine(files)
    hasher.combine(multipartBoundary)
  }
}
