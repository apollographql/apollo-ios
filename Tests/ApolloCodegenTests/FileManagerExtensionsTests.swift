import Foundation
import XCTest
import ApolloCodegenTestSupport
import ApolloCodegenLib
import ApolloUtils
import Nimble

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
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true
    })

    // then
    expect(mocked.apollo.doesFileExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_doesFileExist_givenFileExistsAndIsNotDirectory_shouldReturnTrue() {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true
    })

    // then
    expect(mocked.apollo.doesFileExist(atPath: self.uniquePath)).to(beTrue())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_doesFileExist_givenFileDoesNotExistAndIsDirectory_shouldReturnFalse() {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false
    })

    // then
    expect(mocked.apollo.doesFileExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_doesFileExist_givenFileDoesNotExistAndIsNotDirectory_shouldReturnFalse() {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false
    })

    // then
    expect(mocked.apollo.doesFileExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_doesDirectoryExist_givenFilesExistsAndIsDirectory_shouldReturnTrue() {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true
    })

    // then
    expect(mocked.apollo.doesDirectoryExist(atPath: self.uniquePath)).to(beTrue())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_doesDirectoryExist_givenFileExistsAndIsNotDirectory_shouldReturnFalse() {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true
    })

    // then
    expect(mocked.apollo.doesDirectoryExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_doesDirectoryExist_givenFileDoesNotExistAndIsDirectory_shouldReturnFalse() {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false
    })

    // then
    expect(mocked.apollo.doesDirectoryExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_doesDirectoryExist_givenFileDoesNotExistAndIsNotDirectory_shouldFalse() {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false
    })

    // then
    expect(mocked.apollo.doesDirectoryExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_deleteFile_givenFileExistsAndIsDirectory_shouldThrow() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true
    })

    // then
    expect(try mocked.apollo.deleteFile(atPath: self.uniquePath))
      .to(throwError(MockFileManager.apollo.PathError.notAFile(path: self.uniquePath)))
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_deleteFile_givenFileExistsAndIsNotDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true

    }, removeItem: { (path: String) in
      expect(path).to(equal(self.uniquePath))
    })

    // then
    expect(try mocked.apollo.deleteFile(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists, .removeItem]))
  }

  func test_deleteFile_givenFileExistsAndIsNotDirectoryAndError_shouldThrow() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true

    }, removeItem: { (path: String) in
      expect(path).to(equal(self.uniquePath))

      throw self.uniqueError
    })

    // then
    expect(try mocked.apollo.deleteFile(atPath: self.uniquePath)).to(throwError(self.uniqueError))
    expect(mocked.blocksCalled).to(equal([.fileExists, .removeItem]))
  }

  func test_deleteFile_givenFileDoesNotExistAndIsDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false
    })

    // then
    expect(try mocked.apollo.deleteFile(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_deleteFile_givenFileDoesNotExistAndIsNotDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false
    })

    // then
    expect(try mocked.apollo.deleteFile(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_deleteDirectory_givenFileExistsAndIsDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true

    }, removeItem: { (path: String) in
      expect(path).to(equal(self.uniquePath))
    })

    // then
    expect(try mocked.apollo.deleteDirectory(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists, .removeItem]))
  }

  func test_deleteDirectory_givenFileExistsAndIsDirectoryAndError_shouldThrow() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true

    }, removeItem: { (path: String) in
      expect(path).to(equal(self.uniquePath))

      throw self.uniqueError
    })

    // then
    expect(try mocked.apollo.deleteDirectory(atPath: self.uniquePath)).to(throwError(self.uniqueError))
    expect(mocked.blocksCalled).to(equal([.fileExists, .removeItem]))
  }

  func test_deleteDirectory_givenFileExistsAndIsNotDirectory_shouldThrow() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true

    }, removeItem: { (path: String) in
      expect(path).to(equal(self.uniquePath))
    })

    // then
    expect(try mocked.apollo.deleteDirectory(atPath: self.uniquePath))
      .to(throwError(MockFileManager.apollo.PathError.notADirectory(path: self.uniquePath)))
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_deleteDirectory_givenFileDoesNotExistAndIsDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false
    })

    // then
    expect(try mocked.apollo.deleteDirectory(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_deleteDirectory_givenFileDoesNotExistAndIsNotDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false
    })

    // then
    expect(try mocked.apollo.deleteDirectory(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists]))
  }

  func test_createFile_givenContainingDirectoryDoesExistAndFileCreated_shouldNotThrow() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true

    }, createFile: { (path: String, data: Data?, attr: FileAttributes?) in
      expect(path).to(equal(self.uniquePath))
      expect(data).to(equal(self.uniqueData))
      expect(attr).to(beNil())

      return true

    }, createDirectory: { (path: String, createIntermediates: Bool, attr: FileAttributes?) in
      fail("The containing directory already exists, createDirectory should not be called.")
    })

    // then
    expect(
      try mocked.apollo.createFile(atPath: self.uniquePath, data:self.uniqueData)
    ).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists, .createFile]))
  }

  func test_createFile_givenContainingDirectoryDoesExistAndFileNotCreated_shouldThrow() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true

    }, createFile: { (path: String, data: Data?, attr: FileAttributes?) in
      expect(path).to(equal(self.uniquePath))
      expect(data).to(equal(self.uniqueData))
      expect(attr).to(beNil())

      return false

    }, createDirectory: { (path: String, createIntermediates: Bool, attr: FileAttributes?) in
      fail("The containing directory already exists, createDirectory should not be called.")
    })

    // then
    expect(
      try mocked.apollo.createFile(atPath: self.uniquePath, data:self.uniqueData)
    ).to(throwError(MockFileManager.apollo.PathError.cannotCreateFile(at: self.uniquePath)))
    expect(mocked.blocksCalled).to(equal([.fileExists, .createFile]))
  }

  func test_createFile_givenContainingDirectoryDoesNotExistAndFileCreated_shouldNotThrow() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false

    }, createFile: { (path: String, data: Data?, attr: FileAttributes?) in
      expect(path).to(equal(self.uniquePath))
      expect(data).to(equal(self.uniqueData))
      expect(attr).to(beNil())

      return true

    }, createDirectory: { (path: String, createIntermediates: Bool, attr: FileAttributes?) in
      expect(path).to(equal(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attr).to(beNil())
    })

    // then
    expect(
      try mocked.apollo.createFile(atPath: self.uniquePath, data:self.uniqueData)
    ).notTo(throwError())
    expect(mocked.blocksCalled).to(equal([.fileExists, .createDirectory, .createFile]))
  }

  func test_createFile_givenContainingDirectoryDoesNotExistAndFileNotCreated_shouldThrow() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false

    }, createFile: { (path: String, data: Data?, attr: FileAttributes?) in
      expect(path).to(equal(self.uniquePath))
      expect(data).to(equal(self.uniqueData))
      expect(attr).to(beNil())

      return false

    }, createDirectory: { (path: String, createIntermediates: Bool, attr: FileAttributes?) in
      expect(path).to(equal(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attr).to(beNil())
    })

    // then
    expect(
      try mocked.apollo.createFile(atPath: self.uniquePath, data:self.uniqueData)
    ).to(throwError(MockFileManager.apollo.PathError.cannotCreateFile(at: self.uniquePath)))
    expect(mocked.blocksCalled).to(equal([.fileExists, .createDirectory, .createFile]))
  }

  func test_createFile_givenContainingDirectoryDoesNotExistAndError_shouldThrow() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false

    }, createFile: { (path: String, data: Data?, attr: FileAttributes?) in
      fail("createFile should not be called, due to error in createDirectory.")
      return false

    }, createDirectory: { (path: String, createIntermediates: Bool, attr: FileAttributes?) in
      expect(path).to(equal(parentPath))
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
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager(fileExists: { (path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) in
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true

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
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(equal(parentPath))
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
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(equal(parentPath))
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
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(equal(parentPath))
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
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(equal(parentPath))
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
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true

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
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(equal(self.uniquePath))
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
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(equal(self.uniquePath))
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
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(equal(self.uniquePath))
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
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false

    }, createDirectory: { (path: String, createIntermediates: Bool, attributes: FileAttributes?) in
      expect(path).to(equal(self.uniquePath))
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
