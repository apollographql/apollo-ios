import Foundation
#if !COCOAPODS
import ApolloCore
#endif

extension Result: ApolloCompatible {}

extension ApolloExtension where Base: ResultType,   Base.SuccessType: Any {

  /// Converts the result into an optional value. Returns the value for a `success` case and nil for a `failure` case.
  var value: Base.SuccessType?  {
    switch base.underlying {
    case .success(let value):
      return value
    case .failure:
      return nil
    }
  }

  /// Converts the result into an optional error. Returns the error for a `failure` case and nil for a `success` case.
  /// Mostly useful for testing to make sure appropriate errors are received.
  var error: Base.FailureType? {
    switch base.underlying {
    case .success:
      return nil
    case .failure(let error):
      return error
    }
  }
}
