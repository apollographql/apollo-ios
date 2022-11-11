import Foundation
import ApolloCodegenLib

enum VersionChecker {

  enum VersionCheckResult: Equatable {
    case noApolloVersionFound
    case versionMatch
    case versionMismatch(cliVersion: String, apolloVersion: String)
  }

  static func matchCLIVersionToApolloVersion(projectRootURL: URL?) -> VersionCheckResult {
    return .noApolloVersionFound
  }

}
