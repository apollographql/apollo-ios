import ApolloAPI

/// The `SimplePaginationStrategy`  is appropriate for most use cases.
/// **NOTE**: The `SimplePaginationStrategy` is only intended to work with a `Query.Data` response that that only contains paginated lists.
/// Including multiple paginated lists is fine, however, including a static list and a paginated list is unsupported; doing so would cause the static list to be duplicated by each page.
///
/// It functions by:
///   1. Having the user supply a function which can extract a `Page` from a given `Query.Data`.
///   2. Merging many `Query.Data` together such that new page data is prefered over old page data.
///   3. Returning a formed `Query.Data` to the user in a callback, which includes all page results and the cursor of the last page fetched so far. "Last" in this instance means "last in the list of pages", not "most recent".
public final class SimplePaginationStrategy<Query: GraphQLQuery>: PaginationStrategy {
  private var _extractPage: (Query.Data) -> Page?
  private var _resultHandler: (Result<Query.Data, Error>) -> Void

  /// Designated initializer
  /// - Parameters:
  ///   - extractPage: A user supplied function which can extract a `Page` from a given `Query.Data`
  ///   - resultHandler: A user supplied function which responds to the final output of the watcher.
  public init(
    extractPage: @escaping (Query.Data) -> Page?,
    resultHandler: @escaping (Result<Query.Data, Error>) -> Void
  ) {
    self._extractPage = extractPage
    self._resultHandler = resultHandler
  }

  public func transform(data: Query.Data) -> (Query.Data?, Page?)? {
    (data, _extractPage(data))
  }

  public func mergePageResults(response: PaginationDataResponse<Query, Query.Data>) -> Query.Data {
    var json: DataDict.SelectionSetData = [:]
    json = json.mergeMany(sets: response.allResponses.map { $0.__data._data }, mostRecent: response.mostRecent.__data._data)
    return Query.Data.init(_dataDict: .init(data: json))
  }

  public func resultHandler(result: Result<Query.Data, Error>) {
    _resultHandler(result)
  }
}

private extension DataDict.SelectionSetData {
  func mergeMany(sets: [DataDict.SelectionSetData], mostRecent: DataDict.SelectionSetData) -> DataDict.SelectionSetData {
    var data: DataDict.SelectionSetData = [:]
    sets.forEach { selectionSet in
      data = data.merge(selectionSet: selectionSet)
    }
    return data
  }

  func merge(selectionSet: DataDict.SelectionSetData) -> DataDict.SelectionSetData {
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
        // The value does not exist in the current dictionary. This is likely because the `currentValue` is represented by the initial empty dictionary.
        return (k, newValue)
      }
    }

    let dictionary = values.reduce(into: [:]) { $0[$1.0] = $1.1 }

    return dictionary
  }
}
