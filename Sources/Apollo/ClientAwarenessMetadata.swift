import Foundation
import ApolloAPI

/// A data structure containing telemetry metadata about the client. This is used by GraphOS Studio's
/// [client awareness](https://www.apollographql.com/docs/graphos/platform/insights/client-segmentation)
/// feature.
public struct ClientAwarenessMetadata: Sendable {

  /// The name of the application. This value is sent for the header "apollographql-client-name".
  ///
  /// Defaults to `nil`.
  public let clientApplicationName: String?

  /// The version of the application. This value is sent for the header "apollographql-client-version".
  ///
  /// Defaults to `nil`.
  public let clientApplicationVersion: String?

  /// Determines if the Apollo iOS library name and version should be sent with the telemetry data.
  ///
  /// If `true`, the JSON body of the request will include a "clientLibrary" extension containing
  /// the name of the Apollo iOS library and the version of Apollo iOS being used by the client
  /// application.
  ///
  /// Defaults to `true`.
  public let includeApolloLibraryAwareness: Bool

  public init(
    clientApplicationName: String? = nil,
    clientApplicationVersion: String? = nil,
    includeApolloLibraryAwareness: Bool = true
  ) {
    self.clientApplicationName = clientApplicationName
    self.clientApplicationVersion = clientApplicationVersion
    self.includeApolloLibraryAwareness = includeApolloLibraryAwareness
  }

  /// Disables all client awareness metadata.
  public static var none: ClientAwarenessMetadata {
    .init(
      clientApplicationName: nil,
      clientApplicationVersion: nil,
      includeApolloLibraryAwareness: false
    )
  }

  /// Enables all client awareness metadata with the following default values:
  ///
  /// - `clientApplicationName`: The application's bundle identifier + "-apollo-ios".
  /// - `clientApplicationVersion`: The bundle's short version string if available,
  ///     otherwise the build number.
  /// - `includeApolloiOSLibraryVersion`: `true`
  public static var enabledWithDefaults: ClientAwarenessMetadata {
    .init(
      clientApplicationName: defaultClientName,
      clientApplicationVersion: defaultClientVersion,
      includeApolloLibraryAwareness: true
    )
  }

  /// The default client name to use when setting up the `clientName` property
  public static var defaultClientName: String {
    guard let identifier = Bundle.main.bundleIdentifier else {
      return "apollo-ios-client"
    }

    return "\(identifier)-apollo-ios"
  }

  /// The default client version to use when setting up the `clientVersion` property.
  public static var defaultClientVersion: String {
    var version = String()
    if let shortVersion = Bundle.main.shortVersion {
      version.append(shortVersion)
    }

    if let buildNumber = Bundle.main.buildNumber {
      if version.isEmpty {
        version.append(buildNumber)
      } else {
        version.append("-\(buildNumber)")
      }
    }

    if version.isEmpty {
      version = "(unknown)"
    }

    return version
  }

  struct Constants {
    /// The field name for the Apollo Client Name header
    static let clientApplicationNameKey: StaticString = "apollographql-client-name"

    /// The field name for the Apollo Client Version header
    static let clientApplicationVersionKey: StaticString = "apollographql-client-version"
  }

  /// A helper method that adds the client awareness headers to the given request
  /// This is used by GraphOS Studio's
  /// [client awareness](https://www.apollographql.com/docs/graphos/platform/insights/client-segmentation)
  /// feature.
  ///
  /// - Parameters:
  ///   - clientAwarenessMetadata: The client name. The telemetry metadata about the client.
  public func applyHeaders(
    to request: inout URLRequest
  ) {
    if let clientApplicationName = self.clientApplicationName {
      request.addValue(
        clientApplicationName,
        forHTTPHeaderField: ClientAwarenessMetadata.Constants.clientApplicationNameKey.description
      )
    }

    if let clientApplicationVersion = self.clientApplicationVersion {
      request.addValue(
        clientApplicationVersion,
        forHTTPHeaderField: ClientAwarenessMetadata.Constants.clientApplicationVersionKey.description
      )
    }
  }

  /// Adds client metadata to the request body in the `extensions` key.
  ///
  /// - Parameter body: The previously generated JSON body.
  func applyExtension(to body: inout JSONEncodableDictionary) {
    if self.includeApolloLibraryAwareness {
      let clientLibraryMetadata: JSONEncodableDictionary = [
        "name": Apollo.Constants.ApolloClientName,
        "version": Apollo.Constants.ApolloClientVersion
      ]

      var extensions = body["extensions"] as? JSONEncodableDictionary ?? JSONEncodableDictionary()
      extensions["clientLibrary"] = clientLibraryMetadata
      
      body["extensions"] = extensions
    }
  }
}
