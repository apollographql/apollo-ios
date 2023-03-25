import Foundation

#if !COCOAPODS
import ApolloAPI
#endif

extension RootSelectionSet {

  /// Initializes a `SelectionSet` with a raw JSON response object.
  ///
  /// The process of converting a JSON response into `SelectionSetData` is done by using a
  /// `GraphQLExecutor` with a`GraphQLSelectionSetMapper` to parse, validate, and transform
  /// the JSON response data into the format expected by `SelectionSet`.
  ///
  /// - Parameters:
  ///   - data: A dictionary representing a JSON response object for a GraphQL object.
  ///   - variables: [Optional] The operation variables that would be used to obtain
  ///                the given JSON response data.
  public init(
    data: JSONObject,
    variables: GraphQLOperation.Variables? = nil
  ) throws {
    let accumulator = GraphQLSelectionSetMapper<Self>(
      handleMissingValues: .allowForOptionalFields
    )
    let executor = GraphQLExecutor { object, info in
      return object[info.responseKeyForField]
    }
    executor.shouldComputeCachePath = false

    self = try executor.execute(
      selectionSet: Self.self,
      on: data,
      variables: variables,
      accumulator: accumulator
    )
  }

}
