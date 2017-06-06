import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class FragmentConstructionAndConversionTests: XCTestCase {
  // MARK: - Manually constructing fragments
  
  func testConstructDroidNameFragment() throws {
    let r2d2 = DroidName(name: "R2-D2")
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
  }
  
  func testConstructCharacterNameFragmentForDroid() throws {
    let r2d2 = CharacterName.makeDroid(name: "R2-D2")
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
  }
  
  func testConstructCharacterAppearsInFragmentForDroid() throws {
    let r2d2 = CharacterAppearsIn.makeDroid(appearsIn: [.newhope, .empire, .jedi])
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.appearsIn, [.newhope, .empire, .jedi])
  }
  
  func testConstructCharacterNameAndDroidAppearsInFragmentForDroid() throws {
    let r2d2 = CharacterNameAndDroidAppearsIn.makeDroid(name: "R2-D2", appearsIn: [.newhope, .empire, .jedi])
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    XCTAssertEqual(r2d2.asDroid?.appearsIn, [.newhope, .empire, .jedi])
  }
  
  func testConstructCharacterNameAndDroidAppearsInFragmentForHuman() throws {
    let luke = CharacterNameAndDroidAppearsIn.makeHuman(name: "Luke Skywalker")
    
    XCTAssertEqual(luke.__typename, "Human")
    XCTAssertEqual(luke.name, "Luke Skywalker")
    XCTAssertNil(luke.asDroid)
  }
  
  func testConstructCharacterNameAndDroidPrimaryFunctionFragmentForDroid() throws {
    let r2d2 = CharacterNameAndDroidPrimaryFunction.makeDroid(name: "R2-D2", primaryFunction: "Protocol")
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    XCTAssertEqual(r2d2.asDroid?.primaryFunction, "Protocol")
    XCTAssertEqual(r2d2.fragments.characterName.name, "R2-D2")
    XCTAssertEqual(r2d2.fragments.droidPrimaryFunction?.primaryFunction, "Protocol")
  }
  
  func testConstructCharacterNameAndDroidPrimaryFunctionFragmentForHuman() throws {
    let luke = CharacterNameAndDroidPrimaryFunction.makeHuman(name: "Luke Skywalker")
    
    XCTAssertEqual(luke.__typename, "Human")
    XCTAssertEqual(luke.name, "Luke Skywalker")
    XCTAssertNil(luke.asDroid)
    XCTAssertEqual(luke.fragments.characterName.name, "Luke Skywalker")
    XCTAssertNil(luke.fragments.droidPrimaryFunction)
  }
  
  func testConstructDroidNameAndPrimaryFunctionFragment() throws {
    let r2d2 = DroidNameAndPrimaryFunction(name: "R2-D2", primaryFunction: "Protocol")
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    XCTAssertEqual(r2d2.primaryFunction, "Protocol")
  }
  
  func testConstructHeroDetailsFragmentWithDroidSpecificProperty() throws {
    let r2d2 = HeroDetails.makeDroid(name: "R2-D2", primaryFunction: "Protocol")
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    XCTAssertEqual(r2d2.asDroid?.primaryFunction, "Protocol")
    XCTAssertNil(r2d2.asHuman)
  }
  
  func testConstructHeroDetailsFragmentWithMissingDroidSpecificProperty() throws {
    let r2d2 = HeroDetails.makeDroid(name: "R2-D2")
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    XCTAssertNil(r2d2.asDroid?.primaryFunction)
    XCTAssertNil(r2d2.asHuman)
  }
  
  func testConstructHeroDetailsFragmentWithNullDroidSpecificProperty() throws {
    let r2d2 = HeroDetails.makeDroid(name: "R2-D2", primaryFunction: nil)
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    XCTAssertNil(r2d2.asDroid?.primaryFunction)
    XCTAssertNil(r2d2.asHuman)
  }
  
  func testConstructHeroDetailsFragmentWithHumanSpecificProperty() throws {
    let luke = HeroDetails.makeHuman(name: "Luke Skywalker", height: 1.72)
    
    XCTAssertEqual(luke.__typename, "Human")
    XCTAssertEqual(luke.name, "Luke Skywalker")
    XCTAssertEqual(luke.asHuman?.height, 1.72)
    XCTAssertNil(luke.asDroid)
  }
  
  func testConstructHeroDetailsFragmentWithMissingHumanSpecificProperty() throws {
    let luke = HeroDetails.makeHuman(name: "Luke Skywalker")
    
    XCTAssertEqual(luke.__typename, "Human")
    XCTAssertEqual(luke.name, "Luke Skywalker")
    XCTAssertNil(luke.asHuman?.height)
    XCTAssertNil(luke.asDroid)
  }
  
  func testConstructHeroDetailsFragmentWithNullHumanSpecificProperty() throws {
    let luke = HeroDetails.makeHuman(name: "Luke Skywalker", height: nil)
    
    XCTAssertEqual(luke.__typename, "Human")
    XCTAssertEqual(luke.name, "Luke Skywalker")
    XCTAssertNil(luke.asHuman?.height)
    XCTAssertNil(luke.asDroid)
  }
  
  func testConstructHumanHeightWithVariableFragment() throws {
    let luke = HumanHeightWithVariable(height: 1.72)
    
    XCTAssertEqual(luke.__typename, "Human")
    XCTAssertEqual(luke.height, 1.72)
  }
  
  // MARK: - Converting fragments into JSON objects
  
  func testJSONObjectFromCharacterNameFragment() throws {
    let r2d2 = CharacterName.makeDroid(name: "R2-D2")
    
    XCTAssertEqual(r2d2.jsonObject, ["__typename": "Droid", "name": "R2-D2"])
  }
  
  func testJSONObjectFromCharacterAppearsInFragment() throws {
    let r2d2 = CharacterAppearsIn.makeDroid(appearsIn: [.newhope, .empire, .jedi])
    
    XCTAssertEqual(r2d2.jsonObject, ["__typename": "Droid", "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
  }
  
  func testJSONObjectFromCharacterNameAndDroidAppearsInFragmentForDroid() throws {
    let r2d2 = CharacterNameAndDroidAppearsIn.makeDroid(name: "R2-D2", appearsIn: [.newhope, .empire, .jedi])
    
    XCTAssertEqual(r2d2.jsonObject, ["__typename": "Droid", "name": "R2-D2", "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
  }
  
  func testJSONObjectFromCharacterNameAndDroidAppearsInFragmentForHuman() throws {
    let r2d2 = CharacterNameAndDroidAppearsIn.makeHuman(name: "Luke Skywalker")
    
    XCTAssertEqual(r2d2.jsonObject, ["__typename": "Human", "name": "Luke Skywalker"])
  }
  
  func testJSONObjectFromHeroDetailsFragmentWithTypeSpecificProperty() throws {
    let r2d2 = HeroDetails.makeDroid(name: "R2-D2", primaryFunction: "Protocol")
    
    XCTAssertEqual(r2d2.jsonObject, ["__typename": "Droid", "name": "R2-D2", "primaryFunction": "Protocol"])
  }
  
  func testJSONObjectFromHeroDetailsFragmentWithMissingTypeSpecificProperty() throws {
    let r2d2 = HeroDetails.makeDroid(name: "R2-D2")
    
    XCTAssertEqual(r2d2.jsonObject, ["__typename": "Droid", "name": "R2-D2", "primaryFunction": NSNull()])
  }
  
  func testJSONObjectFromHumanHeightWithVariableFragment() throws {
    let luke = HumanHeightWithVariable(height: 1.72)
    
    XCTAssertEqual(luke.jsonObject, ["__typename": "Human", "height": 1.72])
  }
  
  // MARK: - Converting JSON objects into fragments
  
  func testCharacterNameFragmentForDroidFromJSONObject() throws {
    let r2d2 = try CharacterName(jsonObject: ["__typename": "Droid", "name": "R2-D2"])
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
  }
  
  func testCharacterNameFragmentForDroidFromJSONObjectWithMissingName() throws {
    XCTAssertThrowsError(try CharacterName(jsonObject: ["__typename": "Droid"])) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testCharacterNameFragmentForDroidFromJSONObjectWithNullName() throws {
    XCTAssertThrowsError(try CharacterName(jsonObject: ["__typename": "Droid", "name": NSNull()])) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["name"])
        XCTAssertMatch(error.underlying, JSONDecodingError.nullValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testCharacterNameFragmentFromJSONObjectWithMissingTypename() throws {
    XCTAssertThrowsError(try CharacterName(jsonObject: ["name": "R2-D2"])) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["__typename"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testCharacterNameFragmentFromJSONObjectWithUnknownTypename() throws {
    let r2d2 = try CharacterName(jsonObject: ["__typename": "Pokemon", "name": "Charmander"])
    
    XCTAssertEqual(r2d2.__typename, "Pokemon")
    XCTAssertEqual(r2d2.name, "Charmander")
  }
  
  func testCharacterAppearsInFragmentFromJSONObjectForDroid() throws {
    let r2d2 = try CharacterAppearsIn(jsonObject: ["__typename": "Droid", "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.appearsIn, [.newhope, .empire, .jedi])
  }
  
  func testCharacterNameAndDroidAppearsInFragmentFromJSONObjectForDroid() throws {
    let r2d2 = try CharacterNameAndDroidAppearsIn(jsonObject: ["__typename": "Droid", "name": "R2-D2", "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    XCTAssertEqual(r2d2.asDroid?.appearsIn, [.newhope, .empire, .jedi])
  }
  
  func testCharacterNameAndDroidAppearsInFragmentFromJSONObjectForDroidRequiresAppearsIn() throws {
    XCTAssertThrowsError(try CharacterNameAndDroidAppearsIn(jsonObject: ["__typename": "Droid", "name": "R2-D2"])) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testCharacterNameAndDroidAppearsInFragmentFromJSONObjectForHuman() throws {
    let luke = try CharacterNameAndDroidAppearsIn(jsonObject: ["__typename": "Human", "name": "Luke Skywalker"])
    
    XCTAssertEqual(luke.__typename, "Human")
    XCTAssertEqual(luke.name, "Luke Skywalker")
    XCTAssertNil(luke.asDroid)
  }
  
  func testCharacterNameAndDroidAppearsInFragmentFromJSONObjectForHumanIgnoresAppearsIn() throws {
    let luke = try CharacterNameAndDroidAppearsIn(jsonObject: ["__typename": "Human", "name": "Luke Skywalker", "appearsIn": ["NEWHOPE", "EMPIRE", "JEDI"]])
    
    XCTAssertEqual(luke.__typename, "Human")
    XCTAssertEqual(luke.name, "Luke Skywalker")
    XCTAssertNil(luke.asDroid)
  }
  
  func testHeroDetailsFragmentFromJSONObjectWithTypeSpecificProperty() throws {
    let r2d2 = try HeroDetails(jsonObject: ["__typename": "Droid", "name": "R2-D2", "primaryFunction": "Protocol"])
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    XCTAssertEqual(r2d2.asDroid?.primaryFunction, "Protocol")
    XCTAssertNil(r2d2.asHuman)
  }
  
  func testHeroDetailsFragmentFromJSONObjectWithMissingTypeSpecificProperty() throws {
    XCTAssertThrowsError(try HeroDetails(jsonObject: ["__typename": "Droid", "name": "R2-D2"])) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["primaryFunction"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testHeroDetailsFragmentFromJSONObjectWithNullTypeSpecificProperty() throws {
    let r2d2 = try HeroDetails(jsonObject: ["__typename": "Droid", "name": "R2-D2", "primaryFunction": NSNull()])
    
    XCTAssertEqual(r2d2.__typename, "Droid")
    XCTAssertEqual(r2d2.name, "R2-D2")
    XCTAssertNil(r2d2.asDroid?.primaryFunction)
    XCTAssertNil(r2d2.asHuman)
  }
  
  func testHumanHeightWithVariableFragmentFromJSONObject() throws {
    let luke = try HumanHeightWithVariable(jsonObject: ["__typename": "Human", "height": 1.72])
    
    XCTAssertEqual(luke.__typename, "Human")
    XCTAssertEqual(luke.height, 1.72)
  }
  
  // MARK: - Converting fragments into another type of fragment
  
  func testConvertCharacterNameAndApearsInFragmentIntoCharacterNameFragment() throws {
    let characterNameAndAppearsIn = CharacterNameAndAppearsIn.makeDroid(name: "R2-D2", appearsIn: [.newhope, .empire, .jedi])
    
    let characterName = try CharacterName(characterNameAndAppearsIn)
    
    XCTAssertEqual(characterName.__typename, "Droid")
    XCTAssertEqual(characterName.name, "R2-D2")
  }
  
  func testConvertCharacterNameIntoCharacterNameAndAppearsInFragment() throws {
    let characterName = CharacterName.makeDroid(name: "R2-D2")
    
    XCTAssertThrowsError(try CharacterNameAndAppearsIn(characterName)) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testConvertCharacterNameIntoCharacterNameAndDroidAppearsInFragment() throws {
    let characterName = CharacterName.makeDroid(name: "R2-D2")
    
    XCTAssertThrowsError(try CharacterNameAndDroidAppearsIn(characterName)) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testConvertHeroDetailsIntoCharacterNameFragment() throws {
    let heroDetails = HeroDetails.makeDroid(name: "R2-D2", primaryFunction: "Protocol")
    
    let heroName = try CharacterName(heroDetails)
    
    XCTAssertEqual(heroName.__typename, "Droid")
    XCTAssertEqual(heroName.name, "R2-D2")
  }
  
  func testConvertCharacterNameIntoHeroDetailsFragment() throws {
    let characterName = CharacterName.makeDroid(name: "R2-D2")
    
    XCTAssertThrowsError(try HeroDetails(characterName)) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["primaryFunction"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testConvertCharacterNameIntoCharacterNameAndDroidAppearsInFragmentForDroid() throws {
    let characterName = CharacterName.makeDroid(name: "R2-D2")
    
    XCTAssertThrowsError(try CharacterNameAndDroidAppearsIn(characterName)) { error in
      if case let error as GraphQLResultError = error {
        XCTAssertEqual(error.path, ["appearsIn"])
        XCTAssertMatch(error.underlying, JSONDecodingError.missingValue)
      } else {
        XCTFail("Unexpected error: \(error)")
      }
    }
  }
  
  func testConvertCharacterNameIntoCharacterNameAndDroidAppearsInFragmentForHuman() throws {
    let characterName = CharacterName.makeHuman(name: "Luke Skywalker")
    
    let characterNameAndDroidAppearsIn = try CharacterNameAndDroidAppearsIn(characterName)
    
    XCTAssertEqual(characterNameAndDroidAppearsIn.__typename, "Human")
    XCTAssertEqual(characterNameAndDroidAppearsIn.name, "Luke Skywalker")
  }
  
  func testConvertCharacterNameIntoDroidNameFragmentForDroid() throws {
    let characterName = CharacterName.makeDroid(name: "R2-D2")
    
    let droidName = try DroidName(characterName)
    
    XCTAssertEqual(droidName.__typename, "Droid")
    XCTAssertEqual(droidName.name, "R2-D2")
  }
  
  // TODO: Either fix or document behavior
  /*
  func testConvertCharacterNameIntoDroidNameFragmentForHuman() throws {
    let characterName = CharacterName.makeHuman(name: "Luke Skywalker")
    
    XCTAssertThrowsError(try DroidName(characterName)) { error in
    }
  }
  */
}
