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
      let apolloVersion = try PackageResolveModel(json: packageResolvedJSON).getApolloVersion()
    else {
      return .noApolloVersionFound
    }

    if apolloVersion == Constants.CLIVersion {
      return .versionMatch

    } else {
      return .versionMismatch(cliVersion: Constants.CLIVersion, apolloVersion: apolloVersion)
    }
  }

}

struct PackageResolveModel {
  typealias Object = [String: Any]
  typealias ObjectList = [[String: Any]]

  let fileFormat: FileFormatVersion
  let json: Object

  init(json: Object) throws {
    guard let version = json["version"] as? Int else {
      throw Error(errorDescription: "Invalid 'Package.resolve' file")
    }
    guard let fileFormat = FileFormatVersion(rawValue: version) else {
      throw Error(errorDescription: """
      Package.resolve file version unsupported!
      Please create an issue at: https://github.com/apollographql/apollo-ios
      """)
    }

    self.fileFormat = fileFormat
    self.json = json
  }

  func getApolloVersion() -> String? {
    guard let packageList = fileFormat.getPackageList(fromPackageResolvedJSON: json),
          let apolloPackage = packageList.first(where: {
            let packageName = fileFormat.packageName(forPackage: $0)
            return packageName == "Apollo" || packageName == "apollo-ios"
          })
    else {
      return nil
    }
    return (apolloPackage["state"] as? Object)?["version"] as? String
  }

  enum FileFormatVersion: Int {
    case v1 = 1
    case v2 = 2

    func getPackageList(fromPackageResolvedJSON json: [String: Any]) -> ObjectList? {
      switch self {
      case .v1:
        return (json["object"] as? Object)?["pins"] as? ObjectList

      case .v2:
        return json["pins"] as? ObjectList
      }
    }

    func packageName(forPackage package: Object) -> String? {
      switch self {
      case .v1:
        return package["package"] as? String

      case .v2:
        return package["identity"] as? String
      }
    }
  }

}
