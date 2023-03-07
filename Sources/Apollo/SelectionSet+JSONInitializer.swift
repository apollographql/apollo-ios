import Foundation

#if !COCOAPODS
import ApolloAPI
#endif

extension RootSelectionSet {

#warning("TODO: Update documentation here")
  /// Initializes the `SelectionSet` **unsafely** with an unsafe result data dictionary.
  ///
  /// - Warning: This method is unsafe and improper use may result in unintended consequences
  /// including crashes. The `unsafeData` should mirror the result data returned by a
  /// `GraphQLSelectionSetMapper` after completion of GraphQL Execution.
  ///
  /// This is not identical to the JSON response from a GraphQL network request. The data should be
  /// normalized and custom scalars should be converted to their concrete types.
  ///
  /// To create a `SelectionSet` from data representing a JSON format GraphQL network response
  /// directly, create a `GraphQLResponse` object and call `parseResultFast()`.
  public init(
    data: JSONObject,
    variables: GraphQLOperation.Variables? = nil
  ) throws {
    let accumulator = GraphQLSelectionSetMapper<Self>(
      allowMissingValuesForOptionalFields: true
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
