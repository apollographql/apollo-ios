**STRUCT**

# `ApolloCodegenConfiguration.OutputOptions`

```swift
public struct OutputOptions: Codable, Equatable
```

## Properties
### `additionalInflectionRules`

```swift
public let additionalInflectionRules: [InflectionRule]
```

Any non-default rules for pluralization or singularization you wish to include.

### `queryStringLiteralFormat`

```swift
public let queryStringLiteralFormat: QueryStringLiteralFormat
```

Formatting of the GraphQL query string literal that is included in each
generated operation object.

### `deprecatedEnumCases`

```swift
public let deprecatedEnumCases: Composition
```

How deprecated enum cases from the schema should be handled.

### `schemaDocumentation`

```swift
public let schemaDocumentation: Composition
```

Whether schema documentation is added to the generated files.

### `apqs`

```swift
public let apqs: APQConfig
```

Whether the generated operations should use Automatic Persisted Queries.

See `APQConfig` for more information on Automatic Persisted Queries.

### `warningsOnDeprecatedUsage`

```swift
public let warningsOnDeprecatedUsage: Composition
```

Annotate generated Swift code with the Swift `available` attribute and `deprecated`
argument for parts of the GraphQL schema annotated with the built-in `@deprecated`
directive.

## Methods
### `init(additionalInflectionRules:queryStringLiteralFormat:deprecatedEnumCases:schemaDocumentation:apqs:warningsOnDeprecatedUsage:)`

```swift
public init(
  additionalInflectionRules: [InflectionRule] = [],
  queryStringLiteralFormat: QueryStringLiteralFormat = .multiline,
  deprecatedEnumCases: Composition = .include,
  schemaDocumentation: Composition = .include,
  apqs: APQConfig = .disabled,
  warningsOnDeprecatedUsage: Composition = .include
)
```

Designated initializer.

- Parameters:
 - additionalInflectionRules: Any non-default rules for pluralization or singularization
 you wish to include.
 - queryStringLiteralFormat: Formatting of the GraphQL query string literal that is
 included in each generated operation object.
 - deprecatedEnumCases: How deprecated enum cases from the schema should be handled.
 - schemaDocumentation: Whether schema documentation is added to the generated files.
 - apqs: Whether the generated operations should use Automatic Persisted Queries.
 - warningsOnDeprecatedUsage: Annotate generated Swift code with the Swift `available`
 attribute and `deprecated` argument for parts of the GraphQL schema annotated with the
 built-in `@deprecated` directive.
