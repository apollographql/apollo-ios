public protocol NonTerminatingLink: class {
  func request<Operation>(operation: Operation, context: LinkContext, forward: @escaping NextLink<Operation>) -> Promise<GraphQLResponse<Operation>>
}

public func link(from links: [NonTerminatingLink]) -> NonTerminatingLink {
  guard let firstLink = links.first else {
    return passthroughLink
  }
  
  return links[1...].reduce(firstLink, { (chain, nextLink) in
    chain.concat(nextLink)
  })
}

public func link(from links: [NonTerminatingLink], file: StaticString = #file, line: UInt = #line) -> TerminatingLink {
  return link(from: links).makeTerminating(file: file, line: line)
}

public func link(from links: [NonTerminatingLink], terminating terminatingLink: TerminatingLink) -> TerminatingLink {
  return link(from: links).concat(terminatingLink)
}
