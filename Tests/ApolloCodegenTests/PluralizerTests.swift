import Foundation
import XCTest
@testable import ApolloCodegenLib

class PluralizerTests: XCTestCase {
  
  func testSingularization_givenSimpleWord_shouldSingularize() {
    let pluralizer = Pluralizer()
    let pluralized = "Cats"
    let singular = pluralizer.singularize(pluralized)
    XCTAssertEqual(singular, "Cat")
  }
  
  func testPluralization_givenSimpleWord_shouldPluralize() {
    let pluralizer = Pluralizer()
    let singular = "Cat"
    let pluralized = pluralizer.pluralize(singular)
    XCTAssertEqual(pluralized, "Cats")
  }
  
  func testSingularization_addingSingularizationRule_shouldSingularize() {
    let defaultPluralizer = Pluralizer()
    let pluralized = "Atlases"
    let beforeRule = defaultPluralizer.singularize(pluralized)
    
    // This should be wrong because we haven't applied the rule yet.
    XCTAssertEqual(beforeRule, "Atlase")
    
    let pluralizerWithRule = Pluralizer(rules: [
      .singularization(pluralRegex: "(atlas)(es)?$", replacementRegex: "$1")
    ])
    
    let afterRule = pluralizerWithRule.singularize(pluralized)
    
    // Now that we've applied the rule, this should be correct
    XCTAssertEqual(afterRule, "Atlas")
  }
  
  func testPluralization_addingPluralizationRule_shouldPluralize() {
    let defaultPluralizer = Pluralizer()
    let singular = "Atlas"
    let beforeRule = defaultPluralizer.pluralize(singular)
    
    // This should be wrong because we haven't applied the rule yet.
    XCTAssertEqual(beforeRule, "Atlas")
    
    let pluralizerWithRule = Pluralizer(rules: [
      .pluralization(singularRegex: "(atla)s", replacementRegex: "$1ses")
    ])
    let singularized = pluralizerWithRule.pluralize(singular)
    
    // Now that we've applied the rule, this should be correct
    XCTAssertEqual(singularized, "Atlases")
  }
 
  func testPluralization_givenSpecificCasing_shouldNotChangeCasing() {
    let pluralizer = Pluralizer()
    let singular = "CAT"
    let pluralized = pluralizer.pluralize(singular)
    XCTAssertEqual(pluralized, "CATs")
    
    let singularWithLowercase = "CaT"
    let pluralizedWithLowercase = pluralizer.pluralize(singularWithLowercase)
    XCTAssertEqual(pluralizedWithLowercase, "CaTs")
  }
  
  func testSingularization_givenCasedSuffix_shouldSingularize() {
    let pluralizer = Pluralizer()
    let pluralizedAllCaps = "CTAS"
    let singularizedAllCaps = pluralizer.singularize(pluralizedAllCaps)
    XCTAssertEqual(singularizedAllCaps, "CTA")

    let pluralizedWithOneLowercase = "CTAs"
    let singularizedWithOneLowercase = pluralizer.singularize(pluralizedWithOneLowercase)
    XCTAssertEqual(singularizedWithOneLowercase, "CTA")
  }
  
}
