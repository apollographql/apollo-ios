**ENUM**

# `ApolloCodegen.Error`

```swift
public enum Error: Swift.Error, LocalizedError
```

Errors that can occur during code generation.

## Cases
### `graphQLSourceValidationFailure(atLines:)`

```swift
case graphQLSourceValidationFailure(atLines: [String])
```

An error occured during validation of the GraphQL schema or operations.

## Properties
### `errorDescription`

```swift
public var errorDescription: String?
```
