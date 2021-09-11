@testable import ApolloCodegenLib
import ApolloTestSupport
import ApolloCodegenTestSupport
import XCTest

fileprivate class FailingNetworkSession: NetworkSession {
  func loadData(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask? {
    XCTFail("You must call setRequestHandler before using downloader!")

    return nil
  }
}

class URLDownloaderTests: XCTestCase {
  let urlRequest = URLRequest(url: TestURL.mockServer.url)
  let downloadURL = URL(string: "file://anywhere/nowhere/somewhere")!
  let defaultTimeout = 0.5
  var downloader: URLDownloader!
  var session: NetworkSession!

  override func setUp() {
    downloader = URLDownloader(session: FailingNetworkSession())
    session = nil
  }

  override func tearDown() {
    downloader = nil
    session = nil
  }

  private func setRequestHandler(statusCode: Int, data: Data? = nil, error: Error? = nil, abandon: Bool = false) {
    session = MockNetworkSession(statusCode: statusCode, data: data, error: error, abandon: abandon)
    downloader = URLDownloader(session: session)
  }

  func testDownloadError_withCustomError_shouldThrow() throws {
    let statusCode = 400
    let domain = "ApolloCodegenTests"
    let error = NSError(domain: domain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)

    setRequestHandler(statusCode: statusCode, error: error)

    do {
      try downloader.downloadSynchronously(with: urlRequest, to: downloadURL, timeout: defaultTimeout)
    } catch (let error as NSError) {
      XCTAssertEqual(error.domain, domain)
      XCTAssertEqual(error.code, NSURLErrorNotConnectedToInternet)
    }
  }

  func testDownloadError_withBadResponse_shouldThrow() throws {
    let statusCode = 500
    let responseString = "Internal Error"

    setRequestHandler(statusCode: statusCode, data: responseString.data(using: .utf8))

    do {
      try downloader.downloadSynchronously(with: urlRequest, to: downloadURL, timeout: defaultTimeout)
    } catch URLDownloader.DownloadError.badResponse(let code, let response) {
      XCTAssertEqual(code, statusCode)
      XCTAssertEqual(response, responseString)
    } catch {
      XCTFail("Unexpected error received: \(error)")
    }
  }

  func testDownloadError_withEmptyResponseData_shouldThrow() throws {
    setRequestHandler(statusCode: 200, data: Data())

    do {
      try downloader.downloadSynchronously(with: urlRequest, to: downloadURL, timeout: defaultTimeout)
    } catch URLDownloader.DownloadError.emptyDataReceived {
      // Expected response
    } catch {
      XCTFail("Unexpected error received: \(error)")
    }
  }

  func testDownloadError_withNoResponseData_shouldThrow() throws {
    setRequestHandler(statusCode: 200)

    do {
      try downloader.downloadSynchronously(with: urlRequest, to: downloadURL, timeout: defaultTimeout)
    } catch URLDownloader.DownloadError.noDataReceived {
      // Expected response
    } catch {
      XCTFail("Unexpected error received: \(error)")
    }
  }

  func testDownloadError_whenExceedingTimeout_shouldThrow() throws {
    setRequestHandler(statusCode: 200, abandon: true)

    do {
      try downloader.downloadSynchronously(with: urlRequest, to: downloadURL, timeout: defaultTimeout)
    } catch URLDownloader.DownloadError.downloadTimedOut(let timeout) {
      XCTAssertEqual(timeout, defaultTimeout)
    } catch {
      XCTFail("Unexpected error received: \(error)")
    }
  }

  func testDownloadError_withIncorrectResponseType_shouldThrow() throws {
    class CustomNetworkSession: NetworkSession {
      func loadData(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask? {
        completionHandler(nil,  URLResponse(), nil)

        return nil
      }
    }

    let downloader = URLDownloader(session: CustomNetworkSession())

    do {
      try downloader.downloadSynchronously(with: urlRequest, to: downloadURL, timeout: defaultTimeout)
    } catch URLDownloader.DownloadError.responseNotHTTPResponse {
      // Expected response
    } catch {
      XCTFail("Unexpected error received: \(error)")
    }
  }

  func testDownloader_withCorrectResponse_shouldNotThrow() {
    let statusCode = 200
    let responseString = "Success!"
    let downloadURL = CodegenTestHelper.outputFolderURL().appendingPathComponent("urldownloader.txt")

    setRequestHandler(statusCode: statusCode, data: responseString.data(using: .utf8))

    do {
      try downloader.downloadSynchronously(with: urlRequest, to: downloadURL, timeout: defaultTimeout)
    } catch {
      XCTFail("Unexpected error received: \(error)")
    }

    let output = try? String(contentsOf: downloadURL)
    XCTAssertEqual(output, responseString)
  }
}
