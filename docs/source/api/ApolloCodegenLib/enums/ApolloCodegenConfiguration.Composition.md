**ENUM**

# `ApolloCodegenConfiguration.Composition`

```swift
public enum Composition: String, Codable, Equatable
```

Composition is used as a substitute for a boolean where context is better placed in the value
instead of the parameter name, e.g.: `includeDeprecatedEnumCases = true` vs.
`deprecatedEnumCases = .include`.

## Cases
### `include`

```swift
case include
```

### `exclude`

```swift
case exclude
```
