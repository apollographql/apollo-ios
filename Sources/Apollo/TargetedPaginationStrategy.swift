#if !COCOAPODS
import ApolloAPI
#endif

public class TargetedPaginationMergeStrategy<Query: GraphQLQuery>: PaginationMergeStrategy {
  let keyPath: KeyPath<Query.Data, [AnyHashable]>

  public init(
    targetedKeyPath: KeyPath<Query.Data, [AnyHashable]>
  ) {
    self.keyPath = targetedKeyPath
  }

  public func mergePageResults(paginationResponse: PaginationDataResponse<Query, Query.Data>) -> Query.Data {
    var json: DataDict.SelectionSetData = [:]
    json = json.mergeMany(
      sets: paginationResponse.allResponses.map { $0.__data._data },
      lists: paginationResponse.allResponses.map { $0[keyPath: keyPath] }
    )
    return Query.Data.init(_dataDict: .init(data: json))
  }
}

private extension DataDict.SelectionSetData {
  func mergeMany(
    sets: [DataDict.SelectionSetData],
    lists: [[AnyHashable]]
  ) -> DataDict.SelectionSetData {
    var data: DataDict.SelectionSetData = [:]
    zip(sets, lists).forEach { (selectionSet, list) in
      data = data.merge(selectionSet: selectionSet, list: list)
    }
    return data
  }

  func merge(selectionSet: DataDict.SelectionSetData, list: AnyHashable) -> DataDict.SelectionSetData {
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
                newValue as AnyHashable == list,
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
