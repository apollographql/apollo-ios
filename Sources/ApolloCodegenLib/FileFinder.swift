import Foundation

public struct FileFinder {
    
  #if compiler(>=5.3)
    public static func findParentFolder(from filePath: StaticString = #filePath) -> URL {
      self.findParentFolder(from: filePath.apollo.toString)
    }
  #else
    public static func findParentFolder(from filePath: StaticString = #file) -> URL {
      self.findParentFolder(from: filePath.apollo.toString)
    }
  #endif
    
    public static func findParentFolder(from filePath: String) -> URL {
        let url = URL(fileURLWithPath: filePath)
        return url.deletingLastPathComponent()
    }
}
