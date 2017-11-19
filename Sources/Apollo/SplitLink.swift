extension NonTerminatingLink {
  public func split(first: TerminatingLink, second: TerminatingLink, test: @escaping (LinkOperationDescriptor) -> Bool) -> TerminatingLink {
    return concat(TerminatingSplitLink(first: first, second: second, test: test))
  }
  
  public func split(first: NonTerminatingLink, second: NonTerminatingLink, test: @escaping (LinkOperationDescriptor) -> Bool) -> NonTerminatingLink {
    return concat(NonTerminatingSplitLink(first: first, second: second, test: test))
  }
}

public struct LinkOperationDescriptor {
  let rootCacheKey: String
  let operationString: String
  let requestString: String
  let operationIdentifier: String?
  let variables: GraphQLMap?
  let context: LinkContext
  
  fileprivate init<Operation: GraphQLOperation>(operation: Operation, context: LinkContext) {
    rootCacheKey = Operation.rootCacheKey
    operationString = Operation.operationString
    requestString = Operation.requestString
    operationIdentifier = Operation.operationIdentifier
    variables = operation.variables
    self.context = context
  }
}

fileprivate class TerminatingSplitLink: TerminatingLink {
  private var first: TerminatingLink
  private var second: TerminatingLink
  private var test: (LinkOperationDescriptor) -> Bool
  
  init(first: TerminatingLink, second: TerminatingLink, test: @escaping (LinkOperationDescriptor) -> Bool) {
    self.first = first
    self.second = second
    self.test = test
  }
  
  func request<Operation>(operation: Operation, context: LinkContext) -> Promise<GraphQLResponse<Operation>> {
    let descriptor = LinkOperationDescriptor(operation: operation, context: context)
    
    if test(descriptor) {
      return first.request(operation: operation, context: context)
    }
    else {
      return second.request(operation: operation, context: context)
    }
  }
}

fileprivate class NonTerminatingSplitLink: NonTerminatingLink {
  private var first: NonTerminatingLink
  private var second: NonTerminatingLink
  private var test: (LinkOperationDescriptor) -> Bool
  
  init(first: NonTerminatingLink, second: NonTerminatingLink, test: @escaping (LinkOperationDescriptor) -> Bool) {
    self.first = first
    self.second = second
    self.test = test
  }
  
  func request<Operation>(operation: Operation, context: LinkContext, forward: @escaping NextLink<Operation>) -> Promise<GraphQLResponse<Operation>> {
    let descriptor = LinkOperationDescriptor(operation: operation, context: context)
    
    if test(descriptor) {
      return first.request(operation: operation, context: context, forward: forward)
    }
    else {
      return second.request(operation: operation, context: context, forward: forward)
    }
  }
}
