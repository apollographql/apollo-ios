import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A wrapper for data about a particular task handled by `URLSessionClient`
public class TaskData {
  
  public let rawCompletion: URLSessionClient.RawCompletion?
  public let completionBlock: URLSessionClient.Completion
  private(set) var data: Data = Data()
  private(set) var response: HTTPURLResponse? = nil
  
  init(rawCompletion: URLSessionClient.RawCompletion?,
       completionBlock: @escaping URLSessionClient.Completion) {
    self.rawCompletion = rawCompletion
    self.completionBlock = completionBlock
  }
  
  func append(additionalData: Data) {
    self.data.append(additionalData)
  }

  func reset(data: Data?) {
    guard let data, !data.isEmpty else {
      self.data = Data()
      return
    }

    self.data = data
  }
  
  func responseReceived(response: URLResponse) {
    if let httpResponse = response as? HTTPURLResponse {
      self.response = httpResponse
    }
  }
}
