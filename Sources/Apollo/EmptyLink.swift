fileprivate final class EmptyLink: TerminatingLink {
  public func request<Operation>(operation: Operation, context: LinkContext) -> Promise<GraphQLResponse<Operation>> {
    return Promise(fulfilled: GraphQLResponse(operation: operation, body: [:]))
  }
}

public let emptyLink: TerminatingLink = EmptyLink()
