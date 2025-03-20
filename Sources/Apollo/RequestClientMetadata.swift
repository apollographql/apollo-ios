import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

extension JSONRequest {
  /// Adds client metadata to the request body in the `extensions` key.
  ///
  /// - Parameter body: The previously generated JSON body.
  func addClientMetadataExtension(to body: inout JSONEncodableDictionary) {
    _addClientMetadataExtension(to: &body)
  }
}

extension UploadRequest {
  /// Adds client metadata to the request body in the `extensions` key.
  ///
  /// - Parameter body: The previously generated JSON body.
  func addClientMetadataExtension(to body: inout JSONEncodableDictionary) {
    _addClientMetadataExtension(to: &body)
  }
}

fileprivate func _addClientMetadataExtension(to body: inout JSONEncodableDictionary) {
  let clientLibraryMetadata: JSONEncodableDictionary = [
    "name": Constants.ApolloClientName,
    "version": Constants.ApolloClientVersion
  ]

  var extensions = body["extensions"] as? JSONEncodableDictionary ?? JSONEncodableDictionary()
  extensions["clientLibrary"] = clientLibraryMetadata

  body["extensions"] = extensions
}
