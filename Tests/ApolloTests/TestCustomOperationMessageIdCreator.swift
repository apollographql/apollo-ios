import Apollo

struct TestCustomOperationMessageIdCreator: OperationMessageIdCreator {
  func requestId() -> String {
    return "12345678"
  }
}
