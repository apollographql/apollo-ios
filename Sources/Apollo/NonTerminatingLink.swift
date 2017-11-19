public protocol NonTerminatingLink {
  func request<Operation>(operation: Operation, context: LinkContext, forward: @escaping NextLink<Operation>) -> Promise<GraphQLResponse<Operation>>
}
