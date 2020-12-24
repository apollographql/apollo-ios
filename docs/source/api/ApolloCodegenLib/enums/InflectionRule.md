**ENUM**

# `InflectionRule`

```swift
public enum InflectionRule
```

The types of inflection rules that can be used to customize pluralization.

## Cases
### `pluralization(singularRegex:replacementRegex:)`

```swift
case pluralization(singularRegex: String, replacementRegex: String)
```

A pluralization rule that allows taking a singular word and pluralizing it.
- singularRegex: A regular expression representing the single version of the word
- replacementRegex: A regular expression representing how to replace the singular version.

### `singularization(pluralRegex:replacementRegex:)`

```swift
case singularization(pluralRegex: String, replacementRegex: String)
```

A singularization rule that allows taking a plural word and singularizing it.
- pluralRegex: A regular expression represeinting the plural version of the word
- replacementRegex: A regular expression representing how to replace the singular version

### `irregular(singular:plural:)`

```swift
case irregular(singular: String, plural: String)
```

A definition of an irregular pluralization rule not easily captured by regex - for example "person" and "people".
- singular: The singular version of the word
- plural: The plural version of the word.

### `uncountable(word:)`

```swift
case uncountable(word: String)
```

A definition of a word that should never be pluralized or de-pluralized because it's the same no matter what the count - for example, "fish".
- word: The word that should never be adjusted.
