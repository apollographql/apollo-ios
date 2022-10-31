import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class GlobTests: XCTestCase {
  var baseURL: URL!
  let fileManager = ApolloFileManager.default

  // MARK: Setup

  override func setUpWithError() throws {
    try super.setUpWithError()

    baseURL = CodegenTestHelper.outputFolderURL().appendingPathComponent("Glob/\(UUID().uuidString)")
    try fileManager.createDirectoryIfNeeded(atPath: baseURL.path)
  }

  override func tearDownWithError() throws {
    try ApolloFileManager.default.deleteDirectory(atPath: baseURL.path)

    try super.tearDownWithError()
  }

  // MARK: Helpers

  private func create(files: [String]) throws {
    for file in files {
      try self.fileManager.createFile(atPath: file)
    }
  }

  private func changeCurrentDirectory(to directory: String) throws {
    try fileManager.createDirectoryIfNeeded(atPath: directory)
    expect(self.fileManager.base.changeCurrentDirectoryPath(directory)).to(beTrue())
  }

  // MARK: Tests

  func test_match_givenSinglePattern_usingAnyWildcard_whenNoMatch_shouldReturnEmpty() throws {
    // given
    let pattern = baseURL.appendingPathComponent("*.xyz").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("file.two").path,
      baseURL.appendingPathComponent("other/file.xyz").path
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
      baseURL.appendingPathComponent("file.two").path,
      baseURL.appendingPathComponent("other/file.one").path
    ])

    // then
    expect(try Glob([pattern]).match()).to(equal([
      baseURL.appendingPathComponent("file.one").path
    ]))
  }

  func test_match_givenSinglePattern_usingAnyWildcard_whenMultipleMatch_shouldReturnMultiple() throws {
    // given
    let pattern = baseURL.appendingPathComponent("file.*").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("file.two").path,
      baseURL.appendingPathComponent("another.one").path,
      baseURL.appendingPathComponent("other/file.one").path
    ])

    // then
    expect(try Glob([pattern]).match()).to(equal([
      baseURL.appendingPathComponent("file.two").path,
      baseURL.appendingPathComponent("file.one").path,
    ]))
  }

  func test_match_givenSinglePattern_usingSingleWildcard_whenSingleMatch_shouldReturnSingle() throws {
    // given
    let pattern = baseURL.appendingPathComponent("fil?.one").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("file.two").path,
      baseURL.appendingPathComponent("filez.one").path,
      baseURL.appendingPathComponent("other/file.one").path
    ])

    // then
    expect(try Glob([pattern]).match()).to(equal([
      baseURL.appendingPathComponent("file.one").path
    ]))
  }

  func test_match_givenSinglePattern_usingSingleWildcard_whenMultipleMatch_shouldReturnMultiple() throws {
    // given
    let pattern = baseURL.appendingPathComponent("other/file.o?e").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path,
      baseURL.appendingPathComponent("other/file.two").path
    ])

    // then
    expect(try Glob([pattern]).match()).to(equal([
      baseURL.appendingPathComponent("other/file.oye").path,
      baseURL.appendingPathComponent("other/file.one").path,
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
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("a/another.file").path,
      baseURL.appendingPathComponent("other/file.ext").path,
      baseURL.appendingPathComponent("other/file.two").path
    ])

    // then
    expect(try Glob(pattern).match()).to(equal([
      baseURL.appendingPathComponent("a/file.one").path
    ]))
  }

  func test_match_givenMultiplePattern_usingAnyWildcard_whenMultipleMatch_shouldReturnMultiple() throws {
    // given
    let pattern = [
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("a/file.*").path,
      baseURL.appendingPathComponent("other/file.*").path
    ]

    // when
    try create(files: [
      baseURL.appendingPathComponent("file.ext").path,
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("a/another.file").path,
      baseURL.appendingPathComponent("a/b/file.one").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path,
      baseURL.appendingPathComponent("other/another.file").path
    ])

    // then
    expect(try Glob(pattern).match()).to(equal([
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path,
      baseURL.appendingPathComponent("other/file.one").path,
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
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("a/file.two").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path
    ])

    // then
    expect(try Glob(pattern).match()).to(equal([
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
      baseURL.appendingPathComponent("a/file.two").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path,
      baseURL.appendingPathComponent("other/file.two").path
    ])

    // then
    expect(try Glob(pattern).match()).to(equal([
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path,
      baseURL.appendingPathComponent("other/file.one").path,
    ]))
  }

  func test_match_givenSinglePattern_usingCombinedWildcard_whenSingleMatch_shouldReturnSingle() throws {
    // given
    let pattern = baseURL.appendingPathComponent("*.o?e").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("file.two").path,
      baseURL.appendingPathComponent("other/file.one").path
    ])

    // then
    expect(try Glob([pattern]).match()).to(equal([
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
      baseURL.appendingPathComponent("another.file").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path,
      baseURL.appendingPathComponent("other/another.file").path
    ])

    // then
    expect(try Glob(pattern).match()).to(equal([
      baseURL.appendingPathComponent("file.two").path,
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("other/file.oye").path,
      baseURL.appendingPathComponent("other/file.one").path,
    ]))
  }

  func test_match_givenGlobstarPattern_usingAnyWildcard_whenSingleMatch_shouldReturnSingle() throws {
    // given
    let pattern = baseURL.appendingPathComponent("a/b/c/d/**/*.one").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path,
      baseURL.appendingPathComponent("a/b/c/file.one").path,
      baseURL.appendingPathComponent("other/file.one").path
    ])

    // then
    expect(try Glob([pattern]).match()).to(equal([
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path
    ]))
  }

  func test_match_givenGlobstarPattern_usingAnyWildcard_whenMultipleMatch_shouldReturnMultiple() throws {
    // given
    let pattern = baseURL.appendingPathComponent("a/b/c/d/**/file.*").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("a/b/c/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path,
      baseURL.appendingPathComponent("other/file.one").path
    ])

    // then
    expect(try Glob([pattern]).match()).to(equal([
      baseURL.appendingPathComponent("a/b/c/d/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
    ]))
  }

  func test_match_givenGlobstarPattern_usingSingleWildcard_whenSingleMatch_shouldReturnSingle() throws {
    // given
    let pattern = baseURL.appendingPathComponent("a/b/c/d/**/?ile.one").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("a/b/c/d/file.two").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path,
      baseURL.appendingPathComponent("other/file.one").path
    ])

    // then
    expect(try Glob([pattern]).match()).to(equal([
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path
    ]))
  }

  func test_match_givenGlobstarPattern_usingCombinedWildcard_whenMultipleMatch_shouldReturnMultiple() throws {
    // given
    let pattern = baseURL.appendingPathComponent("a/b/c/d/**/fil?.*").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("a/b/c/d/file.two").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/another.file").path,
      baseURL.appendingPathComponent("other/file.one").path
    ])

    // then
    expect(try Glob([pattern]).match()).to(equal([
      baseURL.appendingPathComponent("a/b/c/d/file.two").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
    ]))
  }

  func test_match_givenPattern_withExcludeNotFirst_shouldThrow() throws {
    // given
    let pattern = baseURL.appendingPathComponent("a/b/c/d/**/!file.swift").path

    // then
    expect(try Glob([pattern]).match()).to(throwError(Glob.MatchError.invalidExclude(path: pattern)))
  }

  func test_match_givenGlobstarPattern_usingPathExclude_whenMultipleMatch_shouldExclude() throws {
    // given
    let pattern = [
      baseURL.appendingPathComponent("a/b/c/d/**/file.*").path,
      "!" + baseURL.appendingPathComponent("a/b/c/d/**/file.two").path,
    ]

    // when
    try create(files: [
      baseURL.appendingPathComponent("a/b/c/d/file.two").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.ext").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.two").path,
      baseURL.appendingPathComponent("other/file.one").path
    ])

    // then
    expect(try Glob(pattern).match()).to(equal([
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.ext").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
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
    expect(try Glob(pattern).match()).to(equal([
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("a/b/file.one").path,
      baseURL.appendingPathComponent("a/b/c/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
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
    expect(try Glob(pattern).match()).to(equal([
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
    expect(try Glob(pattern).match()).to(equal([
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("a/b/file.one").path,
      baseURL.appendingPathComponent("a/b/c/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
    ]))
  }

  func test_match_givenRelativePattern_usingNoPrefix_andRelativeToRootURL_shouldUseGivenRootURL() throws {
    // given
    let pattern = ["**/*.one"]

    // when
    let rootURL = baseURL.appendingPathComponent("a/", isDirectory: true).standardizedFileURL

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
    expect(try Glob(pattern, relativeTo: rootURL).match()).to(equal([
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("a/b/file.one").path,
      baseURL.appendingPathComponent("a/b/c/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path
    ]))
  }

  func test_match_givenRelativePattern_usingSingleDotPrefix_andRelativeToRootURL_shouldUseGivenRootURL() throws {
    // given
    let pattern = ["./**/*.one"]

    // when
    let rootURL = baseURL.appendingPathComponent("a/", isDirectory: true).standardizedFileURL

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
    expect(try Glob(pattern, relativeTo: rootURL).match()).to(equal([
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("a/b/file.one").path,
      baseURL.appendingPathComponent("a/b/c/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path
    ]))
  }

  func test_match_givenRelativePattern_withNoGlob_andRelativeToRootURL_shouldUsePathRelativeToRootURL() throws {
    // given
    let pattern = ["../file.one"]

    // when
    let rootURL = baseURL.appendingPathComponent("relativeRoot/", isDirectory: true).standardizedFileURL

    try create(files: [
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("relativeRoot/file.one").path,
    ])

    // then
    expect(try Glob(pattern, relativeTo: rootURL).match()).to(equal([
      baseURL.appendingPathComponent("file.one").path,
    ]))
  }

  func test_match_givenAbsolutePattern_withGlob_andRelativeToRootURL_shouldUseAbsolutePathNotRelativeToRootURL() throws {
    // given
    // Absolute pattern beginning with `baseURL` folowed gy globstar
    let pattern = [baseURL.appendingPathComponent("**/*.one").path]

    // when
    let rootURL = baseURL.appendingPathComponent("empty/", isDirectory: true).standardizedFileURL

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
    expect(try Glob(pattern, relativeTo: rootURL).match()).to(equal([
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("other/file.one").path,
      baseURL.appendingPathComponent("a/file.one").path,
      baseURL.appendingPathComponent("a/b/file.one").path,
      baseURL.appendingPathComponent("a/b/c/file.one").path,
      baseURL.appendingPathComponent("a/b/c/d/e/f/file.one").path,
    ]))
  }

  func test_match_givenAbsolutePattern_shouldMatch() throws {
    // given
    let pattern = baseURL.appendingPathComponent("other/file.xyz").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("file.xyz").path,
      baseURL.appendingPathComponent("file.one").path,
      baseURL.appendingPathComponent("other/file.xyz").path,
      baseURL.appendingPathComponent("other/file.two").path
    ])

    // then
    expect(try Glob([pattern]).match()).to(equal([
      baseURL.appendingPathComponent("other/file.xyz").path
    ]))
  }

  func test_match_givenExcludedDirectories_shouldNotMatchExcludedFiles() throws {
    // given
    let pattern = baseURL.appendingPathComponent("**/file.xyz").path

    // when
    try create(files: [
      baseURL.appendingPathComponent("file.xyz").path,
      baseURL.appendingPathComponent("nested/file.xyz").path,
      baseURL.appendingPathComponent("nested/two/file.xyz").path,
      baseURL.appendingPathComponent("DoNotInclude/file.xyz").path,
      baseURL.appendingPathComponent("nested/DoNotInclude/file.xyz").path
    ])

    // then
    expect(try Glob([pattern]).match(excludingDirectories: ["DoNotInclude"])).to(equal([
      baseURL.appendingPathComponent("file.xyz").path,
      baseURL.appendingPathComponent("nested/file.xyz").path,
      baseURL.appendingPathComponent("nested/two/file.xyz").path
    ]))
  }

}
