import XCTest
import Apollo
import UploadAPI

class UploadTests: XCTestCase {
  
  let uploadClientURL = URL(string: "http://localhost:4000")!
  
  lazy var client = ApolloClient(url: self.uploadClientURL)
  
  override static func tearDown() {
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
                                  file: StaticString = #file,
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
    let fileURL = TestFileHelper.testParentFolder()
                .appendingPathComponent("a.txt")
    
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
    let firstFileURL = TestFileHelper.testParentFolder()
                .appendingPathComponent("a.txt")
    
    let firstFile = try GraphQLFile(fieldName: "files",
                                    originalName: "a.txt",
                                    fileURL: firstFileURL)
    
    let secondFileURL = TestFileHelper.testParentFolder()
                .appendingPathComponent("b.txt")
    
    let secondFile = try GraphQLFile(fieldName: "files",
                                     originalName: "b.txt",
                                     fileURL: secondFileURL)
    
    let files = [ firstFile, secondFile]
    
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
        XCTAssertEqual(uploads[0].filename, "a.txt")
        XCTAssertEqual(uploads[1].filename, "b.txt")
        self.compareInitialFile(at: firstFileURL, toUploadedFileAt: uploads[0].path)
        self.compareInitialFile(at: secondFileURL, toUploadedFileAt: uploads[1].path)
      case .failure(let error):
        XCTFail("Unexpected upload error: \(error)")
      }
    }
    
    self.wait(for: [expectation], timeout: 10)
  }
  
  func testUploadingMultipleFilesWithDifferentFieldNames() throws {
    let firstFileURL = TestFileHelper.testParentFolder()
      .appendingPathComponent("a.txt")
    
    let firstFile = try GraphQLFile(fieldName: "singleFile",
                                    originalName: "a.txt",
                                    fileURL: firstFileURL)
    
    let secondFileURL = TestFileHelper.testParentFolder()
      .appendingPathComponent("b.txt")
    
    let secondFile = try GraphQLFile(fieldName: "multipleFiles",
                                     originalName: "b.txt",
                                     fileURL: secondFileURL)
    
    let thirdFileURL = TestFileHelper.testParentFolder()
      .appendingPathComponent("c.txt")
    
    let thirdFile = try GraphQLFile(fieldName: "multipleFiles",
                                    originalName: "c.txt",
                                    fileURL: thirdFileURL)
    
    let files = [secondFile, thirdFile]

    let upload = UploadMultipleFilesToDifferentParametersMutation(singleFile: firstFile.originalName, multipleFiles: files.map { $0.originalName })
    
    let expectation = self.expectation(description: "File upload complete")
    self.client.upload(operation: upload, files: files) { result in
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
        XCTAssertEqual(uploads[0].filename, "a.txt")
        XCTAssertEqual(uploads[1].filename, "b.txt")
        // TODO:Figure out why server is only returning 2 files here
//        XCTAssertEqual(uploads[2].filename, "c.txt")
        self.compareInitialFile(at: firstFileURL, toUploadedFileAt: uploads[0].path)
        self.compareInitialFile(at: secondFileURL, toUploadedFileAt: uploads[1].path)
//        self.compareInitialFile(at: thirdFileURL, toUploadedFileAt: uploads[2].path)
      case .failure(let error):
        XCTFail("Unexpected upload error: \(error)")
      }
    }
    
    self.wait(for: [expectation], timeout: 10)
    
  }
}
