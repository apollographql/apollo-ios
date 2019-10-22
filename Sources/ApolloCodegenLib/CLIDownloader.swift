//
//  CLIDownloader.swift
//  Apollo
//
//  Created by Ellen Shapiro on 10/22/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import Foundation

/// Helper for downloading the CLI Zip file so we don't have to include it in the repo.
struct CLIDownloader {
  
  enum CLIDownloaderError: Error {
    case badResponse(code: Int, response: String?)
    case emptyDataReceived
    case noDataReceived
    case operationFailed
    case responseNotHTTPResponse
  }
  
  /// The URL string for getting the current version of the CLI
  static let downloadURLString = "https://34622-65563448-gh.circle-artifacts.com/0/oclif-pack/apollo-v2.21.0/apollo-v2.21.0-darwin-x64.tar.gz"
  
  
  /// Downloads the appropriate Apollo CLI in a zip file.
  ///
  /// - Parameter scriptsFolderURL: The scripts folder URL to download it to.
  static func downloadIfNeeded(scriptsFolderURL: URL) throws {
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromScripts: scriptsFolderURL)
    guard !FileManager.default.apollo_fileExists(at: zipFileURL) else {
      CodegenLogger.log("Zip file with the CLI is already downloaded!")
      return
    }
    
    try self.download(to: zipFileURL)
  }
  
  /// Deletes any existing version of the zip file and re-downloads a new version.
  ///
  /// - Parameter scriptsFolderURL: The scripts folder where all this junk lives.
  static func forceRedownload(scriptsFolderURL: URL) throws {
    let zipFileURL = ApolloFilePathHelper.zipFileURL(fromScripts: scriptsFolderURL)
    try FileManager.default.apollo_deleteFile(at: zipFileURL)
    let apolloFolderURL = ApolloFilePathHelper.apolloFolderURL(fromScripts: scriptsFolderURL)
    try FileManager.default.apollo_deleteFolder(at: apolloFolderURL)
    
    try self.download(to: zipFileURL)
  }
  
  /// Downloads the zip file of the Apollo CLI synchronously.
  ///
  /// - Parameter zipFileURL: The URL where downloaded data should be saved.
  private static func download(to zipFileURL: URL) throws {
    CodegenLogger.log("Downloading zip file with the CLI...")
    let semaphore = DispatchSemaphore(value: 0)
    var errorToThrow: Error? = CLIDownloaderError.operationFailed
    URLSession.shared.dataTask(with: URL(string: CLIDownloader.downloadURLString)!) { data, response, error in
      defer {
        semaphore.signal()
      }
      if let error = error {
        errorToThrow = error
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse else {
        errorToThrow = CLIDownloaderError.responseNotHTTPResponse
        return
      }
      
      guard httpResponse.statusCode == 200 else {
        let dataAsString = String(bytes: data ?? Data(), encoding: .utf8)
        errorToThrow = CLIDownloaderError.badResponse(code: httpResponse.statusCode, response: dataAsString)
        return
      }
      
      guard let data = data else {
        errorToThrow = CLIDownloaderError.noDataReceived
        return
      }
      
      guard !data.isEmpty else {
        errorToThrow = CLIDownloaderError.emptyDataReceived
        return
      }
      
      do {
        try data.write(to: zipFileURL)
      } catch {
        errorToThrow = error
        return
      }
      
      // If we got here, it all worked and it's good to go!
      errorToThrow = nil
    }.resume()
    
    _ = semaphore.wait(timeout: .now() + 30)
    
    if let throwMe = errorToThrow {
      throw throwMe
    } else {
      CodegenLogger.log("CLI zip file successfully downloaded!")
    }
  }
}
