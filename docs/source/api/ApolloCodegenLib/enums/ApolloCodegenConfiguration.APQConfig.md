**ENUM**

# `ApolloCodegenConfiguration.APQConfig`

```swift
public enum APQConfig: String, Codable, Equatable
```

Enum to enable using
[Automatic Persisted Queries (APQs)](https://www.apollographql.com/docs/apollo-server/performance/apq)
with your generated operations.

APQs are an Apollo Server feature. When using Apollo iOS to connect to any other GraphQL server,
`APQConfig` should be set to `.disabled`

## Cases
### `disabled`

```swift
case disabled
```

The default value. Disables APQs.
The operation document is sent to the server with each operation request.

### `automaticallyPersist`

```swift
case automaticallyPersist
```

Automatically persists your operations using Apollo Server's
[APQs](https://www.apollographql.com/docs/apollo-server/performance/apq).

### `persistedOperationsOnly`

```swift
case persistedOperationsOnly
```

Provides only the `operationIdentifier` for operations that have been previously persisted
to an Apollo Server using
[APQs](https://www.apollographql.com/docs/apollo-server/performance/apq).

If the server does not recognize the `operationIdentifier`, the operation will fail. This
method should only be used if you are manually persisting your queries to an Apollo Server.
