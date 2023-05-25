#if !COCOAPODS
import ApolloAPI
#endif

/// A `PaginationMergeStrategy` which merges a specific list together in a response, outputting a `Query.Data`.
public class TargetedPaginationMergeStrategy<Query: GraphQLQuery>: PaginationMergeStrategy {
  let keyPath: AnyKeyPath

  /// Designated initializer
  /// - Parameter targetedKeyPath: `KeyPath` that leads to the list of results to be concatenated.
  public init(
    targetedKeyPath: KeyPath<Query.Data, [some SelectionSet]>
  ) {
    self.keyPath = targetedKeyPath
  }

  /// The function by which we merge several responses, in the form of a `PaginationDataResponse` into one `Query.Data`.
  /// - Parameter paginationResponse: A data type which contains the most recent response, the source of that response, and all other responses.
  /// - Returns: `Query.Data`
  public func mergePageResults(paginationResponse: PaginationDataResponse<Query, Query.Data>) -> Query.Data {
    var json: [String: AnyHashable] = [:]
    json = json.mergeMany(
      sets: paginationResponse.allResponses.map { $0.__data._data },
      lists: paginationResponse.allResponses.compactMap { $0[keyPath: keyPath] as? [any SelectionSet] }
    )
    return Query.Data.init(_dataDict: .init(data: json, fulfilledFragments: paginationResponse.mostRecent.__data._fulfilledFragments))
  }
}

private extension [String: AnyHashable] {
  func mergeMany(
    sets: [[String: AnyHashable]],
    lists: [[any SelectionSet]]
  ) -> [String: AnyHashable] {
    var data: [String: AnyHashable] = [:]
    zip(sets, lists).forEach { (selectionSet, list) in
      data = data.merge(selectionSet: selectionSet, list: list)
    }
    return data
  }

  func merge(selectionSet: [String: AnyHashable], list: [any SelectionSet]) -> [String: AnyHashable] {
    let values: [(String, AnyHashable)] = selectionSet.map { k, v in
      let currentValue = self[k]
      let newValue = v

      if let currentValue = currentValue as? [String: AnyHashable],
         let newValue = newValue as? [String: AnyHashable] {
        // The value exists in both the current dictionary as well as the new dictionary
        // The value is a dictionary
        // Therefore, we must recurse deeper until we hit a concrete value.
        return (k, currentValue.merge(selectionSet: newValue, list: list))
      } else if let currentValue = currentValue as? [[String: AnyHashable]],
                let newValue = newValue as? [[String: AnyHashable]],
                newValue as AnyHashable == list.map({ $0.__data._data }) as AnyHashable,
                let combinedArray = (currentValue + newValue) as? AnyHashable {
        // The value is the targeted object. Combine the values and return them for a given key.
        return (k, combinedArray)
      } else {
        // The value is an object or scalar.
        // Prefer the `newValue` over the `currentValue`, as the `currentValue` may not exist in the first iteration
        // in a series of pages has the latest data.
        return (k, newValue)
      }
    }

    return values.reduce(into: [:]) { $0[$1.0] = $1.1 }
  }
}
