import Foundation
import XCTest
import ApolloCodegenTestSupport
import ApolloCodegenLib
import ApolloUtils
import Nimble

typealias FileAttributes = [FileAttributeKey : Any]

/// A `FileManagerProvider` that can be used to mock the `apollo` extension as  found on `FileManager`.
class MockFileManager: FileManagerProvider {
  typealias fileExistsBlock = ((String, UnsafeMutablePointer<ObjCBool>?) -> Bool)
  typealias removeItemBlock = ((String) throws -> ())
  typealias createFileBlock = ((String, Data?, [FileAttributeKey : Any]?) -> Bool)
  typealias createDirectoryBlock = ((String, Bool, [FileAttributeKey : Any]?) throws -> ())

  enum BlocksCalled {
    case fileExists
    case removeItem
    case createFile
    case createDirectory
  }

  var fileExists: fileExistsBlock?
  var removeItem: removeItemBlock?
  var createFile: createFileBlock?
  var createDirectory: createDirectoryBlock?
  private(set) var blocksCalled: [BlocksCalled] = []

  /// Initialize the instance with one or many of the method stubs to control the return values.
  init(fileExists: fileExistsBlock? = nil,
       removeItem: removeItemBlock? = nil,
       createFile: createFileBlock? = nil,
       createDirectory: createDirectoryBlock? = nil) {
    self.fileExists = fileExists
    self.removeItem = removeItem
    self.createFile = createFile
    self.createDirectory = createDirectory
  }

  func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool {
    guard let block = fileExists else {
      fail("fileExists block must be set before calling this method!")
      return false
    }

    blocksCalled.append(.fileExists)
    return block(path, isDirectory)
  }

  func removeItem(atPath path: String) throws {
    guard let block = removeItem else {
      fail("removeItem block must be set before calling this method!")
      return
    }

    blocksCalled.append(.removeItem)
    try block(path)
  }

  func createFile(atPath path: String, contents data: Data?, attributes attr: FileAttributes?) -> Bool {
    guard let block = createFile else {
      fail("createFile block must be set before calling this method!")
      return false
    }

    blocksCalled.append(.createFile)
    return block(path, data, attr)
  }

  func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: FileAttributes?) throws {
    guard let block = createDirectory else {
      fail("createDirectory block must be set before calling this method!")
      return
    }

    blocksCalled.append(.createDirectory)
    try block(path, createIntermediates, attributes)
  }
}

/// Enables the `.apollo` etension namespace.
extension MockFileManager: ApolloCompatible {}

class FileManagerExtensionTests: XCTestCase {
  lazy var uniquePath: String = {
    CodegenTestHelper.outputFolderURL().appendingPathComponent(UUID().uuidString)
  }().path

  lazy var uniqueError: Error = {
    NSError(domain: "FileManagerExtensionTest", code: Int.random(in: 1...100))
  }()

  lazy var uniqueData: Data = {
    let length = Int(128)
    let bytes = [UInt32](repeating: 0, count: length).map { _ in arc4random() }
    return Data(bytes: bytes, count: length)
  }()

  // MARK: Presence

  func test_doesFileExist_givenExistsTrueAndIsDirectoryFalse_shouldCallFileExistsAndReturnTrue() {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true // exists
    })

    // then
    expect(mocked.apollo.doesFileExist(atPath: self.uniquePath)).to(beTrue())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_doesFileExist_givenExistsTrueAndIsDirectoryTrue_shouldCallFileExistsAndReturnFalse() {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true // exists
    })

    // then
    expect(mocked.apollo.doesFileExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_doesFileExist_givenExistsFalseAndIsDirectoryFalse_shouldCallFileExistsAndReturnFalse() {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false // exists
    })

    // then
    expect(mocked.apollo.doesFileExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_doesFileExist_givenExistsFalseAndIsDirectoryTrue_shouldCallFileExistsAndReturnFalse() {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false // exists
    })

    // then
    expect(mocked.apollo.doesFileExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_doesDirectoryExist_givenExistsTrueAndIsDirectoryTrue_shouldCallFileExistsAndReturnTrue() {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true // exists
    })

    // then
    expect(mocked.apollo.doesDirectoryExist(atPath: self.uniquePath)).to(beTrue())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_doesDirectoryExist_givenExistsTrueAndIsDirectoryFalse_shouldCallFileExistsAndReturnFalse() {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true // exists
    })

    // then
    expect(mocked.apollo.doesDirectoryExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_doesDirectoryExist_givenExistsFalseAndIsDirectoryTrue_shouldCallFileExistsAndReturnFalse() {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false // exists
    })

    // then
    expect(mocked.apollo.doesDirectoryExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_doesDirectoryExist_givenExistsFalseAndIsDirectoryFalse_shouldCallFileExistsAndReturnFalse() {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false // exists
    })

    // then
    expect(mocked.apollo.doesDirectoryExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_deleteFile_givenExistsTrueAndIsDirectoryTrue_shouldCallFileExistsAndThrow() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true // exists
    })

    // then
    expect(try mocked.apollo.deleteFile(atPath: self.uniquePath))
      .to(throwError(MockFileManager.apollo.PathError.notAFile(path: self.uniquePath)))
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_deleteFile_givenExistsTrueAndIsDirectoryFalse_shouldCallFileExistsThenRemoveItemAndNotThrow() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true // exists
    }, removeItem: { (path: String) in
      expect(path).to(match(self.uniquePath))
    })

    // then
    expect(try mocked.apollo.deleteFile(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists, .removeItem]))
  }

  func test_deleteFile_givenExistsFalseAndIsDirectoryTrue_shouldCallFileExistsAndNotThrow() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false // exists
    })

    // then
    expect(try mocked.apollo.deleteFile(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_deleteFile_givenExistsFalseAndIsDirectoryFalse_shouldCallFileExistsAndNotThrow() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false // exists
    })

    // then
    expect(try mocked.apollo.deleteFile(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_deleteFile_givenExistsTrueAndIsDirectoryFalseAndThrowFromRemoveItem_shouldCallFileExistsThenRemoveItemAndThrow() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true // exists
    }, removeItem: { (path: String) in
      expect(path).to(match(self.uniquePath))

      throw self.uniqueError
    })

    // then
    expect(try mocked.apollo.deleteFile(atPath: self.uniquePath)).to(throwError(self.uniqueError))
    expect(mocked.blocksCalled).to(equal([.fileExists, .removeItem]))
  }

  func test_deleteDirectory_givenExistsTrueAndIsDirectoryTrue_shouldCallFileExistsThenRemoveItemAndNotThrow() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true // exists
    }, removeItem: { (path: String) in
      expect(path).to(match(self.uniquePath))
    })

    // then
    expect(try mocked.apollo.deleteDirectory(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists, .removeItem]))
  }

  func test_deleteDirectory_givenExistsTrueAndIsDirectoryFalse_shouldCallFileExistsAndThrow() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true // exists
    }, removeItem: { (path: String) in
      expect(path).to(match(self.uniquePath))
    })

    // then
    expect(try mocked.apollo.deleteDirectory(atPath: self.uniquePath))
      .to(throwError(MockFileManager.apollo.PathError.notADirectory(path: self.uniquePath)))
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_deleteDirectory_givenExistsFalseAndIsDirectoryTrue_shouldCallFileExistsAndNotThrow() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false // exists
    })

    // then
    expect(try mocked.apollo.deleteDirectory(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_deleteDirectory_givenExistsFalseAndIsDirectoryFalse_shouldCallFileExistsAndNotThrow() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false // exists
    })

    // then
    expect(try mocked.apollo.deleteDirectory(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_deleteDirectory_givenExistsTrueAndIsDirectoryTrueAndThrowFromRemoveItem_shouldCallFileExistsThenRemoveItemAndThrow() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true // exists
    }, removeItem: { (path: String) in
      expect(path).to(match(self.uniquePath))

      throw self.uniqueError
    })

    // then
    expect(try mocked.apollo.deleteDirectory(atPath: self.uniquePath)).to(throwError(self.uniqueError))
    expect(mocked.blocksCalled).to(equal([.fileExists, .removeItem]))
  }

  func test_createFile_givenFalseFromCreateFile_shouldCallCreateDirectoryThenCreateFileAndReturnFalse() throws {
    // given
    let mocked = MockFileManager(createFile: { (path: String, data: Data?, attr: FileAttributes?) in
      expect(path).to(match(self.uniquePath))
      expect(data).to(equal(self.uniqueData))
      expect(attr).to(beNil())

      return false
    }, createDirectory: { (path: String, createIntermediates: Bool, attr: FileAttributes?) in
      let parentPath = URL(fileURLWithPath: path).deletingLastPathComponent().path

      expect(path).to(match(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attr).to(beNil())
    })

    // then
    expect(try mocked.apollo.createFile(atPath: self.uniquePath, data:self.uniqueData)).to(beFalse())
    expect(mocked.blocksCalled).to(equal([.createDirectory, .createFile]))
  }

  func test_createFile_givenTrueFromCreateFile_shouldCallCreateDirectoryThenCreateFileAndReturnTrue() throws {
    // given
    let mocked = MockFileManager(createFile: { (path: String, data: Data?, attr: FileAttributes?) in
      expect(path).to(match(self.uniquePath))
      expect(data).to(equal(self.uniqueData))
      expect(attr).to(beNil())

      return true
    }, createDirectory: { (path: String, createIntermediates: Bool, attr: FileAttributes?) in
      let parentPath = URL(fileURLWithPath: path).deletingLastPathComponent().path

      expect(path).to(match(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attr).to(beNil())
    })

    // then
    expect(try mocked.apollo.createFile(atPath: self.uniquePath, data:self.uniqueData)).to(beTrue())
    expect(mocked.blocksCalled).to(equal([.createDirectory, .createFile]))
  }

  func test_createFile_givenTrueFromCreateFileAndThrowFromCreateDirectory_shouldCallCreateDirectoryAndThrow() throws {
    // given
    let mocked = MockFileManager(createFile: { (path: String, data: Data?, attr: FileAttributes?) in
      expect(path).to(match(self.uniquePath))
      expect(data).to(equal(self.uniqueData))
      expect(attr).to(beNil())

      return true
    }, createDirectory: { (path: String, createIntermediates: Bool, attr: FileAttributes?) in
      let parentPath = URL(fileURLWithPath: path).deletingLastPathComponent().path

      expect(path).to(match(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attr).to(beNil())

      throw self.uniqueError
    })

    // then
    expect(try mocked.apollo.createFile(atPath: self.uniquePath, data:self.uniqueData))
      .to(throwError(self.uniqueError))
    expect(mocked.blocksCalled).to(equal([.createDirectory]))
  }

  func test_createContainingDirectory_givenNoThrow_shouldCallCreateDirectoryAndNotThrow() throws {
    // given
    let mocked = MockFileManager(createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      let parentPath = URL(fileURLWithPath: path).deletingLastPathComponent().path

      expect(path).to(match(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())
    })

    // then
    expect(try mocked.apollo.createContainingDirectory(forPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.createDirectory]))
  }

  func test_createContainingDirectory_givenThrow_shouldCallCreateDirectoryAndThrow() throws {
    // given
    let mocked = MockFileManager(createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      let parentPath = URL(fileURLWithPath: path).deletingLastPathComponent().path

      expect(path).to(match(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())

      throw self.uniqueError
    })

    // then
    expect(try mocked.apollo.createContainingDirectory(forPath: self.uniquePath))
      .to(throwError(self.uniqueError))
    expect(mocked.blocksCalled).to(equal([.createDirectory]))
  }

  func test_createDirectory_givenNoThrow_shouldCallCreateDirectoryAndNotThrow() throws {
    // given
    let mocked = MockFileManager(createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(match(self.uniquePath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())
    })

    // then
    expect(try mocked.apollo.createDirectory(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.createDirectory]))
  }

  func test_createDirectory_givenThrow_shouldCallCreateDirectoryAndThrow() throws {
    // given
    let mocked = MockFileManager(createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(match(self.uniquePath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())

      throw self.uniqueError
    })

    // then
    expect(try mocked.apollo.createDirectory(atPath: self.uniquePath)).to(throwError(self.uniqueError))
    expect(mocked.blocksCalled).to(equal([.createDirectory]))
  }
}
