//
//  Pluralizer.swift
//  Apollo
//
//  Created by Ellen Shapiro on 11/30/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import Foundation
import InflectorKit

/// The types of inflection rules that can be used to customize pluralization. 
public enum InflectionRule {

  /// A pluralization rule that allows taking a singular word and pluralizing it.
  /// - singularRegex: A regular expression representing the single version of the word
  /// - replacementRegex: A regular expression representing how to replace the singular version.
  case pluralization(singularRegex: String, replacementRegex: String)
  
  /// A singularization rule that allows taking a plural word and singularizing it.
  /// - pluralRegex: A regular expression represeinting the plural version of the word
  /// - replacementRegex: A regular expression representing how to replace the singular version
  case singularization(pluralRegex: String, replacementRegex: String)
  
  /// A definition of an irregular pluralization rule not easily captured by regex - for example "person" and "people".
  /// - singular: The singular version of the word
  /// - plural: The plural version of the word.
  case irregular(singular: String, plural: String)
  
  /// A definition of a word that should never be pluralized or de-pluralized because it's the same no matter what the count - for example, "fish".
  /// - word: The word that should never be adjusted.
  case uncountable(word: String)
}

struct Pluralizer {
  
  private let inflector: TTTStringInflector
  
  init(rules: [InflectionRule] = []) {
    let inflector = TTTStringInflector.default()
    for rule in rules {
      switch rule {
      case .pluralization(let pluralRegex, let replacementRegex):
        inflector.addPluralRule(pluralRegex, withReplacement: replacementRegex)
      case .singularization(let singularRegex, let replacementRegex):
        inflector.addSingularRule(singularRegex, withReplacement: replacementRegex)
      case .irregular(let singular, let plural):
        inflector.addIrregular(withSingular: singular, plural: plural)
      case .uncountable(let word):
        inflector.addUncountable(word)
      }
    }
    
    self.inflector = inflector
  }
  
  func singularize(_ string: String) -> String {
    self.inflector.singularize(string)
  }
  
  func pluralize(_ string: String) -> String {
    self.inflector.pluralize(string)
  }
}
