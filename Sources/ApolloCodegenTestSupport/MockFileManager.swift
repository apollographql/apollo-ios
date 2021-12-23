import Foundation
import ApolloCodegenLib
import ApolloUtils
import XCTest

/// Used to mock a `FileManager` instance that is compatible with the `.apollo` namespace extension.
public class MockFileManager: FileManager {
  /// Translates to the `FileManager` functions that can be mocked.
  public enum Closure: CustomStringConvertible {
    case fileExists(_ handler: (String, UnsafeMutablePointer<ObjCBool>?) -> Bool)
    case removeItem(_ handler: (String) throws -> Void)
    case createFile(_ handler: (String, Data?, FileAttributes?) -> Bool)
    case createDirectory(_ handler: (String, Bool, FileAttributes?) throws -> Void)

    public var description: String {
      switch self {
      case .fileExists(_): return "fileExists(atPath:isDirectory:)"
      case .removeItem(_): return "removeItem(atPath:)"
      case .createFile(_): return "createFile(atPath:contents:attributes:)"
      case .createDirectory(_): return "createDirectory(atPath:withIntermediateDirectories:attributes:)"
      }
    }
  }

  private var closures: [String: Closure] = [:]
  private var closuresToBeCalled: Set<String> = []

  /// Provide a mock closure for the `FileManager` function.
  ///
  /// - Parameter closure: The mocked function closure.
  public func set(closure: Closure) {
    closures[closure.description] = closure
    closuresToBeCalled.insert(closure.description)
  }

  private func didCall(closure: Closure) {
    closuresToBeCalled.remove(closure.description)
  }


  /// Check whether all mocked closures were called during the lifetime of an instance.
  public var allClosuresCalled: Bool {
    return closuresToBeCalled.isEmpty
  }

  // MARK: FileManager overrides

  private func missingClosureMessage(_ function: String) -> String {
    return "\(function) closure must be set before calling it! Check your MockFileManager instance."
  }

  public override func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool {
    let key = #function

    guard
      let closure = closures[key],
      case let .fileExists(handler) = closure else {
        XCTFail(missingClosureMessage(key))
        return false
      }

    defer {
      didCall(closure: closure)
    }

    return handler(path, isDirectory)
  }

  public override func removeItem(atPath path: String) throws {
    let key = #function

    guard
      let closure = closures[key],
      case let .removeItem(handler) = closure else {
        XCTFail(missingClosureMessage(key))
        return
      }

    defer {
      didCall(closure: closure)
    }

    try handler(path)
  }

  public override func createFile(atPath path: String, contents data: Data?, attributes attr: FileAttributes?) -> Bool {
    let key = #function

    guard
      let closure = closures[key],
      case let .createFile(handler) = closure else {
        XCTFail(missingClosureMessage(key))
        return false
      }

    defer {
      didCall(closure: closure)
    }

    return handler(path, data, attr)
  }

  public override func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: FileAttributes?) throws {
    let key = #function

    guard
      let closure = closures[key],
      case let .createDirectory(handler) = closure else {
        XCTFail(missingClosureMessage(key))
        return
      }

    defer {
      didCall(closure: closure)
    }

    try handler(path, createIntermediates, attributes)
  }
}
