import Foundation

/// Provides the format to identify a file as automatically generated.
struct HeaderCommentTemplate {
  static let template: StaticString =
    """
    // @generated
    // This file was automatically generated and should not be edited.
    """
}
