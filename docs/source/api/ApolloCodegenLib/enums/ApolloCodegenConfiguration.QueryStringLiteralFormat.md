**ENUM**

# `ApolloCodegenConfiguration.QueryStringLiteralFormat`

```swift
public enum QueryStringLiteralFormat: String, Codable, Equatable
```

Specify the formatting of the GraphQL query string literal.

## Cases
### `singleLine`

```swift
case singleLine
```

The query string will be copied into the operation object with all line break formatting removed.

### `multiline`

```swift
case multiline
```

The query string will be copied with original formatting into the operation object.
