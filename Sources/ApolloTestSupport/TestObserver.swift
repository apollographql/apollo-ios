import ApolloUtils
import XCTest

public class TestObserver: NSObject, XCTestObservation {

  private let onFinish: (XCTestCase) -> Void  

  private let isStarted = Atomic<Bool>(false)
  let stopAfterEachTest: Bool

  public init(
    startOnInit: Bool = true,
    stopAfterEachTest: Bool = true,
    onFinish: @escaping ((XCTestCase) -> Void)
  ) {
    self.stopAfterEachTest = stopAfterEachTest
    self.onFinish = onFinish
    super.init()

    if startOnInit { start() }
  }

  public func start() {
    guard !isStarted.value else { return }
    isStarted.mutate {
      XCTestObservationCenter.shared.addTestObserver(self)
      $0 = true
    }
  }

  public func stop() {
    guard isStarted.value else { return }
    isStarted.mutate {
      XCTestObservationCenter.shared.removeTestObserver(self)
      $0 = false
    }
  }

  public func testCaseDidFinish(_ testCase: XCTestCase) {
    onFinish(testCase)
    if stopAfterEachTest { stop() }
  }
}
