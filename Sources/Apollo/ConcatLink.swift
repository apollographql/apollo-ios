extension NonTerminatingLink {
  public func concat(_ next: NonTerminatingLink) -> NonTerminatingLink {
    return NonTerminatingConcatLink(first: self, second: next)
  }
  
  public func concat(_ next: TerminatingLink) -> TerminatingLink {
    return TerminatingConcatLink(first: self, second: next)
  }
}

fileprivate class NonTerminatingConcatLink: NonTerminatingLink {
  private var first: NonTerminatingLink
  private var second: NonTerminatingLink
  
  init(first: NonTerminatingLink, second: NonTerminatingLink) {
    self.first = first
    self.second = second
  }
  
  func request<Operation>(operation: Operation, context: LinkContext, forward: @escaping NextLink<Operation>) -> Promise<GraphQLResponse<Operation>> {
    return first.request(operation: operation, context: context) {
      return self.second.request(operation: $0, context: $1, forward: forward)
    }
  }
}

fileprivate class TerminatingConcatLink: TerminatingLink {
  private var first: NonTerminatingLink
  private var second: TerminatingLink
  
  init(first: NonTerminatingLink, second: TerminatingLink) {
    self.first = first
    self.second = second
  }
  
  func request<Operation>(operation: Operation, context: LinkContext) -> Promise<GraphQLResponse<Operation>> {
    return first.request(operation: operation, context: context) {
      return self.second.request(operation: $0, context: $1)
    }
  }
}
