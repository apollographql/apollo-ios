import Foundation

public struct FileFinder {
    
    public static func findParentFolder(from filePath: StaticString = #file) -> URL {
      findParentFolder(from: filePath.apollo.toString)
    }
    
    public static func findParentFolder(from filePath: String) -> URL {
        let url = URL(fileURLWithPath: filePath)
        return url.deletingLastPathComponent()
    }
}
