#if !COCOAPODS
import ApolloAPI
#endif

/// A `PaginationMergeStrategy` which naively merges all lists together in a response, outputting a `Query.Data`.
public class SimplePaginationMergeStrategy<Query: GraphQLQuery>: PaginationMergeStrategy {

  /// Designated initializer
  public init() { }

  /// The function by which we merge several responses, in the form of a `PaginationDataResponse` into one `Output`.
  /// - Parameter paginationResponse: A data type which contains the most recent response, the source of that response, and all other responses.
  /// - Returns: `Output`
  public func mergePageResults(paginationResponse: PaginationDataResponse<Query, Query.Data>) -> Query.Data {
    var dataDict = DataDict(data: [:], fulfilledFragments: [])
    dataDict = dataDict.mergeMany(sets: paginationResponse.allResponses.map { $0.__data })
    return Query.Data(_dataDict: dataDict)
  }
}

private extension DataDict {
  func mergeMany(
    sets: [DataDict]
  ) -> DataDict {
    var data: DataDict = .init(data: [:], fulfilledFragments: [])
    sets.forEach { selectionSet in
      data = data.merge(selectionSet: selectionSet)
    }
    return data
  }

  func merge(selectionSet: DataDict) -> DataDict {
    let values: [(String, AnyHashable)] = selectionSet._data.map { k, v in
      let currentValue = self._data[k]
      let newValue = v

      if let currentValue = currentValue as? DataDict, let newValue = newValue as? DataDict {
        // The value exists in both the current dictionary as well as the new dictionary
        // The value is a dictionary
        // Therefore, we must recurse deeper until we hit a concrete value.
        return (k, currentValue.merge(selectionSet: newValue))
      } else if let currentValue = currentValue as? [DataDict],
                let newValue = newValue as? [DataDict] {
        // The value is a list.
        // Lists are what we target to combine and paginate over.
        let combinedData: [DataDict] = currentValue + newValue
        return (k, combinedData)
      } else {
        // The value is an object or scalar.
        // Prefer the `newValue` over the `currentValue`, as the `currentValue` may not exist in the first iteration
        // of this function. Further, the `Simple` strategy assumes the simple use-case of pagination; the latest page
        // in a series of pages has the latest data.
        return (k, newValue)
      }
    }

    return DataDict(
      data: values.reduce(into: [:]) { $0[$1.0] = $1.1 },
      fulfilledFragments: selectionSet._fulfilledFragments
    )
  }
}
