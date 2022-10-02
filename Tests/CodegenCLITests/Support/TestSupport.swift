import Foundation

class TestSupport {
  static var productsDirectory: URL {
    for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
        return bundle.bundleURL.deletingLastPathComponent()
    }
    fatalError("Couldn't find the products directory!")
  }
}
