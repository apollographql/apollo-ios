import Foundation

extension StaticString {
  var lastPathComponent: String {
    return (description as NSString).lastPathComponent
  }  
}
