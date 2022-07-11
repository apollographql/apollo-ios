**ENUM**

# `DownloadMethod.OutputFormat`

```swift
public enum OutputFormat: String, Equatable, CustomStringConvertible, Codable
```

The output format for the downloaded schema. This is an option on Introspection schema
downloads only. For Apollo Registry schema downloads, the schema will always be output as
an SDL document

## Cases
### `SDL`

```swift
case SDL
```

A Schema Definition Language (SDL) document defining the schema as described in
the [GraphQL Specification](https://spec.graphql.org/draft/#sec-Schema)

### `JSON`

```swift
case JSON
```

A JSON schema definition provided as the result of a schema introspection query.

## Properties
### `description`

```swift
public var description: String
```
