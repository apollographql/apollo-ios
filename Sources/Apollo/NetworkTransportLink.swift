final class NetworkTransportLink: TerminatingLink {
  let networkTransport: NetworkTransport
  
  init(networkTransport: NetworkTransport) {
    self.networkTransport = networkTransport
  }
  
  public func request<Operation>(operation: Operation, context: LinkContext) -> Promise<GraphQLResponse<Operation>> {
    return Promise({ (fulfill, reject) in
      guard !context.signal.isCancelled else {
        throw CancelError()
      }
      
      let request = networkTransport.send(operation: operation, completionHandler: { (response, error) in
        if let error = error {
          reject(error)
          return
        }
        
        if let response = response {
          fulfill(response)
          return
        }
      })
      
      context.signal.onCancel {
        request.cancel()
      }
    })
  }
}
