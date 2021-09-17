**CLASS**

# `ApolloCodegenFrontend`

```swift
public final class ApolloCodegenFrontend
```

## Methods
### `init()`

```swift
public init() throws
```

### `loadSchema(from:)`

```swift
public func loadSchema(from fileURL: URL) throws -> GraphQLSchema
```

Load a schema by parsing either an introspection result or SDL based on the file extension.

### `loadSchemaFromIntrospectionResult(_:)`

```swift
public func loadSchemaFromIntrospectionResult(_ introspectionResult: String) throws -> GraphQLSchema
```

Load a schema by parsing  an introspection result.

### `loadSchemaFromSDL(_:)`

```swift
public func loadSchemaFromSDL(_ source: GraphQLSource) throws -> GraphQLSchema
```

Load a schema by parsing SDL.

### `printSchemaAsSDL(schema:)`

```swift
public func printSchemaAsSDL(schema: GraphQLSchema) throws -> String
```

Take a loaded GQL schema and print it as SDL.

### `makeSource(_:filePath:)`

```swift
public func makeSource(_ body: String, filePath: String) throws -> GraphQLSource
```

Create a `GraphQLSource` object from a string.

### `makeSource(from:)`

```swift
public func makeSource(from fileURL: URL) throws -> GraphQLSource
```

Create a `GraphQLSource` object by reading from a file.

### `parseDocument(_:)`

```swift
public func parseDocument(_ source: GraphQLSource) throws -> GraphQLDocument
```

Parses a GraphQL document from a source, returning a reference to the parsed AST that can be passed on to validation and compilation.
Syntax errors will result in throwing a `GraphQLError`.

### `parseDocument(from:)`

```swift
public func parseDocument(from fileURL: URL) throws -> GraphQLDocument
```

Parses a GraphQL document from a file, returning a reference to the parsed AST that can be passed on to validation and compilation.
Syntax errors will result in throwing a `GraphQLError`.

### `mergeDocuments(_:)`

```swift
public func mergeDocuments(_ documents: [GraphQLDocument]) throws -> GraphQLDocument
```

Validation and compilation take a single document, but you can merge documents, and operations and fragments will remember their source.

### `validateDocument(schema:document:)`

```swift
public func validateDocument(schema: GraphQLSchema, document: GraphQLDocument) throws -> [GraphQLError]
```

Validate a GraphQL document and return any validation errors as `GraphQLError`s.

### `compile(schema:document:)`

```swift
public func compile(schema: GraphQLSchema, document: GraphQLDocument) throws -> CompilationResult
```

Compiles a GraphQL document into an intermediate representation that is more suitable for analysis and code generation.
