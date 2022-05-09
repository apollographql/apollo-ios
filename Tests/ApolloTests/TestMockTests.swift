import XCTest
import Nimble
@testable import Apollo
import ApolloTestSupport
import ApolloAPI
import AnimalKingdomAPI

class TestMockTests: XCTestCase {

  func test__MockDog__() throws {
    let mock = Mock<Dog>()
  }

}

extension Dog: Mockable {
  public typealias MockFields = MockFields_Dog
}

public class MockFields_Dog {
  @Field("birthdate") public var birthdate: AnimalKingdomAPI.CustomDate?
  @Field("bodyTemperature") public var bodyTemperature: Int?
  @Field("favoriteToy") public var favoriteToy: String?
  @Field("height") public var height: Height?
  @Field("humanName") public var humanName: String?
  @Field("id") public var id: ID?
  @Field("laysEggs") public var laysEggs: Bool?
  @Field("owner") public var owner: Human?
  @Field("predators") public var predators: [Animal]?
  @Field("skinCovering") public var skinCovering: GraphQLEnum<SkinCovering>?
  @Field("species") public var species: String?
}
