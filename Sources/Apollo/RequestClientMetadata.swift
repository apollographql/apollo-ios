import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

extension JSONRequest {
  /// Adds client metadata to the request body in the `extensions` key.
  ///
  /// - Parameter body: The previously generated JSON body.
  func addEnhancedClientAwarenessExtension(to body: inout JSONEncodableDictionary) {
    _addEnhancedClientAwarenessExtension(to: &body)
  }
}

extension UploadRequest {
  /// Adds client metadata to the request body in the `extensions` key.
  ///
  /// - Parameter body: The previously generated JSON body.
  func addEnhancedClientAwarenessExtension(to body: inout JSONEncodableDictionary) {
    _addEnhancedClientAwarenessExtension(to: &body)
  }
}

fileprivate func _addEnhancedClientAwarenessExtension(to body: inout JSONEncodableDictionary) {
  let clientLibraryMetadata: JSONEncodableDictionary = [
    "name": Constants.ApolloClientName,
    "version": Constants.ApolloClientVersion
  ]

  var extensions = body["extensions"] as? JSONEncodableDictionary ?? JSONEncodableDictionary()
  extensions["clientLibrary"] = clientLibraryMetadata

  body["extensions"] = extensions
}
