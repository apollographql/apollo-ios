import XCTest
import Nimble
@testable import CodegenCLI
import ArgumentParser
import ApolloCodegenLib

class VersionCheckerTests: XCTestCase {

  func test__codegenLibVersion() {
    let version = VersionChecker.Versions.codegenLibVersion

    expect(version).to(equal("1.0.3"))
  }
}
