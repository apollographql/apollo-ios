import Foundation
import ApolloCodegenLib
import ApolloUtils
import XCTest

/// A `FileManagerProvider` that can be used to mock the `apollo` extension as  found on `FileManager`.
public class MockFileManager: FileManagerProvider {
  public typealias fileExistsBlock = ((String, UnsafeMutablePointer<ObjCBool>?) -> Bool)
  public typealias removeItemBlock = ((String) throws -> ())
  public typealias createFileBlock = ((String, Data?, FileAttributes?) -> Bool)
  public typealias createDirectoryBlock = ((String, Bool, FileAttributes?) throws -> ())

  public enum BlocksCalled {
    case fileExists
    case removeItem
    case createFile
    case createDirectory
  }

  public var fileExists: fileExistsBlock?
  public var removeItem: removeItemBlock?
  public var createFile: createFileBlock?
  public var createDirectory: createDirectoryBlock?
  private(set) public var blocksCalled: [BlocksCalled] = []

  /// Initialize the instance with one or many of the method stubs to control the return values.
  public init(fileExists: fileExistsBlock? = nil,
              removeItem: removeItemBlock? = nil,
              createFile: createFileBlock? = nil,
              createDirectory: createDirectoryBlock? = nil) {
    self.fileExists = fileExists
    self.removeItem = removeItem
    self.createFile = createFile
    self.createDirectory = createDirectory
  }

  public func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool {
    guard let block = fileExists else {
      XCTFail("fileExists block must be set before calling this method!")
      return false
    }

    blocksCalled.append(.fileExists)
    return block(path, isDirectory)
  }

  public func removeItem(atPath path: String) throws {
    guard let block = removeItem else {
      XCTFail("removeItem block must be set before calling this method!")
      return
    }

    blocksCalled.append(.removeItem)
    try block(path)
  }

  public func createFile(atPath path: String, contents data: Data?, attributes attr: FileAttributes?) -> Bool {
    guard let block = createFile else {
      XCTFail("createFile block must be set before calling this method!")
      return false
    }

    blocksCalled.append(.createFile)
    return block(path, data, attr)
  }

  public func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: FileAttributes?) throws {
    guard let block = createDirectory else {
      XCTFail("createDirectory block must be set before calling this method!")
      return
    }

    blocksCalled.append(.createDirectory)
    try block(path, createIntermediates, attributes)
  }
}

/// Enables the `.apollo` etension namespace.
extension MockFileManager: ApolloCompatible {}
