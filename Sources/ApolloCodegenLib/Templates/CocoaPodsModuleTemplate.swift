import Foundation

struct CocoaPodsModuleTemplate {
  let name: String
  let version: String
  let license: String
  let homepage: URL
  let source: URL

  func render() -> String {
    TemplateString("""
    Pod::Spec.new do |spec|
      spec.name = '\(name)'
      spec.version = '\(version)'
      spec.authors = 'Apollo Codegen'
      spec.license = '\(license)'
      spec.homepage = '\(homepage.absoluteString)'
      spec.source = { :git => '\(source.absoluteString)', :tag => '\(version)' }
      spec.summary = 'Automatically generated API code that helps you execute all forms of GraphQL operations, as well as parse and cache operation responses.'
      spec.source_files = './**/*.swift'
    end
    """).description
  }
}
