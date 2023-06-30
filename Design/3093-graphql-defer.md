* Feature Name: GraphQL `@defer`
* Start Date: 2023-06-26
* RFC PR: [3093](https://github.com/apollographql/apollo-ios/pull/3093)

# Summary

The specification for `@defer`/`@stream` is slowly making it's way through the GraphQL Foundation approval process and once formally merged into the GraphQL specification Apollo iOS will need to support it. However, Apollo already has a public implementation of `@defer` in the other OSS offerings, namely Apollo Server, Apollo Client, and Apollo Kotlin. The goal of this project is to implement support for `@defer` that matches the other Apollo OSS clients. This project will not include support for the `@stream` directive.

Based on the progress of `@defer`/`@stream` through the approval process there may be some differences in the final specification vs. what is currently implemented in Apollo's OSS. This project does not attempt to preemptively anticipate those changes nor comply with the potentially merged specification. Any client affecting-changes in the merged specification will be implemented into Apollo iOS.

# Proposed Changes

## Update graphql-js dependency

Apollo iOS uses [graphql-js](https://github.com/graphql/graphql-js) for validation of the GraphQL schema and operation documents as the first step in the code generation workflow. The version of this [dependency](https://github.com/apollographql/apollo-ios/blob/spike/defer/Sources/ApolloCodegenLib/Frontend/JavaScript/package.json#L16) is fixed at [`16.3.0-canary.pr.3510.5099f4491dc2a35a3e4a0270a55e2a228c15f13b`](https://www.npmjs.com/package/graphql/v/16.3.0-canary.pr.3510.5099f4491dc2a35a3e4a0270a55e2a228c15f13b?activeTab=versions). This is a version of graphql-js that supports the experimental [Client Controlled Nullability](https://github.com/graphql/graphql-wg/blob/main/rfcs/ClientControlledNullability.md) feature but does not support the `@defer` directive.

The latest `16.x` release of graphql-js with support for the `@defer` directive is [`16.1.0-experimental-stream-defer.6`](https://www.npmjs.com/package/graphql/v/16.1.0-experimental-stream-defer.6) but it looks like the 'experimental' named releases for `@defer` have been discontinued and the recommendation is to use [`17.0.0-alpha.2`](https://www.npmjs.com/package/graphql/v/17.0.0-alpha.2). This is further validated by the fact that [`16.7.0` does not](https://github.com/graphql/graphql-js/blob/v16.7.0/src/type/directives.ts#L167) include the @defer directive whereas [`17.0.0-alpha.2` does](https://github.com/graphql/graphql-js/blob/v17.0.0-alpha.2/src/type/directives.ts#L159).

There are a few options for updating the graphql-js dependency:
1. Add support for Client Controlled Nullability to `17.0.0-alpha.2`, or the latest 17.0.0 alpha release, and publish that to NPM. The level of effort for this is unknown but it would allow us to maintain support for CCN.
2. Use `17.0.0-alpha.2`, or the latest 17.0.0 alpha release, as-is and remove the experimental Client Controlled Nullability feature. We do not know how many users rely on the CCN functionality so this may be a controversial decision. This path doesn’t necessarily imply an easier dependency update because there will be changes needed to our frontend javascript to adapt to the changes in graphql-js.
3. Another option is a staggered approach where we adopt `17.0.0-alpha.2`, or the latest 17.0.0 alpha release, limiting the changes to our frontend javascript only and at a later stage bring the CCN changes from [PR `#3510`](https://github.com/graphql/graphql-js/pull/3510) to the `17.x` release path and reintroduce support for CCN to Apollo iOS. This would also require the experiemental CCN feature to be removed, with no committment to when it would be reintroduced.

## Rename `PossiblyDeferred` types/functions

Adding support for `@defer` brings new meaning of the word 'deferred' to the codebase. There is an enum type named [`PossiblyDeferred`](https://github.com/apollographql/apollo-ios/blob/spike/defer/Sources/Apollo/PossiblyDeferred.swift#L47) which would cause confusion when trying to understand it’s intent. This type and its related functions should be renamed to disambiguate it from the incoming `@defer` related types and functions.

`PossiblyDeferred` is an internal type so this should have no adverse effect to users’ code.

## Generated models

Generated models will definitely be affected by `@defer` statements in the operation. Ideally there is easy-to-read annotation indicating something is deferred by simply reading the generated model code but more importantly it must be easy when using the generated models in code to detect whether something is deferred or not.

The most simple solution is to change the deferred property type to an optional version of that type. This hides detail though because you wouldn't be able to tell whether the value is `nil` because the response data has been received yet (i.e.: deferred) or whether the data was returned and it was explicitly `null`. It also gets more complicated when a type is already optional; would that result in a Swift double-optional type? As we learnt with the legacy implementation of GraphQL nullability, double-optionals are difficult to interpret and easy lead to errors.

I explored Swift's property wrappers but they suffer from the limitation of not being able to be applied to a computed property. All model properties are computed properties because they simply route access the value in the underlying dictionary data storage. It would be nice to be able to simply annotate fragments and fields with some like `@Deferred` but it doesn't look like that is possible.

An idea that was suggested by [`@Iron-Ham`](https://github.com/apollographql/apollo-ios/issues/2395#issuecomment-1433628466) is to wrap the type in a Swift enum that can expose the deferred state as well as the underlying value once it has been received.

_Example enum to wrap deferred properties_
```swift
enum DeferredValue<T> {
    case loading
    case result(Result<T, Error>)
}
```
_Sample model with `DeferredResponse`_
```swift
public struct ModelSelectionSet: GraphAPI.SelectionSet {
  // other properties no shown

  public var name: DeferredValue<String?> { __data["name"] }
}
```

Deferred fragment definitions in generated models will get an additional property to indicate they are deferred.

_Updated `Selection` enum_
```swift
public enum Selection {
  // other cases not shown
  case fragment(any Fragment.Type, deferred: Bool)
  case inlineFragment(any InlineFragment.Type, deferred: Bool)

  // other properties and types not shown
}
```

_Example usage in a generated model_
```swift
  public static var __selections: [ApolloAPI.Selection] { [
    .inlineFragment(AsEntity.self, deferred: true),
  ] }

  public static var __selections: [ApolloAPI.Selection] { [
    .fragment(EntityFragment.self, deferred: true),
  ] }
```

### Deferred fragments

_In progress_

### Merged fields

_In progress_

### Selection set initializers

_In progress_

## Networking 

### Request header

If an operation can support an incremental delivery response it must add an `Accept` header to the HTTP request specifying the protocol version that can be parsed. An [example](https://github.com/apollographql/apollo-ios/blob/spike/defer/Sources/Apollo/RequestChainNetworkTransport.swift#L115) is HTTP subscription requests that include the `subscriptionSpec=1.0` specification. `@defer` would introduce another operation feature that would request an incremental delivery response.

This should not be sent with all requests though so operations will need to be identifiable as having deferred fragments to signal inclusion of the request header.

_Sample code for `RequestChainNetworkTransport`_
```swift
public func send<Operation: GraphQLOperation>(
  operation: Operation,
  cachePolicy: CachePolicy = .default,
  contextIdentifier: UUID? = nil,
  callbackQueue: DispatchQueue = .main,
  completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
) -> Cancellable {
    // request chain and request are built

    if Operation.hasDeferredFragments {
      request.addHeader(
        name: "Accept",
        value: "multipart/mixed;deferSpec=20220824,application/json"
      )
    }

    // request chain kickoff
  }
```

_Sample of new property on `GraphQLOperation`_
```swift
public protocol GraphQLOperation: AnyObject, Hashable {
  // other properties not shown

  static var hasDeferredFragments: Bool { get } // computed for each operation during codegen
}
```

### Response parsing

Apollo iOS already has support for parsing incremental delivery responses. That provides a great foundation to build on however there are some changes needed.

#### Multipart parsing protocol

The current `MultipartResponseParsingInterceptor` implementation is specific to the `subscriptionSpec` version `1.0` specification. Adopting a protocol with implementations for each of the supported specifications will enable us to support any number of incremental delivery specifications in the future.

These would be registered with the `MultipartResponseParsingInterceptor` for an each specification string, and when a response is received the specification string is extracted from the response `content-type` header, and the correct specification parser can be used to parse the response data.

_Sample code in `MultipartResponseParsingInterceptor`_
```swift
public struct MultipartResponseParsingInterceptor: ApolloInterceptor {
  private static let multipartParsers: [String: MultipartResponseSpecificationParser.Type] = [
    SubscriptionResponseParser.protocolSpec: SubscriptionResponseParser.self,
    DeferResponseParser.protocolSpec: DeferResponseParser.self
  ]

  public func interceptAsync<Operation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) where Operation : GraphQLOperation {
    // response validators not shown

    guard
      let multipartBoundary = response.httpResponse.multipartBoundary,
      let protocolSpec = response.httpResponse.multipartProtocolSpec,
      let protocolParser = Self.multipartParsers[protocolSpec]
    else {
      // call request chain error handler

      return
    }

    let dataHandler: ((Data) -> Void) = { data in
      // proceed ahead on the request chain
    }

    let errorHandler: (() -> Void) = {
      // call request chain error handler
    }

    protocolParser.parse(
      data: response.rawData,
      boundary: multipartBoundary,
      dataHandler: dataHandler,
      errorHandler: errorHandler
    )
  }
```

_Sample protocol for multipart specification parsing_
```swift
protocol MultipartResponseSpecificationParser {
  static var protocolSpec: String { get }

  static func parse(
    data: Data,
    boundary: String,
    dataHandler: ((Data) -> Void),
    errorHandler: (() -> Void)
  )
}
```

_Sample implementations of multipart specification parsers_
```swift
struct SubscriptionResponseParser: MultipartResponseSpecificationParser {
  static let protocolSpec: String = "subscriptionSpec=1.0"

  static func parse(
    data: Data,
    boundary: String,
    dataHandler: ((Data) -> Void),
    errorHandler: (() -> Void)
  ) {
    // parsing code currently in MultipartResponseParsingInterceptor
  }
}

struct DeferResponseParser: MultipartResponseSpecificationParser {
  static let protocolSpec: String = "deferSpec=20220824"

  static func parse(
    data: Data,
    boundary: String,
    dataHandler: ((Data) -> Void),
    errorHandler: (() -> Void)
  ) {
    // new code to parser the defer specification
  }
}
```

#### Response data

The initial response data and data received in each incremental response will need to be retained and combined so that each incremental response can insert the latest received incremental response data at the correct path and return an up-to-date response to the request callback.

The data being retained and combined should not require another pass through the GraphQL executor though.

### Completion handler

`GraphQLResult` should be modified to provide query completion blocks with a high-level abstraction of whether the request has been fulfilled or is still in progress. This prevents clients from having to dig into the deferred fragments to identify the state of the overall request.

One way to do this is through a property on the `GraphQLResult` type.

```swift
public struct GraphQLResult<Data: RootSelectionSet> {
  // other properties and types

  public enum Response {
    case partial
    case complete
  }

  public let response: Response
}
```

_Sample usage in an app_
```swift
  client.fetch(query: ExampleQuery()) { result in
    switch (result) {
    case let .success(data):
      switch (data.response) {
      case .complete:
      case .partial:
      }
    case let .failure(error):
    }
  }
```

Another way which may be a bit more intuitive is to make the `server` case on `Source` have an associated value since `cache` sources will always be complete. The cache could return partial responses for deferred operations but for the initial implementation we will probably only write the cache record once all deferred fragments have been received.

```swift
public struct GraphQLResult<Data: RootSelectionSet> {
  // other properties and types

  public enum Response {
    case partial
    case complete
  }

  public enum Source: Hashable {
    case cache
    case server(_ response: Response)
  }
}
```

_Sample usage in an app_
```swift
  client.fetch(query: ExampleQuery()) { result in
    switch (result) {
    case let .success(data):
      switch (data.source) {
      case .server(.complete):
      case .server(.partial):
      case .cache:
      }
    case let .failure(error):
    }
  }
```

## GraphQL execution

The executor currently executes on an entire operation selection set. It will need to be adapted to be able to execute on a partial response when deferred fragments have not been received and on an isolated fragment selection set so that incremental responses can be parsed alone instead of needing to execute on the whole operation’s selection set.

An alternative to parsing isolated fragment selection sets would be to execute on all the data currently received. The inefficiency with this is executing on data that would have already been executed on during prior responses.

## Caching

Similarly to GraphQL execution the cache write interceptor is designed to work holistically on the operation and write cache records for a single response. This approach still works for HTTP-based subscriptions because each incremental response contains a selection set for the entire operation.

This approach is not going to work for the incremental responses of `@defer` though and partial responses cannot be written to the cache for the operation. Instead all deferred responses will need to be fulfilled before the record is written to the cache.

_Only write cache records for complete responses_
```swift
public struct CacheWriteInterceptor: ApolloInterceptor {
  ...

  public func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    // response validators not shown

    guard
      let createdResponse = response,
      let parsedResponse = createdResponse.parsedResponse,
      parsedResponse.source == .server(.complete)
    else {
      // a partial response must have been received and should not be written to the cache
      return
    }

    // cache write code not shown
  }
}
```

There is a bunch of complexity in writing partial records to the cache such as: query watchers without deferred fragments; how would we handle failed requests; race conditions to fulfil deferred data; amongst others. These problems need careful, thoughtful solutions and this project will not include them in the scope for initial implementation. 
