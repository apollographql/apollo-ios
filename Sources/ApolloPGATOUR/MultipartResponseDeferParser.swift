import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

struct MultipartResponseDeferParser: MultipartResponseSpecificationParser {
  static let protocolSpec: String = "deferSpec=20220824"

  static func parse(
    data: Data,
    boundary: String,
    dataHandler: ((Data) -> Void),
    errorHandler: ((Error) -> Void)
  ) {
    // TODO: Will be implemented in #3146
  }
}
