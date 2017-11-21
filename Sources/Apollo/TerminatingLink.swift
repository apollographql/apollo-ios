public protocol TerminatingLink: class {
  func request<Operation>(operation: Operation, context: LinkContext) -> Promise<GraphQLResponse<Operation>>
}

extension TerminatingLink {
  public func execute<Operation>(operation: Operation, context: LinkContext? = nil) -> Promise<GraphQLResponse<Operation>> {
    return request(operation: operation, context: context ?? LinkContext())
  }
}
