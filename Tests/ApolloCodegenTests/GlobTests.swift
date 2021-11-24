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

    expect(
      // <outputFolder>/Glob/file.one
      try fileManager.createFile(atPath: self.baseURL.appendingPathComponent("file.one").path)
    ).to(beTrue())

    expect(
      // <outputFolder>/Glob/file.two
      try fileManager.createFile(atPath: self.baseURL.appendingPathComponent("file.two").path)
    ).to(beTrue())

    expect(
      // <outputFolder>/Glob/a/file.one
      try fileManager.createFile(atPath: self.baseURL.appendingPathComponent("a/file.one").path)
    ).to(beTrue())

    expect(
      // <outputFolder>/Glob/a/b/file.one
      try fileManager.createFile(atPath: self.baseURL.appendingPathComponent("a/b/file.one").path)
    ).to(beTrue())

    expect(
      // <outputFolder>/Glob/a/b/c/file.one
      try fileManager.createFile(atPath: self.baseURL.appendingPathComponent("a/b/c/file.one").path)
    ).to(beTrue())

    expect(
      // <outputFolder>/Glob/a/b/c/d/e/f/file.one
      try fileManager.createFile(atPath: self.baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path)
    ).to(beTrue())

    expect(
      // <outputFolder>/Glob/a/b/c/d/e/f/file.two
      try fileManager.createFile(atPath: self.baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path)
    ).to(beTrue())

    expect(
      // <outputFolder>/Glob/other/file.one
      try fileManager.createFile(atPath: self.baseURL.appendingPathComponent("other/file.one").path)
    ).to(beTrue())

    expect(
      // <outputFolder>/Glob/other/file.oye
      try fileManager.createFile(atPath: self.baseURL.appendingPathComponent("other/file.oye").path)
    ).to(beTrue())
  }

  override func tearDownWithError() throws {
    try FileManager.default.apollo.deleteDirectory(atPath: baseURL.path)
  }

  // MARK: Tests

  func test_paths_givenNoMatch_whenMultipleFiles_shouldReturnEmpty() throws {
    // given
    let pattern = baseURL.appendingPathComponent("*.xyz").path

    // when
    // <outputFolder>/Glob/file.one
    // <outputFolder>/Glob/file.two

    // then
    expect(Glob(pattern).match).to(beEmpty())
  }

  func test_paths_givenSingleMatch_whenMultipleFiles_shouldReturnSingle() throws {
    // given
    let pattern = baseURL.appendingPathComponent("*.one").path

    // when
    // <outputFolder>/Glob/file.one
    // <outputFolder>/Glob/file.two

    // then
    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("file.one").path
    ]))
  }

  func test_paths_givenMultipleMatches_whenMultipleFiles_shouldReturnMultiple() throws {
    // given
    let pattern = baseURL.appendingPathComponent("file.*").path

    // when
    // <outputFolder>/Glob/file.one
    // <outputFolder>/Glob/file.two

    // then
    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("file.two").path
    ]))
  }

  func test_paths_givenMultipleMatchBraces_whenSingleFile_shouldReturnSingle() throws {
    // given
    let pattern = baseURL.appendingPathComponent("a/{*.one,*.two}").path

    // when
    // <outputFolder>/Glob/a/file.one

    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("a/file.one").path
    ]))
  }

  func test_paths_givenMultipleMatchBraces_whenMultipleFiles_shouldReturnMultiple() throws {
    // given
    let pattern = baseURL.appendingPathComponent("{*.one,*.two}").path

    // when
    // <outputFolder>/Glob/file.one
    // <outputFolder>/Glob/file.two

    // then
    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("file.two").path
    ]))
  }

  func test_paths_givenMultipleMatchBraces_withNegation_whenMultipleFiles_shouldReturnSingle() throws {
    // given
    let pattern = baseURL.appendingPathComponent("{*.one,!*.two}").path

    // when
    // <outputFolder>/Glob/file.one
    // <outputFolder>/Glob/file.two

    // then
    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("file.one").path
    ]))
  }

  func test_paths_givenMultipleMatches_withWildcardCharacter_whenMultipleFiles_shouldReturnMultiple() throws {
    // given
    let pattern = baseURL.appendingPathComponent("other/file.o?e").path

    // when
    // <outputFolder>/Glob/other/file.one
    // <outputFolder>/Glob/other/file.oye

    // then
    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path
    ]))
  }

  func test_paths_givenDuplicateMatches_whenMatches_shouldNotReturnDuplicates() throws {
    // given
    let pattern = baseURL.appendingPathComponent("a/{*.one,*.one}").path

    // when
    // <outputFolder>/Glob/a/file.one

    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("a/file.one").path
    ]))
  }

  func test_expandGlobstar_givenRootGlobstar_shouldExpandAllDirectoriesWithPattern() throws {
    // given
    let pattern = baseURL.appendingPathComponent("**/*.one").path

    // when
    // <outputFolder>/Glob/file.one
    // <outputFolder>/Glob/file.two
    // <outputFolder>/Glob/a/file.one
    // <outputFolder>/Glob/a/b/file.one
    // <outputFolder>/Glob/a/b/c/file.one
    // <outputFolder>/Glob/a/b/c/d/e/f/file.one
    // <outputFolder>/Glob/a/b/c/d/e/f/file.two
    // <outputFolder>/Glob/other/file.one
    // <outputFolder>/Glob/other/file.oye

    // then
    expect(Glob(pattern).expandGlobstar).to(equal([
      baseURL.path.appending("/*.one"),
      baseURL.appendingPathComponent("a/*.one").path,
      baseURL.appendingPathComponent("a/b/*.one").path,
      baseURL.appendingPathComponent("a/b/c/*.one").path,
      baseURL.appendingPathComponent("a/b/c/d/*.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/*.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/*.one").path,
      baseURL.appendingPathComponent("other/*.one").path
    ]))
  }

  func test_expandGlobstar_givenPathGlobstar_shouldExpandSubdirectoriesWithPattern() {
    // given
    let pattern = baseURL.appendingPathComponent("a/**/*.one").path

    // when
    // <outputFolder>/Glob/file.one
    // <outputFolder>/Glob/file.two
    // <outputFolder>/Glob/a/file.one
    // <outputFolder>/Glob/a/b/file.one
    // <outputFolder>/Glob/a/b/c/file.one
    // <outputFolder>/Glob/a/b/c/d/e/f/file.one
    // <outputFolder>/Glob/a/b/c/d/e/f/file.two
    // <outputFolder>/Glob/other/file.one
    // <outputFolder>/Glob/other/file.oye

    // then
    expect(Glob(pattern).expandGlobstar).to(equal([
      baseURL.appendingPathComponent("a/*.one").path,
      baseURL.appendingPathComponent("a/b/*.one").path,
      baseURL.appendingPathComponent("a/b/c/*.one").path,
      baseURL.appendingPathComponent("a/b/c/d/*.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/*.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/*.one").path
    ]))
  }

  func test_paths_givenRootGlobstar_whenSubdirectoryMatches_shouldReturnAllMatches() throws {
    // given
    let pattern = baseURL.appendingPathComponent("**/*.two").path

    // when
    // <outputFolder>/Glob/file.one
    // <outputFolder>/Glob/file.two
    // <outputFolder>/Glob/a/file.one
    // <outputFolder>/Glob/a/b/file.one
    // <outputFolder>/Glob/a/b/c/file.one
    // <outputFolder>/Glob/a/b/c/d/e/f/file.one
    // <outputFolder>/Glob/a/b/c/d/e/f/file.two
    // <outputFolder>/Glob/other/file.one
    // <outputFolder>/Glob/other/file.oye

    // then
    expect(Glob(pattern).match).to(equal([
      baseURL.appendingPathComponent("file.two").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path
    ]))
  }

  #warning("TODO - memory leak test")
}
