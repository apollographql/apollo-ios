import Foundation
import ApolloCodegenLib

enum VersionChecker {

  enum VersionCheckResult: Equatable {
    case noApolloVersionFound
    case versionMatch
    case versionMismatch(cliVersion: String, apolloVersion: String)
  }

  static func matchCLIVersionToApolloVersion(projectRootURL: URL?) throws -> VersionCheckResult {
    guard var packageModel = try findPackageResolvedFile(projectRootURL: projectRootURL),
          let apolloVersion = packageModel.apolloVersion else {
      return .noApolloVersionFound
    }
    
    if apolloVersion == Constants.CLIVersion {
      return .versionMatch

    } else {
      return .versionMismatch(cliVersion: Constants.CLIVersion, apolloVersion: apolloVersion)
    }
  }

  private static func findPackageResolvedFile(projectRootURL: URL?) throws -> PackageResolvedModel? {
    let Package_resolved = "Package.resolved"
    let fileManager = ApolloFileManager.default

    // When using SPM with a `Package.swift` file, the `Package.resolved` file will be in the
    // same directory as the `Package.swift`, which is the project's root directory.
    func findInProjectRoot() -> Data? {
      let path: String
      if let projectRootURL {
        path = projectRootURL.appendingPathComponent(Package_resolved, isDirectory: false).path
      } else {
        path = Package_resolved
      }

      return fileManager.base.contents(atPath: path)
    }

    // When using SPM via Xcode, the `Package.resolved` file is nested inside either the
    // `.xcworkspace` or the `.xcproject` package. Since we don't know the name of your project,
    // we just look for the first workspace or project that depends on Apollo, prioritising
    // workspaces. This may not be 100% fool-proof, but it should be accurate in almost all cases.
    func findInXcodeWorkspaces() -> PackageResolvedModel? {
      let projectEnumerator = fileManager.base.enumerator(atPath: projectRootURL?.path ?? ".")
      while let file = projectEnumerator?.nextObject() as? String {
        if file.hasSuffix(".xcworkspace") {
          let projectPackagePath = "\(file)/xcshareddata/swiftpm/\(Package_resolved)"
          if let package = apolloDependantPackage(atPath: projectPackagePath) {
            return package
          }
        }
      }
      return nil
    }
      
    func findInXcodeProjects() -> PackageResolvedModel? {
      let projectEnumerator = fileManager.base.enumerator(atPath: projectRootURL?.path ?? ".")
      while let file = projectEnumerator?.nextObject() as? String {
        if file.hasSuffix(".xcodeproj") {
          let projectPackagePath = "\(file)/project.xcworkspace/xcshareddata/swiftpm/\(Package_resolved)"
          if let package = apolloDependantPackage(atPath: projectPackagePath) {
            return package
          }
        }
      }
      return nil
    }
      
    func apolloDependantPackage(atPath projectPackagePath: String) -> PackageResolvedModel? {
      let path: String
      if let projectRootURL {
        path = projectRootURL.appendingPathComponent(projectPackagePath, isDirectory: false).path
      } else {
        path = projectPackagePath
      }

      if let packageResolvedData = fileManager.base.contents(atPath: path),
         var packageModel = try? PackageResolvedModel(data: packageResolvedData),
             packageModel.apolloVersion != nil {
        return packageModel
      }
      return nil
    }


    if let packageResolvedData = findInProjectRoot() {
      return try PackageResolvedModel(data: packageResolvedData)
    }

    if let packageModel = findInXcodeWorkspaces() {
      return packageModel
    }

    if let packageModel = findInXcodeProjects() {
      return packageModel
    }

    return nil
  }

}

struct PackageResolvedModel {
  typealias Object = [String: Any]
  typealias ObjectList = [[String: Any]]

  let fileFormat: FileFormatVersion
  let json: Object
  lazy var apolloVersion: String? = getApolloVersion()

  init(json: Object) throws {
    guard let version = json["version"] as? Int else {
      throw Error(errorDescription: """
      Invalid 'Package.resolve' file.
      Please create an issue at: https://github.com/apollographql/apollo-ios
      """)
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

  init?(data: Data) throws {
    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      return nil
    }

    try self.init(json: json)
  }

  private func getApolloVersion() -> String? {
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
