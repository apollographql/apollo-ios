import Foundation
import ApolloUtils

// MARK: FileGenerator (protocol and extension)

/// The methods to conform to when building a code generation Swift file generator.
protocol FileGenerator {
  var fileName: String { get }
  var overwrite: Bool { get }
  var template: TemplateRenderer { get }
  var target: FileTarget { get }
}

extension FileGenerator {
  var overwrite: Bool { true }

  /// Generates the file writing the template content to the specified config output paths.
  ///
  /// - Parameters:
  ///   - config: Shared codegen configuration.
  ///   - fileManager: The `ApolloFileManager` object used to create the file. Defaults to `ApolloFileManager.default`.
  func generate(
    forConfig config: ApolloCodegen.ConfigurationContext,
    fileManager: ApolloFileManager = .default
  ) throws {
    let directoryPath = target.resolvePath(forConfig: config)
    let filePath = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent(fileName.firstUppercased).path

    let rendered: String = template.render()

    try fileManager.createFile(
      atPath: filePath,
      data: rendered.data(using: .utf8),
      overwrite: self.overwrite
    )
  }
}

// MARK: - FileTarget (path resolver)

enum FileTarget: Equatable {
  case object
  case `enum`
  case interface
  case union
  case inputObject
  case customScalar
  case fragment(CompilationResult.FragmentDefinition)
  case operation(CompilationResult.OperationDefinition)
  case schema
  case testMock

  private var subpath: String {
    switch self {
    case .object: return "Objects"
    case .enum: return "Enums"
    case .interface: return "Interfaces"
    case .union: return "Unions"
    case .inputObject: return "InputObjects"
    case .customScalar: return "CustomScalars"

    case let .operation(operation) where operation.isLocalCacheMutation:
      return "LocalCacheMutations"
    case let .fragment(fragment) where fragment.isLocalCacheMutation:
      return "LocalCacheMutations"

    case .fragment: return "Fragments"
    case let .operation(operation):
      switch operation.operationType {
      case .query: return "Queries"
      case .mutation: return "Mutations"
      case .subscription: return "Subscriptions"
      }

    case .schema, .testMock: return ""
    }
  }

  func resolvePath(
    forConfig config: ApolloCodegen.ConfigurationContext
  ) -> String {
    switch self {
    case .object, .enum, .interface, .union, .inputObject, .customScalar, .schema:
      return resolveSchemaPath(forConfig: config)

    case let .fragment(fragmentDefinition):
      return resolveFragmentPath(
        forConfig: config,
        fragment: fragmentDefinition
      )

    case let .operation(operationDefinition):
      return resolveOperationPath(
        forConfig: config,
        operation: operationDefinition
      )

    case .testMock:
      return resolveTestMockPath(forConfig: config)
    }
  }

  private func resolveSchemaPath(
    forConfig config: ApolloCodegen.ConfigurationContext
  ) -> String {
    var moduleSubpath: String = "/"
    if config.output.schemaTypes.moduleType == .swiftPackageManager {
      moduleSubpath += "Sources/"
    }
    if config.output.operations.isInModule {
      moduleSubpath += "Schema/"
    }

    return URL(fileURLWithPath: config.output.schemaTypes.path)
      .appendingPathComponent("\(moduleSubpath)\(subpath)").standardizedFileURL.path
  }

  private func resolveFragmentPath(
    forConfig config: ApolloCodegen.ConfigurationContext,
    fragment: CompilationResult.FragmentDefinition
  ) -> String {
    switch config.output.operations {
    case .inSchemaModule:
      var url = URL(fileURLWithPath: config.output.schemaTypes.path)
      if config.output.schemaTypes.moduleType == .swiftPackageManager {
        url = url.appendingPathComponent("Sources")
      }

      return url.appendingPathComponent(subpath).path

    case let .absolute(path):
      return "\(path)/\(subpath)"

    case let .relative(subpath):
      return resolveRelativePath(
        sourceURL: URL(fileURLWithPath: fragment.filePath),
        withSubpath: subpath
      )
    }
  }

  private func resolveRelativePath(sourceURL: URL, withSubpath subpath: String?) -> String {
    let relativeURL = sourceURL.deletingLastPathComponent()

    if let subpath = subpath {
      return relativeURL.appendingPathComponent(subpath).path
    }

    return relativeURL.path
  }

  private func resolveOperationPath(
    forConfig config: ApolloCodegen.ConfigurationContext,
    operation: CompilationResult.OperationDefinition
  ) -> String {
    switch config.output.operations {
    case .inSchemaModule:
      var url = URL(fileURLWithPath: config.output.schemaTypes.path)
      if config.output.schemaTypes.moduleType == .swiftPackageManager {
        url = url.appendingPathComponent("Sources")
      }
      if !operation.isLocalCacheMutation {
        url = url.appendingPathComponent("Operations")
      }

      return url
        .appendingPathComponent(subpath)
        .path

    case let .absolute(path):
      return "\(path)/\(subpath)"

    case let .relative(subpath):
      return resolveRelativePath(
        sourceURL: URL(fileURLWithPath: operation.filePath),
        withSubpath: subpath
      )
    }
  }

  private func resolveTestMockPath(
    forConfig config: ApolloCodegen.ConfigurationContext
  ) -> String {
    switch config.output.testMocks {
    case .none:
      return ""
    case let .swiftPackage(targetName):
      return "\(config.output.schemaTypes.path)/\(targetName ?? "TestMocks")"
    case let .absolute(path):
      return path
    }
  }
}
