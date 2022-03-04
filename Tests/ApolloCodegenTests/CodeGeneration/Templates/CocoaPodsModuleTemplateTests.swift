import XCTest
import Nimble
@testable import ApolloCodegenLib

class CocoaPodsModuleTemplateTests: XCTestCase {
  let subject = CocoaPodsModuleTemplate(
    name: "PodModule",
    version: "0.1.2",
    license: "Internal",
    homepage: URL(string: "https://www.apollographql.com/")!,
    source: URL(string: "https://github.com/apollographql/apollo-ios.git")!
  )

  // MARK: Boilerplate Tests

  func test__boilerplate__generatesPodSpecInitializerBlock() {
    // given
    let expected = """
    Pod::Spec.new do |spec|
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__boilerplate__generatesPodSpecBlockEnd() {
    // given
    let expected = """
    end
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 10, ignoringExtraLines: true))
  }

  // MARK: Podspec Tests

  func test__podspec__generatesName() {
    // given
    let expected = """
      spec.name = 'PodModule'
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 2, ignoringExtraLines: true))
  }

  func test__podspec__generatesVersion() {
    // given
    let expected = """
      spec.version = '0.1.2'
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 3, ignoringExtraLines: true))
  }

  func test__podspec__generatesAuthors() {
    // given
    let expected = """
      spec.authors = 'Apollo Codegen'
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

  func test__podspec__generatesLicense() {
    // given
    let expected = """
      spec.license = 'Internal'
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 5, ignoringExtraLines: true))
  }

  func test__podspec__generatesHomepage() {
    // given
    let expected = """
      spec.homepage = 'https://www.apollographql.com/'
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__podspec__givenGitTag_generatesSource() {
    // given
    let expected = """
      spec.source = { :git => 'https://github.com/apollographql/apollo-ios.git', :tag => '0.1.2' }
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  #warning("TODO: all supported 'source' keys in the podspec reference - https://guides.cocoapods.org/syntax/podspec.html#source")

  func test__podspec__generatesSummary() {
    // given
    let expected = """
      spec.summary = 'Automatically generated API code that helps you execute all forms of GraphQL operations, as well as parse and cache operation responses.'
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__podspec__generatesSource() {
    // given
    let expected = """
      spec.source_files = './**/*.swift'
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }
}
