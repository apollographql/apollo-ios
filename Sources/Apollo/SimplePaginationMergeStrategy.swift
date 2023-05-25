#if !COCOAPODS
import ApolloAPI
#endif

/// A `PaginationMergeStrategy` which naively merges all lists together in a response, outputting a `Query.Data`.
public class SimplePaginationMergeStrategy<Query: GraphQLQuery>: PaginationMergeStrategy {
  public init() { }

  /// The function by which we merge several responses, in the form of a `PaginationDataResponse` into one `Output`.
  /// - Parameter paginationResponse: A data type which contains the most recent response, the source of that response, and all other responses.
  /// - Returns: `Output`
  public func mergePageResults(paginationResponse: PaginationDataResponse<Query, Query.Data>) -> Query.Data {
    var json: [String: AnyHashable] = [:]
    json = json.mergeMany(
      sets: paginationResponse.allResponses.map { $0.__data._data },
      mostRecent: paginationResponse.mostRecent.__data._data
    )
    return Query.Data.init(_dataDict: .init(data: json, fulfilledFragments: paginationResponse.mostRecent.__data._fulfilledFragments))
  }
}

private extension [String: AnyHashable] {
  func mergeMany(
    sets: [[String: AnyHashable]],
    mostRecent: [String: AnyHashable]
  ) -> [String: AnyHashable] {
    var data: [String: AnyHashable] = [:]
    sets.forEach { selectionSet in
      data = data.merge(selectionSet: selectionSet)
    }
    return data
  }

  func merge(selectionSet: [String: AnyHashable]) -> [String: AnyHashable] {
    let values: [(String, AnyHashable)] = selectionSet.map { k, v in
      let currentValue = self[k]
      let newValue = v

      if let currentValue = currentValue as? [String: AnyHashable],
         let newValue = newValue as? [String: AnyHashable] {
        // The value exists in both the current dictionary as well as the new dictionary
        // The value is a dictionary
        // Therefore, we must recurse deeper until we hit a concrete value.
        return (k, currentValue.merge(selectionSet: newValue))
      } else if let currentValue = currentValue as? [[String: AnyHashable]],
                let newValue = newValue as? [[String: AnyHashable]],
                let combinedArray = (currentValue + newValue) as? AnyHashable {
        // The value is a list.
        // Lists are what we target to combine and paginate over.
        return (k, combinedArray)
      } else {
        // The value is an object or scalar.
        // Prefer the `newValue` over the `currentValue`, as the `currentValue` may not exist in the first iteration
        // of this function. Further, the `Simple` strategy assumes the simple use-case of pagination; the latest page
        // in a series of pages has the latest data.
        return (k, newValue)
      }
    }

    return values.reduce(into: [:]) { $0[$1.0] = $1.1 }
  }
}
