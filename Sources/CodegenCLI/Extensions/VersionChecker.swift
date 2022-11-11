import Foundation
import ApolloCodegenLib

enum VersionChecker {

  enum VersionCheckResult: Equatable {
    case noApolloVersionFound
    case versionMatch
    case versionMismatch(cliVersion: String, apolloVersion: String)
  }

  static func matchCLIVersionToApolloVersion(projectRootURL: URL?) throws -> VersionCheckResult {
    let fileManager = ApolloFileManager.default

    guard
      let packageResolvedData = fileManager.base.contents(
        atPath: projectRootURL!.appendingPathComponent("Package.resolved", isDirectory: false).path
      ),
      let packageResolvedJSON = try JSONSerialization.jsonObject(
        with: packageResolvedData
      ) as? [String: Any],
      let apolloVersion = getApolloVersion(fromPackageResolvedJSON: packageResolvedJSON)
    else {
      return .noApolloVersionFound
    }

    if apolloVersion == Constants.CLIVersion {
      return .versionMatch

    } else {
      return .versionMismatch(cliVersion: Constants.CLIVersion, apolloVersion: apolloVersion)
    }
  }

  private static func getApolloVersion(fromPackageResolvedJSON json: [String: Any]) -> String? {
    typealias Object = [String: Any]
    typealias ObjectList = [[String: Any]]

    let packageList = (json["object"] as? Object)?["pins"] as? ObjectList ?? json["pins"] as? ObjectList

    guard
      let apolloPackage = packageList?.first(where: {
        $0["package"] as? String == "Apollo"
      }),
      let apolloVersion = (apolloPackage["state"] as? Object)?["version"] as? String
    else {
      return nil
    }

    return apolloVersion
  }

  enum PackageResolveFileFormat {
    case v1
    case v2

    func getApolloVersion(fromPackageResolvedJSON json: [String: Any]) -> String? {
      switch self {
      case .v1:
        let packageList = (json["object"] as? Object)?["pins"] as? ObjectList

        guard
          let apolloPackage = packageList?.first(where: {
            guard let packageName = $0["package"] as? String else { return false }
            packageName == "Apollo" || packageName == "apollo"
          }),
          let apolloVersion = (apolloPackage["state"] as? Object)?["version"] as? String
        else {
          return nil
        }

        return apolloVersion

      case .v2:
        let packageList = (json["object"] as? Object)?["pins"] as? ObjectList

        guard
          let apolloPackage = packageList?.first(where: {
            $0["package"] as? String == "Apollo"
          }),
          let apolloVersion = (apolloPackage["state"] as? Object)?["version"] as? String
        else {
          return nil
        }

        return apolloVersion
      }
    }
  }

}

struct PackageResolveFile
