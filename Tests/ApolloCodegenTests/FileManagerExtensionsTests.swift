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

  func test_doesFileExist_givenFileExistsAndIsDirectory_shouldReturnFalse() {
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

  func test_doesFileExist_givenFileExistsAndIsNotDirectory_shouldReturnTrue() {
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

  func test_doesFileExist_givenFileDoesNotExistAndIsDirectory_shouldReturnFalse() {
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

  func test_doesFileExist_givenFileDoesNotExistAndIsNotDirectory_shouldReturnFalse() {
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

  func test_doesDirectoryExist_givenFilesExistsAndIsDirectory_shouldReturnTrue() {
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

  func test_doesDirectoryExist_givenFileExistsAndIsNotDirectory_shouldReturnFalse() {
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

  func test_doesDirectoryExist_givenFileDoesNotExistAndIsDirectory_shouldReturnFalse() {
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

  func test_doesDirectoryExist_givenFileDoesNotExistAndIsNotDirectory_shouldFalse() {
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

  func test_deleteFile_givenFileExistsAndIsDirectory_shouldThrow() throws {
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

  func test_deleteFile_givenFileExistsAndIsNotDirectory_shouldSucceed() throws {
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

  func test_deleteFile_givenFileExistsAndIsNotDirectoryAndError_shouldThrow() throws {
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

  func test_deleteFile_givenFileDoesNotExistAndIsDirectory_shouldSucceed() throws {
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

  func test_deleteFile_givenFileDoesNotExistAndIsNotDirectory_shouldSucceed() throws {
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

  func test_deleteDirectory_givenFileExistsAndIsDirectory_shouldSucceed() throws {
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

  func test_deleteDirectory_givenFileExistsAndIsDirectoryAndError_shouldThrow() throws {
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

  func test_deleteDirectory_givenFileExistsAndIsNotDirectory_shouldThrow() throws {
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

  func test_deleteDirectory_givenFileDoesNotExistAndIsDirectory_shouldSucceed() throws {
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

  func test_deleteDirectory_givenFileDoesNotExistAndIsNotDirectory_shouldSucceed() throws {
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

  func test_createFile_givenContainingDirectoryDoesExistAndFileCreated_shouldReturnTrue() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true // exists

    }, createFile: { (path: String, data: Data?, attr: FileAttributes?) in
      expect(path).to(match(self.uniquePath))
      expect(data).to(equal(self.uniqueData))
      expect(attr).to(beNil())

      return true

    }, createDirectory: { (path: String, createIntermediates: Bool, attr: FileAttributes?) in
      fail("The containing directory already exists, createDirectory should not be called.")
    })

    // then
    expect(try mocked.apollo.createFile(atPath: self.uniquePath, data:self.uniqueData)).to(beTrue())
    expect(mocked.blocksCalled).to(equal([.fileExists, .createFile]))
  }

  func test_createFile_givenContainingDirectoryDoesExistAndFileNotCreated_shouldReturnFalse() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true // exists

    }, createFile: { (path: String, data: Data?, attr: FileAttributes?) in
      expect(path).to(match(self.uniquePath))
      expect(data).to(equal(self.uniqueData))
      expect(attr).to(beNil())

      return false

    }, createDirectory: { (path: String, createIntermediates: Bool, attr: FileAttributes?) in
      fail("The containing directory already exists, createDirectory should not be called.")
    })

    // then
    expect(try mocked.apollo.createFile(atPath: self.uniquePath, data:self.uniqueData)).to(beFalse())
    expect(mocked.blocksCalled).to(equal([.fileExists, .createFile]))
  }

  func test_createFile_givenContainingDirectoryDoesNotExistAndFileCreated_shouldReturnTrue() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false // exists

    }, createFile: { (path: String, data: Data?, attr: FileAttributes?) in
      expect(path).to(match(self.uniquePath))
      expect(data).to(equal(self.uniqueData))
      expect(attr).to(beNil())

      return true

    }, createDirectory: { (path: String, createIntermediates: Bool, attr: FileAttributes?) in
      expect(path).to(match(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attr).to(beNil())
    })

    // then
    expect(try mocked.apollo.createFile(atPath: self.uniquePath, data:self.uniqueData)).to(beTrue())
    expect(mocked.blocksCalled).to(equal([.fileExists, .createDirectory, .createFile]))
  }

  func test_createFile_givenContainingDirectoryDoesNotExistAndFileNotCreated_shouldReturnFalse() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false // exists

    }, createFile: { (path: String, data: Data?, attr: FileAttributes?) in
      expect(path).to(match(self.uniquePath))
      expect(data).to(equal(self.uniqueData))
      expect(attr).to(beNil())

      return false

    }, createDirectory: { (path: String, createIntermediates: Bool, attr: FileAttributes?) in
      expect(path).to(match(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attr).to(beNil())
    })

    // then
    expect(try mocked.apollo.createFile(atPath: self.uniquePath, data:self.uniqueData)).to(beFalse())
    expect(mocked.blocksCalled).to(equal([.fileExists, .createDirectory, .createFile]))
  }

  func test_createFile_givenContainingDirectoryDoesNotExistAndError_shouldThrow() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false // exists

    }, createFile: { (path: String, data: Data?, attr: FileAttributes?) in
      fail("createFile should not be called, due to error in createDirectory.")
      return false

    }, createDirectory: { (path: String, createIntermediates: Bool, attr: FileAttributes?) in
      expect(path).to(match(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attr).to(beNil())

      throw self.uniqueError
    })

    // then
    expect(try mocked.apollo.createFile(atPath: self.uniquePath, data:self.uniqueData))
      .to(throwError(self.uniqueError))
    expect(mocked.blocksCalled).to(equal([.fileExists, .createDirectory]))
  }

  func test_createContainingDirectory_givenFileExistsAndIsDirectory_shouldReturnEarly() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      let parentPath = URL(fileURLWithPath: path).deletingLastPathComponent().path

      expect(path).to(match(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true // exists

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      fail("The directory already exists, createDirectory should not be called.")
    })

    // then
    expect(try mocked.apollo.createContainingDirectoryIfNeeded(forPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_createContainingDirectory_givenFileExistsAndIsNotDirectory_shouldSucceed() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true // exists

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(match(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())
    })

    // then
    expect(try mocked.apollo.createContainingDirectoryIfNeeded(forPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists, .createDirectory]))
  }

  func test_createContainingDirectory_givenFileDoesNotExistAndIsDirectory_shouldSucceed() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false // exists

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(match(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())
    })

    // then
    expect(try mocked.apollo.createContainingDirectoryIfNeeded(forPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists, .createDirectory]))
  }

  func test_createContainingDirectory_givenFileDoesNotExistAndIsNotDirectory_shouldSucceed() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false // exists

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(match(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())
    })

    // then
    expect(try mocked.apollo.createContainingDirectoryIfNeeded(forPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists, .createDirectory]))
  }

  func test_createContainingDirectory_givenError_shouldThrow() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false // exists

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(match(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())

      throw self.uniqueError
    })

    // then
    expect(try mocked.apollo.createContainingDirectoryIfNeeded(forPath: self.uniquePath))
      .to(throwError(self.uniqueError))
    expect(mocked.blocksCalled).to(equal([.fileExists, .createDirectory]))
  }

  func test_createDirectory_givenFileExistsAndIsDirectory_shouldReturnEarly() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true // exists

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      fail("The directory already exists, createDirectory should not be called.")
    })

    // then
    expect(try mocked.apollo.createDirectoryIfNeeded(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_createDirectory_givenFileExistsAndIsNotDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true // exists

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(match(self.uniquePath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())
    })

    // then
    expect(try mocked.apollo.createDirectoryIfNeeded(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists, .createDirectory]))
  }

  func test_createDirectory_givenFileDoesNotExistAndIsDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false // exists

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(match(self.uniquePath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())
    })

    // then
    expect(try mocked.apollo.createDirectoryIfNeeded(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists, .createDirectory]))
  }

  func test_createDirectory_givenFileDoesNotExistAndIsNotDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false // exists

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(match(self.uniquePath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())
    })

    // then
    expect(try mocked.apollo.createDirectoryIfNeeded(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists, .createDirectory]))
  }

  func test_createDirectory_givenError_shouldThrow() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(match(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false // exists

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(match(self.uniquePath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())

      throw self.uniqueError
    })

    // then
    expect(try mocked.apollo.createDirectoryIfNeeded(atPath: self.uniquePath))
      .to(throwError(self.uniqueError))
    expect(mocked.blocksCalled).to(equal([.fileExists, .createDirectory]))
  }
}
