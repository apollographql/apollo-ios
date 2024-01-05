#if !COCOAPODS
import ApolloAPI
#endif

/// Represents an incremental result received as part of a deferred incremental response.
///
/// This is not a type exposed to users as a final result, it is an intermediate result that is
/// merged into a final result.
struct IncrementalGraphQLResult {
  /// This is the same label identifier passed to the `@defer` directive associated with the
  /// response.
  let label: String
  /// Allows for the association to a particular field in a GraphQL result. This will be a list of
  /// path segments starting at the root of the response and ending with the field to be associated
  /// with.
  let path: [PathComponent]
  /// The typed result data, or `nil` if an error was encountered that prevented a valid response.
  let data: (any SelectionSet)?
  /// A list of errors, or `nil` if the operation completed without encountering any errors.
  let errors: [GraphQLError]?
  /// A dictionary which services can use however they see fit to provide additional information to clients.
  let extensions: [String: AnyHashable]?

  let dependentKeys: Set<CacheKey>?

  init(
    label: String,
    path: [PathComponent],
    data: (any SelectionSet)?,
    extensions: [String: AnyHashable]?,
    errors: [GraphQLError]?,
    dependentKeys: Set<CacheKey>?
  ) {
    self.label = label
    self.path = path
    self.data = data
    self.extensions = extensions
    self.errors = errors
    self.dependentKeys = dependentKeys
  }
}
