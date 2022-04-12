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
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true
    }))

    // then
    expect(mocked.apollo.doesFileExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_doesFileExist_givenFileExistsAndIsNotDirectory_shouldReturnTrue() {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true
    }))

    // then
    expect(mocked.apollo.doesFileExist(atPath: self.uniquePath)).to(beTrue())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_doesFileExist_givenFileDoesNotExistAndIsDirectory_shouldReturnFalse() {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false
    }))

    // then
    expect(mocked.apollo.doesFileExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_doesFileExist_givenFileDoesNotExistAndIsNotDirectory_shouldReturnFalse() {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false
    }))

    // then
    expect(mocked.apollo.doesFileExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_doesDirectoryExist_givenFilesExistsAndIsDirectory_shouldReturnTrue() {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true
    }))

    // then
    expect(mocked.apollo.doesDirectoryExist(atPath: self.uniquePath)).to(beTrue())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_doesDirectoryExist_givenFileExistsAndIsNotDirectory_shouldReturnFalse() {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true
    }))

    // then
    expect(mocked.apollo.doesDirectoryExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_doesDirectoryExist_givenFileDoesNotExistAndIsDirectory_shouldReturnFalse() {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false
    }))

    // then
    expect(mocked.apollo.doesDirectoryExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_doesDirectoryExist_givenFileDoesNotExistAndIsNotDirectory_shouldFalse() {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false
    }))

    // then
    expect(mocked.apollo.doesDirectoryExist(atPath: self.uniquePath)).to(beFalse())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  // MARK: Deletion

  func test_deleteFile_givenFileExistsAndIsDirectory_shouldThrow() throws {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true
    }))

    // then
    expect(try mocked.apollo.deleteFile(atPath: self.uniquePath))
      .to(throwError(MockFileManager.apollo.PathError.notAFile(path: self.uniquePath)))
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_deleteFile_givenFileExistsAndIsNotDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true

    }))
    mocked.mock(closure: .removeItem({ path in
      expect(path).to(equal(self.uniquePath))
    }))

    // then
    expect(try mocked.apollo.deleteFile(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_deleteFile_givenFileExistsAndIsNotDirectoryAndError_shouldThrow() throws {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true

    }))
    mocked.mock(closure: .removeItem({ path in
      expect(path).to(equal(self.uniquePath))

      throw self.uniqueError
    }))

    // then
    expect(try mocked.apollo.deleteFile(atPath: self.uniquePath)).to(throwError(self.uniqueError))
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_deleteFile_givenFileDoesNotExistAndIsDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false
    }))

    // then
    expect(try mocked.apollo.deleteFile(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_deleteFile_givenFileDoesNotExistAndIsNotDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false
    }))

    // then
    expect(try mocked.apollo.deleteFile(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_deleteDirectory_givenFileExistsAndIsDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true

    }))
    mocked.mock(closure: .removeItem({ path in
      expect(path).to(equal(self.uniquePath))
    }))

    // then
    expect(try mocked.apollo.deleteDirectory(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_deleteDirectory_givenFileExistsAndIsDirectoryAndError_shouldThrow() throws {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true

    }))
    mocked.mock(closure: .removeItem({ path in
      expect(path).to(equal(self.uniquePath))

      throw self.uniqueError
    }))

    // then
    expect(try mocked.apollo.deleteDirectory(atPath: self.uniquePath)).to(throwError(self.uniqueError))
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_deleteDirectory_givenFileExistsAndIsNotDirectory_shouldThrow() throws {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true

    }))

    // then
    expect(try mocked.apollo.deleteDirectory(atPath: self.uniquePath))
      .to(throwError(MockFileManager.apollo.PathError.notADirectory(path: self.uniquePath)))
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_deleteDirectory_givenFileDoesNotExistAndIsDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false
    }))

    // then
    expect(try mocked.apollo.deleteDirectory(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_deleteDirectory_givenFileDoesNotExistAndIsNotDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false
    }))

    // then
    expect(try mocked.apollo.deleteDirectory(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  // MARK: Creation

  func test_createFile_givenContainingDirectoryDoesExistAndFileCreated_shouldNotThrow() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true

    }))
    mocked.mock(closure: .createFile({ path, data, attr in
      expect(path).to(equal(self.uniquePath))
      expect(data).to(equal(self.uniqueData))
      expect(attr).to(beNil())

      return true

    }))

    // then
    expect(
      try mocked.apollo.createFile(atPath: self.uniquePath, data:self.uniqueData, overwrite: true)
    ).notTo(throwError())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_createFile_givenContainingDirectoryDoesExistAndFileNotCreated_shouldThrow() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true

    }))
    mocked.mock(closure: .createFile({ path, data, attr in
      expect(path).to(equal(self.uniquePath))
      expect(data).to(equal(self.uniqueData))
      expect(attr).to(beNil())

      return false

    }))

    // then
    expect(
      try mocked.apollo.createFile(atPath: self.uniquePath, data:self.uniqueData, overwrite: true
    )).to(throwError(MockFileManager.apollo.PathError.cannotCreateFile(at: self.uniquePath)))
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_createFile_givenContainingDirectoryDoesNotExistAndFileCreated_shouldNotThrow() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false

    }))
    mocked.mock(closure: .createFile({ path, data, attr in
      expect(path).to(equal(self.uniquePath))
      expect(data).to(equal(self.uniqueData))
      expect(attr).to(beNil())

      return true

    }))
    mocked.mock(closure: .createDirectory({ path, createIntermediates, attr in
      expect(path).to(equal(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attr).to(beNil())
    }))

    // then
    expect(
      try mocked.apollo.createFile(atPath: self.uniquePath, data:self.uniqueData, overwrite: true)
    ).notTo(throwError())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_createFile_givenContainingDirectoryDoesNotExistAndFileNotCreated_shouldThrow() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false

    }))
    mocked.mock(closure: .createFile({ path, data, attr in
      expect(path).to(equal(self.uniquePath))
      expect(data).to(equal(self.uniqueData))
      expect(attr).to(beNil())

      return false

    }))
    mocked.mock(closure: .createDirectory({ path, createIntermediates, attr in
      expect(path).to(equal(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attr).to(beNil())
    }))

    // then
    expect(
      try mocked.apollo.createFile(atPath: self.uniquePath, data:self.uniqueData, overwrite: true)
    ).to(throwError(MockFileManager.apollo.PathError.cannotCreateFile(at: self.uniquePath)))
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_createFile_givenContainingDirectoryDoesNotExistAndError_shouldThrow() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false

    }))
    mocked.mock(closure: .createDirectory({ path, createIntermediates, attr in
      expect(path).to(equal(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attr).to(beNil())

      throw self.uniqueError
    }))

    // then
    expect(try mocked.apollo.createFile(
      atPath: self.uniquePath,
      data:self.uniqueData,
      overwrite: true
    )).to(throwError(self.uniqueError))
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_createFile_givenOverwriteFalse_whenFileExists_shouldNotThrow_shouldNotOverwrite() throws {
    // given
    let filePath = URL(fileURLWithPath: self.uniquePath).path
    let directoryPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager(strict: true)

    mocked.mock(closure: .fileExists({ path, isDirectory in
      switch path {
      case directoryPath: isDirectory?.pointee = true
      case filePath: isDirectory?.pointee = false
      default: fail("Unknown path - \(path)")
      }

      return true

    }))
    mocked.mock(closure: .createFile({ path, data, attr in
      fail("Tried to create file when overwrite was false")

      return false
    }))

    // then
    expect(
      try mocked.apollo.createFile(
        atPath: self.uniquePath,
        data:self.uniqueData,
        overwrite: false
      )
    ).notTo(throwError())
  }

  func test_createContainingDirectory_givenFileExistsAndIsDirectory_shouldReturnEarly() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true

    }))

    // then
    expect(try mocked.apollo.createContainingDirectoryIfNeeded(forPath: self.uniquePath)).notTo(throwError())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_createContainingDirectory_givenFileExistsAndIsNotDirectory_shouldSucceed() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true

    }))
    mocked.mock(closure: .createDirectory({ path, createIntermediates, attributes in
      expect(path).to(equal(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())
    }))

    // then
    expect(try mocked.apollo.createContainingDirectoryIfNeeded(forPath: self.uniquePath)).notTo(throwError())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_createContainingDirectory_givenFileDoesNotExistAndIsDirectory_shouldSucceed() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false

    }))
    mocked.mock(closure: .createDirectory({ path, createIntermediates, attributes in
      expect(path).to(equal(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())
    }))

    // then
    expect(try mocked.apollo.createContainingDirectoryIfNeeded(forPath: self.uniquePath)).notTo(throwError())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_createContainingDirectory_givenFileDoesNotExistAndIsNotDirectory_shouldSucceed() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false

    }))
    mocked.mock(closure: .createDirectory({ path, createIntermediates, attributes in
      expect(path).to(equal(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())
    }))

    // then
    expect(try mocked.apollo.createContainingDirectoryIfNeeded(forPath: self.uniquePath)).notTo(throwError())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_createContainingDirectory_givenError_shouldThrow() throws {
    // given
    let parentPath = URL(fileURLWithPath: self.uniquePath).deletingLastPathComponent().path
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(parentPath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false

    }))
    mocked.mock(closure: .createDirectory({ path, createIntermediates, attributes in
      expect(path).to(equal(parentPath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())

      throw self.uniqueError
    }))

    // then
    expect(try mocked.apollo.createContainingDirectoryIfNeeded(forPath: self.uniquePath))
      .to(throwError(self.uniqueError))
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_createDirectory_givenFileExistsAndIsDirectory_shouldReturnEarly() throws {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return true

    }))

    // then
    expect(try mocked.apollo.createDirectoryIfNeeded(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_createDirectory_givenFileExistsAndIsNotDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return true

    }))
    mocked.mock(closure: .createDirectory({ path, createIntermediates, attributes in
      expect(path).to(equal(self.uniquePath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())
    }))

    // then
    expect(try mocked.apollo.createDirectoryIfNeeded(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_createDirectory_givenFileDoesNotExistAndIsDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = true
      return false

    }))
    mocked.mock(closure: .createDirectory({ path, createIntermediates, attributes in
      expect(path).to(equal(self.uniquePath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())
    }))

    // then
    expect(try mocked.apollo.createDirectoryIfNeeded(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_createDirectory_givenFileDoesNotExistAndIsNotDirectory_shouldSucceed() throws {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false

    }))
    mocked.mock(closure: .createDirectory({ path, createIntermediates, attributes in
      expect(path).to(equal(self.uniquePath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())
    }))

    // then
    expect(try mocked.apollo.createDirectoryIfNeeded(atPath: self.uniquePath)).notTo(throwError())
    expect(mocked.allClosuresCalled).to(beTrue())
  }

  func test_createDirectory_givenError_shouldThrow() throws {
    // given
    let mocked = MockFileManager()

    mocked.mock(closure: .fileExists({ path, isDirectory in
      expect(path).to(equal(self.uniquePath))
      expect(isDirectory).notTo(beNil())

      isDirectory?.pointee = false
      return false

    }))
    mocked.mock(closure: .createDirectory({ path, createIntermediates, attributes in
      expect(path).to(equal(self.uniquePath))
      expect(createIntermediates).to(beTrue())
      expect(attributes).to(beNil())

      throw self.uniqueError
    }))

    // then
    expect(try mocked.apollo.createDirectoryIfNeeded(atPath: self.uniquePath))
      .to(throwError(self.uniqueError))
    expect(mocked.allClosuresCalled).to(beTrue())
  }
}
