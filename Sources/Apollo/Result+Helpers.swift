import Foundation

extension Result {

  /// Converts the result into an optional value. Returns the value for a `success` case and nil for a `failure` case.
  var value: Success?  {
    switch self {
    case .success(let value):
      return value
    case .failure:
      return nil
    }
  }

  /// Converts the result into an optional error. Returns the error for a `failure` case and nil for a `success` case.
  /// Mostly useful for testing to make sure appropriate errors are received.
  var error: Failure? {
    switch self {
    case .success:
      return nil
    case .failure(let error):
      return error
    }
  }
}
