import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class GlobTests: XCTestCase {
  let baseURL = CodegenTestHelper.outputFolderURL().appendingPathComponent("Glob")

  // MARK: Setup

  override func setUpWithError() throws {
    let fileManager = FileManager.default.apollo

    // <outputFolder>/Glob/
    try fileManager.createDirectoryIfNeeded(atPath: baseURL.path)

    let files = [
      self.baseURL.appendingPathComponent("file.one").path, // <outputFolder>/Glob/file.one
      self.baseURL.appendingPathComponent("file.two").path, // <outputFolder>/Glob/file.two
      self.baseURL.appendingPathComponent("a/file.one").path, // <outputFolder>/Glob/a/file.one
      self.baseURL.appendingPathComponent("a/b/file.one").path, // <outputFolder>/Glob/a/b/file.one
      self.baseURL.appendingPathComponent("a/b/c/file.one").path, // <outputFolder>/Glob/a/b/c/file.one
      self.baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path, // <outputFolder>/Glob/a/b/c/d/e/f/file.one
      self.baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path, // <outputFolder>/Glob/a/b/c/d/e/f/file.two
      self.baseURL.appendingPathComponent("other/file.one").path, // <outputFolder>/Glob/other/file.one
      self.baseURL.appendingPathComponent("other/file.oye").path // <outputFolder>/Glob/other/file.oye
    ]

    for file in files {
      expect(try fileManager.createFile(atPath: file)).to(beTrue())
    }
  }

  override func tearDownWithError() throws {
    try FileManager.default.apollo.deleteDirectory(atPath: baseURL.path)
  }

  // MARK: Tests

  func test_match_givenSinglePattern_whenNoMatch_shouldReturnEmpty() throws {
    // given
    let pattern = baseURL.appendingPathComponent("*.xyz").path

    // when
    // <baseURL>/file.one
    // <baseURL>/file.two

    // then
    let results = try Glob([pattern]).match()

    expect(results).to(beEmpty())
  }

  func test_match_givenSinglePattern_usingAnyWildcard_whenSingleMatch_shouldReturnSingle() throws {
    // given
    let pattern = baseURL.appendingPathComponent("*.one").path

    // when
    // <baseURL>/file.one
    // <baseURL>/file.two

    // then
    expect(Glob([pattern]).match).to(equal([
      baseURL.appendingPathComponent("file.one").path
    ]))
  }

  func test_match_givenSinglePattern_usingAnyWildcard_whenMultipleMatch_shouldReturnMultiple() throws {
    // given
    let pattern = baseURL.appendingPathComponent("file.*").path

    // when
    // <baseURL>/file.one
    // <baseURL>/file.two

    // then
    expect(Glob([pattern]).match).to(equal([
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("file.two").path
    ]))
  }

  func test_match_givenSinglePattern_usingSingleWildcard_whenSingleMatch_shouldReturnSingle() throws {
    // given
    let pattern = baseURL.appendingPathComponent("fil?.one").path

    // when
    // <baseURL>/file.one
    // <baseURL>/file.two

    // then
    expect(Glob([pattern]).match).to(equal([
      baseURL.appendingPathComponent("file.one").path
    ]))
  }

  func test_match_givenSinglePattern_usingSingleWildcard_whenMultipleMatch_shouldReturnMultiple() throws {
    // given
    let pattern = baseURL.appendingPathComponent("other/file.o?e").path

    // when
    // <baseURL>/other/file.one
    // <baseURL>/other/file.oye

    // then
    expect(Glob([pattern]).match).to(equal([
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path
    ]))
  }

  func test_match_givenMultiplePattern_usingAnyWildcard_whenSingleMatch_shouldReturnSingle() throws {
    // given
    let pattern = [
      baseURL.appendingPathComponent("a/file.*").path,
      baseURL.appendingPathComponent("a/*.ext").path
    ]

    // when
    // <baseURL>/a/file.one

    // then
    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("a/file.one").path
    ]))
  }

  func test_match_givenMultiplePattern_usingAnyWildcard_whenMultipleMatch_shouldReturnMultiple() throws {
    // given
    let pattern = [
      baseURL.appendingPathComponent("a/file.*").path,
      baseURL.appendingPathComponent("other/file.*").path
    ]

    // when
    // <baseURL>/a/file.one
    // <baseURL>/other/file.one
    // <baseURL>/other/file.oye

    // then
    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path
    ]))
  }

  func test_match_givenMultiplePattern_usingSingleWildcard_whenSingleMatch_shouldReturnSingle() throws {
    // given
    let pattern = [
      baseURL.appendingPathComponent("a/file.?ne").path,
      baseURL.appendingPathComponent("other/file.?xt").path
    ]

    // when
    // <baseURL>/a/file.one
    // <baseURL>/other/file.one
    // <baseURL>/other/file.oye

    // then
    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("a/file.one").path
    ]))
  }

  func test_match_givenMultiplePattern_usingSingleWildcard_whenMultipleMatch_shouldReturnMultiple() throws {
    // given
    let pattern = [
      baseURL.appendingPathComponent("a/file.o?e").path,
      baseURL.appendingPathComponent("other/file.o?e").path
    ]

    // when
    // <baseURL>/a/file.one
    // <baseURL>/other/file.one
    // <baseURL>/other/file.oye

    // then
    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path
    ]))
  }

  func test_match_givenSinglePattern_usingCombinedWildcard_whenSingleMatch_shouldReturnSingle() throws {
    // given
    let pattern = baseURL.appendingPathComponent("*.o?e").path

    // when
    // <baseURL>/file.one

    // then
    expect(Glob([pattern]).match).to(equal([
      baseURL.appendingPathComponent("file.one").path
    ]))
  }

  func test_match_givenMultiplePattern_usingCombinedWildcard_whenMultipleMatch_shouldReturnMultiple() throws {
    // given
    let pattern = [
      baseURL.appendingPathComponent("file.*").path,
      baseURL.appendingPathComponent("other/file.o?e").path
    ]

    // when
    // <baseURL>/file.one
    // <baseURL>/file.two
    // <baseURL>/other/file.one
    // <baseURL>/other/file.oye

    // then
    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("file.two").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path
    ]))
  }

  func test_match_givenGlobstarPattern_usingAnyWildcard_whenSingleMatch_shouldReturnSingle() throws {
    // given
    let pattern = baseURL.appendingPathComponent("a/b/c/d/**/*.one").path

    // when
    // <baseURL>/a/b/c/d/e/f/file.one
    // <baseURL>/a/b/c/d/e/f/file.two

    // then
    expect(Glob([pattern]).match).to(equal([
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path
    ]))
  }

  func test_match_givenGlobstarPattern_usingAnyWildcard_whenMultipleMatch_shouldReturnMultiple() throws {
    // given
    let pattern = baseURL.appendingPathComponent("a/b/c/d/**/file.*").path

    // when
    // <baseURL>/a/b/c/d/e/f/file.one
    // <baseURL>/a/b/c/d/e/f/file.two

    // then
    expect(Glob([pattern]).match).to(equal([
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path
    ]))
  }

  func test_match_givenGlobstarPattern_usingSingleWildcard_whenSingleMatch_shouldReturnSingle() throws {
    // given
    let pattern = baseURL.appendingPathComponent("a/b/c/d/**/?ile.one").path

    // when
    // <baseURL>/a/b/c/d/e/f/file.one
    // <baseURL>/a/b/c/d/e/f/file.two

    // then
    expect(Glob([pattern]).match).to(equal([
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path
    ]))
  }

  func test_match_givenGlobstarPattern_usingCombinedWildcard_whenMultipleMatch_shouldReturnMultiple() throws {
    // given
    let pattern = baseURL.appendingPathComponent("a/b/c/d/**/fil?.*").path

    // when
    // <baseURL>/a/b/c/d/e/f/file.one
    // <baseURL>/a/b/c/d/e/f/file.two

    // then
    expect(Glob([pattern]).match).to(equal([
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path
    ]))
  }

  #warning("TODO - test globstar negation")
}
