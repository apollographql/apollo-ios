import Foundation
#if !COCOAPODS
import ApolloMigrationAPI
#endif

/// A marker protocol to set up an object to pass through the request chain.
///
/// Used to allow additional context-specific information to pass the length of the request chain.
///
/// This allows the various interceptors to make modifications, or perform actions, with information
/// that they cannot get just from the existing operation. It can be anything that conforms to this protocol.
public protocol RequestContext {}
