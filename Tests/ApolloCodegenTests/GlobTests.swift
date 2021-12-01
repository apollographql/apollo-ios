import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class GlobTests: XCTestCase {
  let baseURL = CodegenTestHelper.outputFolderURL().appendingPathComponent("Glob")
  let fileManager = FileManager.default.apollo

  // MARK: Setup

  override func setUpWithError() throws {
    try super.setUpWithError()

    try fileManager.createDirectoryIfNeeded(atPath: baseURL.path)
  }

  override func tearDownWithError() throws {
    try FileManager.default.apollo.deleteDirectory(atPath: baseURL.path)

    try super.tearDownWithError()
  }

  // MARK: Helpers

  private func create(files: [String]) throws {
    for file in files {
      expect(try self.fileManager.createFile(atPath: file)).to(beTrue())
    }
  }

  private func changeCurrentDirectory(to directory: String) throws {
    try fileManager.createDirectoryIfNeeded(atPath: directory)
    expect(self.fileManager.base.changeCurrentDirectoryPath(directory)).to(beTrue())
  }

  // MARK: Tests

  func test_match_givenSinglePattern_whenNoMatch_shouldReturnEmpty() throws {
    // given
    let pattern = baseURL.appendingPathComponent("*.xyz").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("file.two").path
    ])

    // then
    let results = try Glob([pattern]).match()

    expect(results).to(beEmpty())
  }

  func test_match_givenSinglePattern_usingAnyWildcard_whenSingleMatch_shouldReturnSingle() throws {
    // given
    let pattern = baseURL.appendingPathComponent("*.one").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("file.two").path
    ])

    // then
    expect(Glob([pattern]).match).to(equal([
      baseURL.appendingPathComponent("file.one").path
    ]))
  }

  func test_match_givenSinglePattern_usingAnyWildcard_whenMultipleMatch_shouldReturnMultiple() throws {
    // given
    let pattern = baseURL.appendingPathComponent("file.*").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("file.two").path
    ])

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
    try create(files: [
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("file.two").path
    ])

    // then
    expect(Glob([pattern]).match).to(equal([
      baseURL.appendingPathComponent("file.one").path
    ]))
  }

  func test_match_givenSinglePattern_usingSingleWildcard_whenMultipleMatch_shouldReturnMultiple() throws {
    // given
    let pattern = baseURL.appendingPathComponent("other/file.o?e").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path
    ])

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
    try create(files: [
      baseURL.appendingPathComponent("a/file.one").path
    ])

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
    try create(files: [
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path
    ])

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
    try create(files: [
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path
    ])

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
    try create(files: [
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path
    ])

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
    try create(files: [
      baseURL.appendingPathComponent("file.one").path
    ])

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
    try create(files: [
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("file.two").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path
    ])

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
    try create(files: [
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path
    ])

    // then
    expect(Glob([pattern]).match).to(equal([
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path
    ]))
  }

  func test_match_givenGlobstarPattern_usingAnyWildcard_whenMultipleMatch_shouldReturnMultiple() throws {
    // given
    let pattern = baseURL.appendingPathComponent("a/b/c/d/**/file.*").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path
    ])

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
    try create(files: [
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path
    ])

    // then
    expect(Glob([pattern]).match).to(equal([
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path
    ]))
  }

  func test_match_givenGlobstarPattern_usingCombinedWildcard_whenMultipleMatch_shouldReturnMultiple() throws {
    // given
    let pattern = baseURL.appendingPathComponent("a/b/c/d/**/fil?.*").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path
    ])

    // then
    expect(Glob([pattern]).match).to(equal([
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path
    ]))
  }

  func test_match_givenPattern_withExcludeNotFirst_shouldThrow() throws {
    // given
    let pattern = baseURL.appendingPathComponent("a/b/c/d/**/!file.swift").path

    // then
    expect(Glob([pattern]).match).to(throwError(Glob.MatchError.invalidExclude(path: pattern)))
  }

  func test_match_givenGlobstarPattern_usingPathExclude_whenMultipleMatch_shouldExclude() throws {
    // given
    let pattern = [
      baseURL.appendingPathComponent("a/b/c/d/**/file.*").path,
      "!" + baseURL.appendingPathComponent("a/b/c/d/**/file.two").path,
    ]

    // when
    try create(files: [
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path
    ])

    // then
    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path
    ]))
  }

  func test_match_givenRelativePattern_usingNoPrefix_andRootCurrentDirectory_shouldUseCurrentDirectory() throws {
    // given
    let pattern = ["**/*.one"]

    // when
    try changeCurrentDirectory(to: baseURL.path)

    try create(files: [
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("file.two").path,
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("a/b/file.one").path,
      baseURL.appendingPathComponent("a/b/c/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path
    ])

    // then
    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("a/b/file.one").path,
      baseURL.appendingPathComponent("a/b/c/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("other/file.one").path
    ]))
  }

  func test_match_givenRelativePattern_usingNoPrefix_andSubfolderCurrentDirectory_shouldUseCurrentDirectory() throws {
    // given
    let pattern = ["**/*.one"]

    // when
    try changeCurrentDirectory(to: baseURL.appendingPathComponent("a/").path)

    try create(files: [
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("file.two").path,
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("a/b/file.one").path,
      baseURL.appendingPathComponent("a/b/c/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path
    ])

    // then
    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("a/b/file.one").path,
      baseURL.appendingPathComponent("a/b/c/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path
    ]))
  }

  func test_match_givenRelativePattern_usingSingleDotPrefix_shouldUseCurrentDirectory() throws {
    // given
    let pattern = ["./**/*.one"]

    // when
    try changeCurrentDirectory(to: baseURL.path)

    try create(files: [
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("file.two").path,
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("a/b/file.one").path,
      baseURL.appendingPathComponent("a/b/c/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path
    ])

    // then
    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("a/b/file.one").path,
      baseURL.appendingPathComponent("a/b/c/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("other/file.one").path
    ]))
  }
}
