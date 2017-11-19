fileprivate final class PassthroughLink: NonTerminatingLink {
  public func request<Operation>(operation: Operation, context: LinkContext, forward: @escaping NextLink<Operation>) -> Promise<GraphQLResponse<Operation>> {
    return forward(operation, context)
  }
}

public let passthroughLink: NonTerminatingLink = PassthroughLink()
