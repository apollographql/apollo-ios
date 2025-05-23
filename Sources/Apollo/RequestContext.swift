import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// A marker protocol to set up an object to pass through the request chain.
///
/// Used to allow additional context-specific information to pass the length of the request chain.
///
/// This allows the various interceptors to make modifications, or perform actions, with information
/// that they cannot get just from the existing operation. It can be anything that conforms to this protocol.
public protocol RequestContext {}

/// A request context specialization protocol that specifies options for configuring the timeout of a `URLRequest`.
///
/// A `RequestContext` object can conform to this protocol to provide a custom `requestTimeout` for an individual
/// request. If the `RequestContext` for a request does not conform to this protocol, the default request timeout
/// of `URLRequest` will be used.
public protocol RequestContextTimeoutConfigurable: RequestContext {
  /// The timeout interval specifies the limit on the idle interval allotted to a request in the process of
  /// loading. This timeout interval is measured in seconds.
  ///
  /// The value of this property will be set as the `timeoutInterval` on the `URLRequest` created for this GraphQL request.
  var requestTimeout: TimeInterval { get }
}
