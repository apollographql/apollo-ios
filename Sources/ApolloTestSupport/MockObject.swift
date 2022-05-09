import ApolloAPI

public class Mock<O: Object> {
  public var data: JSONObject

  public init() {
    data = ["__typename": O.__typename.description]
  }

}

public protocol Mockable {
  associatedtype MockFields
}
