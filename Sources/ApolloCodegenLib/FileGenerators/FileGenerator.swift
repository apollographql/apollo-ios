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
  ///   - fileManager: The `FileManager` object used to create the file. Defaults to `FileManager.default`.
  func generate(
    forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>,
    fileManager: FileManager = FileManager.default
  ) throws {
    let directoryPath = target.resolvePath(forConfig: config)
    let filePath = URL(fileURLWithPath: directoryPath)
      .appendingPathComponent(fileName.firstUppercased).path

    let rendered: String = template.render(forConfig: config)

    try fileManager.apollo.createFile(
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

  private var subpath: String {
    switch self {
    case .object: return "Objects"
    case .enum: return "Enums"
    case .interface: return "Interfaces"
    case .union: return "Unions"
    case .inputObject: return "InputObjects"
    case .customScalar: return "CustomScalars"
    case .fragment, .operation: return "Operations"
    case .schema: return ""
    }
  }

  func resolvePath(
    forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>
  ) -> String {
    switch self {
    case .object, .enum, .interface, .union, .inputObject, .customScalar, .schema:
      return resolveSchemaPath(forConfig: config)

    case let .fragment(fragmentDefinition):
      return resolveOperationPath(
        forConfig: config,
        filePath: NSString(string: fragmentDefinition.filePath).deletingLastPathComponent
      )

    case let .operation(operationDefinition):
      return resolveOperationPath(
        forConfig: config,
        filePath: NSString(string: operationDefinition.filePath).deletingLastPathComponent
      )
    }
  }

  private func resolveSchemaPath(
    forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>
  ) -> String {
    var moduleSubpath: String = ""
    if config.output.operations.isInModule {
      moduleSubpath = "Schema"
    }

    return URL(fileURLWithPath: config.output.schemaTypes.path)
      .appendingPathComponent("\(moduleSubpath)/\(subpath)").standardizedFileURL.path
  }

  private func resolveOperationPath(
    forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>,
    filePath: String
  ) -> String {
    switch config.output.operations {
    case .inSchemaModule:
      return URL(fileURLWithPath: config.output.schemaTypes.path)
        .appendingPathComponent(subpath).path

    case let .absolute(path):
      return path

    case let .relative(subpath):
      let relativeURL = URL(fileURLWithPath: filePath)

      if let subpath = subpath {
        return relativeURL.appendingPathComponent(subpath).path
      }

      return relativeURL.path
    }
  }
}
