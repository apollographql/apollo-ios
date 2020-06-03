**TYPEALIAS**

# `GraphQLResultHandler`

```swift
public typealias GraphQLResultHandler<Data> = (Result<GraphQLResult<Data>, Error>) -> Void
```

> A handler for operation results.
>
> - Parameters:
>   - result: The result of a performed operation. Will have a `GraphQLResult` with any parsed data and any GraphQL errors on `success`, and an `Error` on `failure`.