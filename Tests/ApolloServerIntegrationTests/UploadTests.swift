import XCTest
@testable import Apollo
import ApolloInternalTestHelpers
import UploadAPI
import StarWarsAPI

class UploadTests: XCTestCase {

  static let uploadClientURL = TestServerURL.uploadServer.url

  var client: ApolloClient!

  override func setUp() {
    super.setUp()

    client = {
      let store = ApolloStore()
      let provider = DefaultInterceptorProvider(store: store)
      let transport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                   endpointURL: Self.uploadClientURL,
                                                   additionalHeaders: ["headerKey": "headerValue"])
      transport.clientName = "test"
      transport.clientVersion = "test"

      return ApolloClient(networkTransport: transport, store: store)
    }()
  }

  override func tearDown() {
    client = nil
    
    super.tearDown()
  }

  override class func tearDown() {
    // Recreate the uploads folder at the end of all tests in this suite to avoid having one billion files in there
    recreateUploadsFolder()
    super.tearDown()
  }

  private static func recreateUploadsFolder() {
    let uploadsFolderURL = TestFileHelper.uploadsFolder()
    try? FileManager.default.removeItem(at: uploadsFolderURL)

    try? FileManager.default.createDirectory(at: uploadsFolderURL, withIntermediateDirectories: false)
  }

  private func compareInitialFile(at initialFileURL: URL,
                                  toUploadedFileAt path: String?,
                                  file: StaticString = #filePath,
                                  line: UInt = #line) {
    guard let path = path else {
      XCTFail("Path was nil!",
              file: file,
              line: line)
      return
    }

    let sanitizedPath = String(path.dropFirst(2)) // Gets rid of the ./ returned by the server

    let uploadedFileURL = TestFileHelper.uploadServerFolder()
      .appendingPathComponent(sanitizedPath)

    do {
      let initialData = try Data(contentsOf: initialFileURL)
      let uploadedData = try Data(contentsOf: uploadedFileURL)
      XCTAssertFalse(initialData.isEmpty,
                     "Initial data was empty at \(initialFileURL)",
                     file: file,
                     line: line)
      XCTAssertFalse(uploadedData.isEmpty,
                     "Uploaded data was empty at \(uploadedFileURL)",
                     file: file,
                     line: line)
      XCTAssertEqual(initialData,
                     uploadedData,
                     "Initial data at \(initialFileURL) was not equal to data uploaded at \(uploadedFileURL)",
                     file: file,
                     line: line)
    } catch {
      XCTFail("Unexpected error loading data to compare: \(error)",
              file: file,
              line: line)
    }
  }

  func testUploadingASingleFile() throws {
    let fileURL = TestFileHelper.fileURLForFile(named: "a", extension: "txt")

    let file = try GraphQLFile(fieldName: "file",
                               originalName: "a.txt",
                               fileURL: fileURL)

    let upload = UploadOneFileMutation(file: "a.txt")

    let expectation = self.expectation(description: "File upload complete")
    self.client.upload(operation: upload, files: [file]) { result in
      defer {
        expectation.fulfill()
      }

      switch result {
      case .success(let graphQLResult):
        XCTAssertEqual(graphQLResult.data?.singleUpload.filename, "a.txt")
        self.compareInitialFile(at: fileURL, toUploadedFileAt: graphQLResult.data?.singleUpload.path)
      case .failure(let error):
        XCTFail("Unexpected upload error: \(error)")
      }
    }

    self.wait(for: [expectation], timeout: 10)
  }

  func testUploadingMultipleFilesWithTheSameFieldName() throws {
    let firstFileURL = TestFileHelper.fileURLForFile(named: "a", extension: "txt")

    let firstFile = try GraphQLFile(fieldName: "files",
                                    originalName: "a.txt",
                                    fileURL: firstFileURL)

    let secondFileURL = TestFileHelper.fileURLForFile(named: "b", extension: "txt")

    let secondFile = try GraphQLFile(fieldName: "files",
                                     originalName: "b.txt",
                                     fileURL: secondFileURL)

    let files = [firstFile, secondFile]

    let upload = UploadMultipleFilesToTheSameParameterMutation(files: files.map { $0.originalName })

    let expectation = self.expectation(description: "File upload complete")
    self.client.upload(operation: upload, files: files) { result in
      defer {
        expectation.fulfill()
      }

      switch result {
      case .success(let graphQLResult):
        guard let uploads = graphQLResult.data?.multipleUpload else {
          XCTFail("NOPE")
          return
        }

        XCTAssertEqual(uploads.count, 2)
        let sortedUploads = uploads.sorted { $0.filename < $1.filename }
        XCTAssertEqual(sortedUploads[0].filename, "a.txt")
        XCTAssertEqual(sortedUploads[1].filename, "b.txt")
        self.compareInitialFile(at: firstFileURL, toUploadedFileAt: sortedUploads[0].path)
        self.compareInitialFile(at: secondFileURL, toUploadedFileAt: sortedUploads[1].path)
      case .failure(let error):
        XCTFail("Unexpected upload error: \(error)")
      }
    }

    self.wait(for: [expectation], timeout: 10)
  }

  func testUploadingMultipleFilesWithDifferentFieldNames() throws {
    let firstFileURL = TestFileHelper.fileURLForFile(named: "a", extension: "txt")

    let firstFile = try GraphQLFile(fieldName: "singleFile",
                                    originalName: "a.txt",
                                    fileURL: firstFileURL)

    let secondFileURL = TestFileHelper.fileURLForFile(named: "b", extension: "txt")

    let secondFile = try GraphQLFile(fieldName: "multipleFiles",
                                     originalName: "b.txt",
                                     fileURL: secondFileURL)

    let thirdFileURL = TestFileHelper.fileURLForFile(named: "c", extension: "txt")

    let thirdFile = try GraphQLFile(fieldName: "multipleFiles",
                                    originalName: "c.txt",
                                    fileURL: thirdFileURL)

    // This is the array of Files for the `multipleFiles` parameter only
    let multipleFiles = [secondFile, thirdFile]

    let upload = UploadMultipleFilesToDifferentParametersMutation(singleFile: firstFile.originalName, multipleFiles: multipleFiles.map { $0.originalName })

    let expectation = self.expectation(description: "File upload complete")

    // This is the array of Files for all parameters
    let allFiles = [firstFile, secondFile, thirdFile]
    self.client.upload(operation: upload, files: allFiles) { result in
      defer {
        expectation.fulfill()
      }

      switch result {
      case .success(let graphQLResult):
        guard let uploads = graphQLResult.data?.multipleParameterUpload else {
          XCTFail("NOPE")
          return
        }

        XCTAssertEqual(uploads.count, 3)
        let sortedUploads = uploads.sorted { $0.filename < $1.filename }
        XCTAssertEqual(sortedUploads[0].filename, "a.txt")
        XCTAssertEqual(sortedUploads[1].filename, "b.txt")
        XCTAssertEqual(sortedUploads[2].filename, "c.txt")
        self.compareInitialFile(at: firstFileURL, toUploadedFileAt: sortedUploads[0].path)
        self.compareInitialFile(at: secondFileURL, toUploadedFileAt: sortedUploads[1].path)
        self.compareInitialFile(at: thirdFileURL, toUploadedFileAt: sortedUploads [2].path)
      case .failure(let error):
        XCTFail("Unexpected upload error: \(error)")
      }
    }

    self.wait(for: [expectation], timeout: 10)
  }

  func testUploadingASingleFileInAnArray() throws {
    let fileURL = TestFileHelper.fileURLForFile(named: "a", extension: "txt")

    let file = try GraphQLFile(fieldName: "files",
                                    originalName: "a.txt",
                                    fileURL: fileURL)

    let filesArray = [file]

    let uploadMutation = UploadMultipleFilesToTheSameParameterMutation(files: filesArray.map { $0.originalName })

    let expectation = self.expectation(description: "File upload complete")
    self.client.upload(operation: uploadMutation, files: filesArray) { result in
      defer {
        expectation.fulfill()
      }

      switch result {
      case .success(let graphQLResult):
        guard let uploads = graphQLResult.data?.multipleUpload else {
          XCTFail("NOPE")
          return
        }

        XCTAssertEqual(uploads.count, 1)
        guard let uploadedFile = uploads.first else {
          XCTFail("Could not access uploaded file!")
          return
        }

        XCTAssertEqual(uploadedFile.filename, "a.txt")
        self.compareInitialFile(at: fileURL, toUploadedFileAt: uploadedFile.path)
      case .failure(let error):
        XCTFail("Unexpected upload error: \(error)")
      }
    }

    self.wait(for: [expectation], timeout: 10)
  }

  func testUploadingSingleFileInAnArrayWithAnotherFileForAnotherField() throws {
    let firstFileURL = TestFileHelper.fileURLForFile(named: "a", extension: "txt")

    let firstFile = try GraphQLFile(fieldName: "singleFile",
                                    originalName: "a.txt",
                                    fileURL: firstFileURL)

    let secondFileURL = TestFileHelper.fileURLForFile(named: "b", extension: "txt")

    let secondFile = try GraphQLFile(fieldName: "multipleFiles",
                                     originalName: "b.txt",
                                     fileURL: secondFileURL)

    // This is the array of Files for the `multipleFiles` parameter only
    let multipleFiles = [secondFile]

    let upload = UploadMultipleFilesToDifferentParametersMutation(singleFile: firstFile.originalName, multipleFiles: multipleFiles.map { $0.originalName })

    let expectation = self.expectation(description: "File upload complete")

    // This is the array of Files for all parameters
    let allFiles = [firstFile, secondFile]
    self.client.upload(operation: upload, files: allFiles) { result in
      defer {
        expectation.fulfill()
      }

      switch result {
      case .success(let graphQLResult):
        guard let uploads = graphQLResult.data?.multipleParameterUpload else {
          XCTFail("NOPE")
          return
        }

        XCTAssertEqual(uploads.count, 2)
        let sortedUploads = uploads.sorted { $0.filename < $1.filename }
        XCTAssertEqual(sortedUploads[0].filename, "a.txt")
        XCTAssertEqual(sortedUploads[1].filename, "b.txt")
        self.compareInitialFile(at: firstFileURL, toUploadedFileAt: sortedUploads[0].path)
        self.compareInitialFile(at: secondFileURL, toUploadedFileAt: sortedUploads[1].path)
      case .failure(let error):
        XCTFail("Unexpected upload error: \(error)")
      }
    }

    self.wait(for: [expectation], timeout: 10)
  }

}
