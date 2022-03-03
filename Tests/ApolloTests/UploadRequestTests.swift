import XCTest
@testable import Apollo
import ApolloTestSupport
import UploadAPI
import StarWarsAPI

class UploadRequestTests: XCTestCase {

  var client: ApolloClient!

  override func setUp() {
    super.setUp()

    client = {
      let store = ApolloStore()
      let provider = DefaultInterceptorProvider(store: store)
      let transport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                   endpointURL: URL(string: "http://www.test.com")!,
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
