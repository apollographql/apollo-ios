import Foundation
import ArgumentParser
import ApolloCodegenLib

extension ParsableCommand {
  func rootOutputURL(for inputOptions: InputOptions) -> URL? {
    if inputOptions.string != nil { return nil }
    let rootURL = URL(fileURLWithPath: inputOptions.path).deletingLastPathComponent()
    if rootURL.path == FileManager.default.currentDirectoryPath { return nil }
    return rootURL
  }
}
