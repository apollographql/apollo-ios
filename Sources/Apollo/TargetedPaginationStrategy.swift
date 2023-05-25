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
    var dataDict = DataDict(data: [:], fulfilledFragments: [])
    dataDict = dataDict.mergeMany(
      sets: paginationResponse.allResponses.map { $0.__data },
      lists: paginationResponse.allResponses.compactMap { $0[keyPath: keyPath] as? [any SelectionSet] }
    )
    return Query.Data(_dataDict: dataDict)
  }
}

private extension DataDict {
  func mergeMany(
    sets: [DataDict],
    lists: [[any SelectionSet]]
  ) -> DataDict {
    var data: DataDict = .init(data: [:], fulfilledFragments: [])
    zip(sets, lists).forEach { (selectionSet, list) in
      data = data.merge(selectionSet: selectionSet, list: list)
    }
    return data
  }

  func merge(selectionSet: DataDict, list: [any SelectionSet]) -> DataDict {
    let values: [(String, AnyHashable)] = selectionSet._data.map { k, v in
      let currentValue = self._data[k]
      let newValue = v

      if let currentValue = currentValue as? DataDict,
         let newValue = newValue as? DataDict {
        // The value exists in both the current dictionary as well as the new dictionary
        // The value is a dictionary
        // Therefore, we must recurse deeper until we hit a concrete value.
        return (k, currentValue.merge(selectionSet: newValue, list: list))
      } else if let currentValue = currentValue as? [DataDict],
                let newValue = newValue as? [DataDict],
                newValue.map({ $0._data }) as AnyHashable == list.map({ $0.__data._data }) as AnyHashable {
        // The value is the targeted object. Combine the values and return them for a given key.
        let combinedData: [DataDict] = currentValue + newValue
        return (k, combinedData)
      } else {
        // The value is an object or scalar.
        // Prefer the `newValue` over the `currentValue`, as the `currentValue` may not exist in the first iteration
        // in a series of pages has the latest data.
        return (k, newValue)
      }
    }

    return DataDict(
      data: values.reduce(into: [:]) { $0[$1.0] = $1.1 },
      fulfilledFragments: selectionSet._fulfilledFragments.union(_fulfilledFragments)
    )
  }
}
