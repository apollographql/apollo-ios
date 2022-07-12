import XCTest
@testable import Apollo
import Nimble

class ResponsePathTests: XCTestCase {

  func test__initializer__givenArray_shouldRespectKeyCasing() {
    let subject: ResponsePath = ["first", "Second", "Third"]

    expect(subject.joined).to(equal("first.Second.Third"))
  }

  func test__joined__givenArray_shouldReturnJoinedKeysInOrder() {
    let subject: ResponsePath = ["first", "second", "third"]

    expect(subject.joined).to(equal("first.second.third"))
  }

  func test__joined__whenAppendKey_shouldIncludeAppendedKeyLast() {
    var subject: ResponsePath = ["first", "second", "third"]
    subject.append("fourth")

    expect(subject.joined).to(equal("first.second.third.fourth"))
  }

  func test__joined__whenAddKey_shouldIncludeAddedKeyLast() {
    let paths: ResponsePath = ["first", "second"]
    let subject = paths + "third"

    expect(subject.joined).to(equal("first.second.third"))
  }

  func test__description__givenArray_shouldEqualJoined() {
    let subject: ResponsePath = ["first", "second", "third"]

    expect(subject.description).to(equal(subject.joined))
  }
}
