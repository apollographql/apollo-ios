import Foundation
import InflectorKit

/// The types of inflection rules that can be used to customize pluralization. 
public enum InflectionRule: Codable, Equatable {

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
  
  private let inflector: StringInflector
  
  init(rules: [InflectionRule] = []) {
    let inflector = StringInflector()
    self.inflector = inflector

    add(rules: Self.defaultRules)
    add(rules: rules)
  }

  private func add(rules: [InflectionRule]) {
    for rule in rules {
      switch rule {
      case .pluralization(let pluralRegex, let replacementRegex):
        inflector.addPluralRule(pluralRegex, replacement: replacementRegex)
      case .singularization(let singularRegex, let replacementRegex):
        inflector.addSingularRule(singularRegex, replacement: replacementRegex)
      case .irregular(let singular, let plural):
        inflector.addIrregular(singular: singular, plural: plural)
      case .uncountable(let word):
        inflector.addUncountable(word)
      }
    }
  }
  
  func singularize(_ string: String) -> String {
    self.inflector.singularize(string)
  }
  
  func pluralize(_ string: String) -> String {
    self.inflector.pluralize(string)
  }

  private static let defaultRules: [InflectionRule] = [
    .pluralization(singularRegex: "$", replacementRegex: "s"),
    .pluralization(singularRegex: "s$", replacementRegex: "s"),
    .pluralization(singularRegex: "^(ax|test)is$", replacementRegex: "$1es"),
    .pluralization(singularRegex: "(octop|vir)us$", replacementRegex: "$1i"),
    .pluralization(singularRegex: "(octop|vir)i$", replacementRegex: "$1i"),
    .pluralization(singularRegex: "(alias|status)$", replacementRegex: "$1es"),
    .pluralization(singularRegex: "(bu)s$", replacementRegex: "$1ses"),
    .pluralization(singularRegex: "(buffal|tomat)o$", replacementRegex: "$1oes"),
    .pluralization(singularRegex: "([ti])um$", replacementRegex: "$1a"),
    .pluralization(singularRegex: "([ti])a$", replacementRegex: "$1a"),
    .pluralization(singularRegex: "sis$", replacementRegex: "ses"),
    .pluralization(singularRegex: "(?:([^f])fe|([lr])f)$", replacementRegex: "$1$2ves"),
    .pluralization(singularRegex: "(hive)$", replacementRegex: "$1s"),
    .pluralization(singularRegex: "([^aeiouy]|qu)y$", replacementRegex: "$1ies"),
    .pluralization(singularRegex: "(x|ch|ss|sh)$", replacementRegex: "$1es"),
    .pluralization(singularRegex: "(matr|vert|ind)(?:ix|ex)$", replacementRegex: "$1ices"),
    .pluralization(singularRegex: "^(m|l)ouse$", replacementRegex: "$1ice"),
    .pluralization(singularRegex: "^(m|l)ice$", replacementRegex: "$1ice"),
    .pluralization(singularRegex: "^(ox)$", replacementRegex: "$1en"),
    .pluralization(singularRegex: "^(oxen)$", replacementRegex: "$1"),
    .pluralization(singularRegex: "(quiz)$", replacementRegex: "$1zes"),

    .singularization(pluralRegex: "s$", replacementRegex: ""),
    .singularization(pluralRegex: "(ss)$", replacementRegex: "$1"),
    .singularization(pluralRegex: "(n)ews$", replacementRegex: "$1ews"),
    .singularization(pluralRegex: "([ti])a$", replacementRegex: "$1um"),
    .singularization(pluralRegex: "((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)(sis|ses)$", replacementRegex: "$1sis"),
    .singularization(pluralRegex: "(^analy)(sis|ses)$$", replacementRegex: "$1sis"),
    .singularization(pluralRegex: "([^f])ves$", replacementRegex: "$1fe"),
    .singularization(pluralRegex: "(hive)s$", replacementRegex: "$1"),
    .singularization(pluralRegex: "(tive)s$", replacementRegex: "$1"),
    .singularization(pluralRegex: "([lr])ves$", replacementRegex: "$1f"),
    .singularization(pluralRegex: "([^aeiouy]|qu)ies$", replacementRegex: "$1y"),
    .singularization(pluralRegex: "(s)eries$", replacementRegex: "$1eries"),
    .singularization(pluralRegex: "(m)ovies$", replacementRegex: "$1ovie"),
    .singularization(pluralRegex: "(x|ch|ss|sh)es$", replacementRegex: "$1"),
    .singularization(pluralRegex: "^(m|l)ice$", replacementRegex: "$1ouse"),
    .singularization(pluralRegex: "(bus)(es)?$", replacementRegex: "$1"),
    .singularization(pluralRegex: "(o)es$", replacementRegex: "$1"),
    .singularization(pluralRegex: "(shoe)s$", replacementRegex: "$1"),
    .singularization(pluralRegex: "(cris|test)(is|es)$", replacementRegex: "$1is"),
    .singularization(pluralRegex: "^(a)x[ie]s$", replacementRegex: "$1xis"),
    .singularization(pluralRegex: "(octop|vir)(us|i)$", replacementRegex: "$1us"),
    .singularization(pluralRegex: "(alias|status)(es)?$", replacementRegex: "$1"),
    .singularization(pluralRegex: "^(ox)en", replacementRegex: "$1"),
    .singularization(pluralRegex: "(vert|ind)ices$", replacementRegex: "$1ex"),
    .singularization(pluralRegex: "(matr)ices$", replacementRegex: "$1ix"),
    .singularization(pluralRegex: "(quiz)zes$", replacementRegex: "$1"),
    .singularization(pluralRegex: "(database)s$", replacementRegex: "$1"),

    .irregular(singular: "person", plural: "people"),
    .irregular(singular: "man", plural: "men"),
    .irregular(singular: "child", plural: "children"),
    .irregular(singular: "sex", plural: "sexes"),
    .irregular(singular: "move", plural: "moves"),
    .irregular(singular: "zombie", plural: "zombies"),

    .uncountable(word: "equipment"),
    .uncountable(word: "information"),
    .uncountable(word: "rice"),
    .uncountable(word: "money"),
    .uncountable(word: "species"),
    .uncountable(word: "series"),
    .uncountable(word: "fish"),
    .uncountable(word: "sheep"),
    .uncountable(word: "jeans"),
    .uncountable(word: "police"),
  ]
}
