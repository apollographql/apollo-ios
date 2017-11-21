extension NonTerminatingLink {
  public func makeTerminating(file: StaticString = #file, line: UInt = #line) -> TerminatingLink {
    return concat(LimboLink(previousLink: self, file: file, line: line))
  }
}

fileprivate final class LimboLink: TerminatingLink {
  weak private var previousLink: NonTerminatingLink?
  private let file: StaticString
  private let line: UInt
  
  init(previousLink: NonTerminatingLink, file: StaticString, line: UInt) {
    self.previousLink = previousLink
    self.file = file
    self.line = line
  }
  
  func request<Operation>(operation: Operation, context: LinkContext) -> Promise<GraphQLResponse<Operation>> {
    guard let link = previousLink else {
      fatalError("Link did not terminate", file: file, line: line)
    }
    
    fatalError("\(link) did not terminate", file: file, line: line)
  }
}
