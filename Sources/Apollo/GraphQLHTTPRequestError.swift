/// An error which has occurred during the serialization of a request.
public enum GraphQLHTTPRequestError: Error, LocalizedError {
  case cancelledByDeveloper
  case serializedBodyMessageError
  case serializedQueryParamsMessageError
  
  public var errorDescription: String? {
    switch self {
    case .cancelledByDeveloper:
      return "The request was cancelled by the developer using the HTTPNetworkTransportPreflightDelegate."
    case .serializedBodyMessageError:
      return "JSONSerialization error: Error while serializing request's body"
    case .serializedQueryParamsMessageError:
      return "QueryParams error: Error while serializing variables as query parameters."
    }
  }
}
