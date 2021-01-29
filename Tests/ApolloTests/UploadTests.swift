import XCTest
@testable import Apollo
import ApolloTestSupport
import UploadAPI
import StarWarsAPI

class UploadTests: XCTestCase {
  
  let uploadClientURL = TestURL.uploadServer.url
  
  lazy var client: ApolloClient = {
    let store = ApolloStore()
    let provider = LegacyInterceptorProvider(store: store)
    let transport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                 endpointURL: self.uploadClientURL,
                                                 additionalHeaders: ["headerKey": "headerValue"])
    transport.clientName = "test"
    transport.clientVersion = "test"
    
    return ApolloClient(networkTransport: transport, store: store)
  }()
  
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
  
  // MARK: - UploadRequest

  
  func testSingleFileWithUploadRequest() throws {
    let alphaFileUrl = TestFileHelper.fileURLForFile(named: "a", extension: "txt")
    
    let alphaFile = try GraphQLFile(fieldName: "file",
                                    originalName: "a.txt",
                                    mimeType: "text/plain",
                                    fileURL: alphaFileUrl)
    let operation = UploadOneFileMutation(file: alphaFile.originalName)
    
    let transport = try XCTUnwrap(self.client.networkTransport as? RequestChainNetworkTransport)
    
    let httpRequest = transport.constructUploadRequest(for: operation,
                                                       with: [alphaFile],
                                                       manualBoundary: "TEST.BOUNDARY")
    let uploadRequest = try XCTUnwrap(httpRequest as? UploadRequest)
    
    let urlRequest = try uploadRequest.toURLRequest()
    XCTAssertEqual(urlRequest.allHTTPHeaderFields?["headerKey"], "headerValue")
    
    let formData = try uploadRequest.requestMultipartFormData()
    let stringToCompare = try formData.toTestString()
    
    let expectedString = """
--TEST.BOUNDARY
Content-Disposition: form-data; name="operations"

{"id":"c5d5919f77d9ba16a9689b6b0ad4b781cb05dc1dc4812623bf80f7c044c09533","operationName":"UploadOneFile","query":"mutation UploadOneFile($file: Upload!) {\\n  singleUpload(file: $file) {\\n    __typename\\n    id\\n    path\\n    filename\\n    mimetype\\n  }\\n}","variables":{"file":null}}
--TEST.BOUNDARY
Content-Disposition: form-data; name="map"

{"0":["variables.file"]}
--TEST.BOUNDARY
Content-Disposition: form-data; name="0"; filename="a.txt"
Content-Type: text/plain

Alpha file content.

--TEST.BOUNDARY--
"""
    
    XCTAssertEqual(stringToCompare, expectedString)
  }

  func testMultipleFilesWithUploadRequest() throws {
    let alphaFileURL = TestFileHelper.fileURLForFile(named: "a", extension: "txt")
    let alphaFile = try GraphQLFile(fieldName: "files",
                                    originalName: "a.txt",
                                    mimeType: "text/plain",
                                    fileURL: alphaFileURL)
    
    let betaFileURL = TestFileHelper.fileURLForFile(named: "b", extension: "txt")
    let betaFile = try GraphQLFile(fieldName: "files",
                                   originalName: "b.txt",
                                   mimeType: "text/plain",
                                   fileURL: betaFileURL)
    
    let files = [alphaFile, betaFile]
    let operation = UploadMultipleFilesToTheSameParameterMutation(files: files.map { $0.originalName })
    let transport = try XCTUnwrap(self.client.networkTransport as? RequestChainNetworkTransport)
    
    let httpRequest = transport.constructUploadRequest(for: operation,
                                                       with: [alphaFile, betaFile],
                                                       manualBoundary: "TEST.BOUNDARY")
    let uploadRequest = try XCTUnwrap(httpRequest as? UploadRequest)
    
    let urlRequest = try uploadRequest.toURLRequest()
    XCTAssertEqual(urlRequest.allHTTPHeaderFields?["headerKey"], "headerValue")
    
    let multipartData = try uploadRequest.requestMultipartFormData()
    let stringToCompare = try multipartData.toTestString()
    
    let expectedString = """
--TEST.BOUNDARY
Content-Disposition: form-data; name="operations"

{"id":"88858c283bb72f18c0049dc85b140e72a4046f469fa16a8bf4bcf01c11d8a2b7","operationName":"UploadMultipleFilesToTheSameParameter","query":"mutation UploadMultipleFilesToTheSameParameter($files: [Upload!]!) {\\n  multipleUpload(files: $files) {\\n    __typename\\n    id\\n    path\\n    filename\\n    mimetype\\n  }\\n}","variables":{"files":[null,null]}}
--TEST.BOUNDARY
Content-Disposition: form-data; name="map"

{"0":["variables.files.0"],"1":["variables.files.1"]}
--TEST.BOUNDARY
Content-Disposition: form-data; name="0"; filename="a.txt"
Content-Type: text/plain

Alpha file content.

--TEST.BOUNDARY
Content-Disposition: form-data; name="1"; filename="b.txt"
Content-Type: text/plain

Bravo file content.

--TEST.BOUNDARY--
"""
    XCTAssertEqual(stringToCompare, expectedString)
  }

  func testMultipleFilesWithMultipleFieldsWithUploadRequest() throws {
    let alphaFileURL = TestFileHelper.fileURLForFile(named: "a", extension: "txt")
    let alphaFile = try GraphQLFile(fieldName: "uploads",
                                    originalName: "a.txt",
                                    mimeType: "text/plain",
                                    fileURL: alphaFileURL)
    
    let betaFileURL = TestFileHelper.fileURLForFile(named: "b", extension: "txt")
    let betaFile = try GraphQLFile(fieldName: "uploads",
                                   originalName: "b.txt",
                                   mimeType: "text/plain",
                                   fileURL: betaFileURL)
    
    let charlieFileUrl = TestFileHelper.fileURLForFile(named: "c", extension: "txt")
    let charlieFile = try GraphQLFile(fieldName: "secondField",
                                      originalName: "c.txt",
                                      mimeType: "text/plain",
                                      fileURL: charlieFileUrl)
    
    let transport = try XCTUnwrap(self.client.networkTransport as? RequestChainNetworkTransport)
    
    let httpRequest = transport.constructUploadRequest(for: HeroNameQuery(),
                                                       with: [alphaFile, betaFile, charlieFile],
                                                       manualBoundary: "TEST.BOUNDARY")
    let uploadRequest = try XCTUnwrap(httpRequest as? UploadRequest)
    
    let urlRequest = try uploadRequest.toURLRequest()
    XCTAssertEqual(urlRequest.allHTTPHeaderFields?["headerKey"], "headerValue")
    
    let multipartData = try uploadRequest.requestMultipartFormData()
    let stringToCompare = try multipartData.toTestString()
    
    let expectedString = """
--TEST.BOUNDARY
Content-Disposition: form-data; name="operations"

{"id":"f6e76545cd03aa21368d9969cb39447f6e836a16717823281803778e7805d671","operationName":"HeroName","query":"query HeroName($episode: Episode) {\\n  hero(episode: $episode) {\\n    __typename\\n    name\\n  }\\n}","variables":{"episode":null,\"secondField\":null,\"uploads\":null}}
--TEST.BOUNDARY
Content-Disposition: form-data; name="map"

{"0":["variables.secondField"],"1":["variables.uploads.0"],"2":["variables.uploads.1"]}
--TEST.BOUNDARY
Content-Disposition: form-data; name="0"; filename="c.txt"
Content-Type: text/plain

Charlie file content.

--TEST.BOUNDARY
Content-Disposition: form-data; name="1"; filename="a.txt"
Content-Type: text/plain

Alpha file content.

--TEST.BOUNDARY
Content-Disposition: form-data; name="2"; filename="b.txt"
Content-Type: text/plain

Bravo file content.

--TEST.BOUNDARY--
"""
    XCTAssertEqual(stringToCompare, expectedString)
  }
}
