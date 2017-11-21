extension NonTerminatingLink {
  public func split(first: TerminatingLink, second: TerminatingLink, test: @escaping (GraphQLOperationBase) -> Bool) -> TerminatingLink {
    return concat(TerminatingSplitLink(first: first, second: second, test: test))
  }
  
  public func split(first: NonTerminatingLink, second: NonTerminatingLink, test: @escaping (GraphQLOperationBase) -> Bool) -> NonTerminatingLink {
    return concat(NonTerminatingSplitLink(first: first, second: second, test: test))
  }
}

fileprivate final class TerminatingSplitLink: TerminatingLink {
  private var first: TerminatingLink
  private var second: TerminatingLink
  private var test: (GraphQLOperationBase) -> Bool
  
  init(first: TerminatingLink, second: TerminatingLink, test: @escaping (GraphQLOperationBase) -> Bool) {
    self.first = first
    self.second = second
    self.test = test
  }
  
  func request<Operation>(operation: Operation, context: LinkContext) -> Promise<GraphQLResponse<Operation>> {
    if test(operation) {
      return first.request(operation: operation, context: context)
    }
    else {
      return second.request(operation: operation, context: context)
    }
  }
}

fileprivate final class NonTerminatingSplitLink: NonTerminatingLink {
  private var first: NonTerminatingLink
  private var second: NonTerminatingLink
  private var test: (GraphQLOperationBase) -> Bool
  
  init(first: NonTerminatingLink, second: NonTerminatingLink, test: @escaping (GraphQLOperationBase) -> Bool) {
    self.first = first
    self.second = second
    self.test = test
  }
  
  func request<Operation>(operation: Operation, context: LinkContext, forward: @escaping NextLink<Operation>) -> Promise<GraphQLResponse<Operation>> {
    if test(operation) {
      return first.request(operation: operation, context: context, forward: forward)
    }
    else {
      return second.request(operation: operation, context: context, forward: forward)
    }
  }
}
