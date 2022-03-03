**PROTOCOL**

# `ApolloCompatible`

```swift
public protocol ApolloCompatible
```

Protocol to allow calls to extended methods and vars as object.apollo.method

NOTE: This does not work with a bunch of stuff involving generic types - those
still need to use old-school `apollo_method` naming conventions.

## Properties
### `apollo`

```swift
var apollo: ApolloExtension<Base>
```

The `ApolloExtension` object for an instance

### `apollo`

```swift
static var apollo: ApolloExtension<Base>.Type
```

The `ApolloExtension` object for a type
