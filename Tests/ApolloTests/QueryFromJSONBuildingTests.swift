import XCTest
@testable import Apollo
import ApolloInternalTestHelpers

#warning("TODO: Rewrite tests with Animal Schema")
class QueryFromJSONBuildingTests: XCTestCase {
//  func testHeroDetailsWithFragmentQueryHuman() throws {
//    let jsonObject = [
//        "hero": ["__typename": "Human", "name": "Luke Skywalker", "height": 1.72]
//    ]
//
//    let data = try HeroDetailsWithFragmentQuery.Data(jsonObject: jsonObject)
//
//    let human = try XCTUnwrap(data.hero?.fragments.heroDetails.asHuman,
//                              "Wrong type")
//
//    XCTAssertEqual(human.height, 1.72)
//  }
//
//  func testConditionalInclusionQuery() throws {
//    let jsonObject = [
//      "hero": [
//        "__typename": "Hero",
//        "name": "R2-D2"
//      ]
//    ]
//
//    let nameData = try HeroNameConditionalInclusionQuery.Data(jsonObject: jsonObject, variables: ["includeName" : true])
//    XCTAssertEqual(nameData.hero?.name, "R2-D2")
//
//    let noNameData = try HeroNameConditionalInclusionQuery.Data(jsonObject: jsonObject, variables: ["includeName" : false])
//    XCTAssertNil(noNameData.hero?.name)
//  }
//
//  func testConditionalInclusionQueryWithoutVariables() throws {
//    let jsonObject = [
//      "hero": [
//        "__typename": "Hero",
//        "name": "R2-D2"
//      ]
//    ]
//
//    XCTAssertThrowsError(try HeroNameConditionalInclusionQuery.Data(jsonObject: jsonObject)) { error in
//      if case let error as GraphQLResultError = error {
//        XCTAssertEqual(error.path, ["hero"])
//      } else {
//        XCTFail("Unexpected error: \(error)")
//      }
//    }
//  }
}
