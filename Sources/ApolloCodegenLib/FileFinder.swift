import Foundation

public struct FileFinder {
  
  #if compiler(>=5.3)
  /// Version that works if you're using the 5.3 compiler or above
  /// - Parameter filePath: The full file path of the file to find. Defaults to the `#filePath` of the caller.
  /// - Returns: The file URL for the parent folder.
  public static func findParentFolder(from filePath: StaticString = #filePath) -> URL {
    self.findParentFolder(from: filePath.description)
  }
  
  /// The URL of a file at a given path
  /// - Parameter filePath: The full file path of the file to find
  /// - Returns: The file's URL
  public static func fileURL(from filePath: StaticString = #filePath) -> URL {
    URL(fileURLWithPath: filePath.description)
  }
  #else
  /// Version that works if you're using the 5.2 compiler or below
  /// - Parameter file: The full file path of the file to find. Defaults to the `#file` of the caller.
  /// - Returns: The file URL for the parent folder.
  public static func findParentFolder(from filePath: StaticString = #file) -> URL {
    self.findParentFolder(from: filePath.description)
  }
  
  /// The URL of a file at a given path
  /// - Parameter filePath: The full file path of the file to find
  /// - Returns: The file's URL
  public static func fileURL(from filePath: StaticString = #file) -> URL {
    URL(fileURLWithPath: filePath.toString)
  }
  #endif
  
  /// Finds the parent folder from a given file path.
  /// - Parameter filePath: The full file path, as a string
  /// - Returns: The file URL for the parent folder.
  public static func findParentFolder(from filePath: String) -> URL {
    let url = URL(fileURLWithPath: filePath)
    return url.deletingLastPathComponent()
  }
}
