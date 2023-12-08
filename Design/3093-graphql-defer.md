* Feature Name: GraphQL `@defer`
* Start Date: 2023-06-26
* RFC PR: [3093](https://github.com/apollographql/apollo-ios/pull/3093)

# Summary

The specification for `@defer`/`@stream` is slowly making it's way through the GraphQL Foundation approval process and once formally merged into the GraphQL specification Apollo iOS will need to support it. However, Apollo already has a public implementation of `@defer` in the other OSS offerings, namely Apollo Server, Apollo Client, and Apollo Kotlin. The goal of this project is to implement support for `@defer` that matches the other Apollo OSS clients which, based on the commit history, we believe is [the specification as dated at `2022-08-24`](https://github.com/graphql/graphql-spec/tree/48cf7263a71a683fab03d45d309fd42d8d9a6659/spec). This project will not include support for the `@stream` directive.

Based on the progress of `@defer`/`@stream` through the approval process there may be some differences in the final specification vs. what is currently implemented in Apollo's OSS. This project does not attempt to preemptively anticipate those changes nor comply with the potentially merged specification. Any client affecting-changes in the merged specification will be implemented into Apollo iOS.

# Proposed Changes

## Update graphql-js dependency

Apollo iOS uses [graphql-js](https://github.com/graphql/graphql-js) for validation of the GraphQL schema and operation documents as the first step in the code generation workflow. The version of this [dependency](https://github.com/apollographql/apollo-ios/blob/spike/defer/Sources/ApolloCodegenLib/Frontend/JavaScript/package.json#L16) is fixed at [`16.3.0-canary.pr.3510.5099f4491dc2a35a3e4a0270a55e2a228c15f13b`](https://www.npmjs.com/package/graphql/v/16.3.0-canary.pr.3510.5099f4491dc2a35a3e4a0270a55e2a228c15f13b?activeTab=versions). This is a version of graphql-js that supports the experimental [Client Controlled Nullability](https://github.com/graphql/graphql-wg/blob/main/rfcs/ClientControlledNullability.md) feature but does not support the `@defer` directive.

The latest `16.x` release of graphql-js with support for the `@defer` directive is [`16.1.0-experimental-stream-defer.6`](https://www.npmjs.com/package/graphql/v/16.1.0-experimental-stream-defer.6) but it looks like the 'experimental' named releases for `@defer` have been discontinued and the recommendation is to use [`17.0.0-alpha.2`](https://www.npmjs.com/package/graphql/v/17.0.0-alpha.2). This is further validated by the fact that [`16.7.0` does not](https://github.com/graphql/graphql-js/blob/v16.7.0/src/type/directives.ts#L167) include the `@defer` directive whereas [`17.0.0-alpha.2` does](https://github.com/graphql/graphql-js/blob/v17.0.0-alpha.2/src/type/directives.ts#L159).

**Preferred solution (see the end of this document for discarded solutions)**

We will take a staggered approach where we adopt `17.0.0-alpha.2`, or the latest 17.0.0 alpha release, limiting the changes to our frontend javascript only and at a later stage bring the CCN changes from [PR `#3510`](https://github.com/graphql/graphql-js/pull/3510) to the `17.x` release path and reintroduce support for CCN to Apollo iOS. This would also require the experiemental CCN feature to be removed, with no committment to when it would be reintroduced.

_The work to port the CCN PRs to `17.0.0-alpha.2` is being done externally as part of the renewed interest in the CCN proposal._

## Rename `PossiblyDeferred` types/functions

Adding support for `@defer` brings new meaning of the word 'deferred' to the codebase. There is an enum type named [`PossiblyDeferred`](https://github.com/apollographql/apollo-ios/blob/spike/defer/Sources/Apollo/PossiblyDeferred.swift#L47) which would cause confusion when trying to understand it’s intent. This type and its related functions should be renamed to disambiguate it from the incoming `@defer` related types and functions.

`PossiblyDeferred` is an internal type so this should have no adverse effect on users’ code.

## Generated models

Generated models will need to adapt with the introduction of `@defer` statements in operations. Ideally there is easy-to-read annotation indicating something is deferred by simply reading the generated model code but more importantly it must be easy when using the generated models in code to detect whether something is able to be deferred and it's current state when receiving a response.

**Preferred solution (see the end of this document for discarded solutions)**

These are the key changes:

**All deferred fragments including inline fragments are treated as isolated fragments**

This is necessary because they are delivered separately in the incremental response, therefore they cannot be merged together. This means that inline fragments, even on the same typecase with matching arguments, will be treated as separate fragments in the same way that named fragments are. They will be placed into the `Fragments` container along with an accessor.

This is still undecided but we may require that _all_ deferred fragments be named with the `label` argument. This provides us with a naming paradigm and aids us in identifying the fulfilled fragments in the incremental responses. At a minimum any fragments on the same typecase will need to be uniquely identifable with at least one having an associated label.

**Deferred fragment accessors are stored properties**

This is different to data fields which are computed properties that use a subscript on the underlying data dictionary to return the value. We decided to do this so that we can use a property wrapper, which are not available for computed properties. The property wrapper is an easy-to-read annotation on the accessor to aid in identifying a deferred fragment from other named fragments in the fragment container.

It's worth noting though that the fragment accessors are not true stored properties but rather a pseudo stored-property because the property wrapper is still initialized with a data dictionary that holds the data. This is also made possible by the underlying data dictionary having copy-on-write semantics.

**`@Deferred` property wrapper**

Aside from being a conveinent annotation the property wrapper also unlocks both deferred value and state. The wrapped value is used to access the returned value and the projected value is used to determine the state of the fragment in the response, i.e.: pending, fulfilled or a not-executed.

The not-executed case is used to indicate when a merged deferred fragment could never be fulfilled, such as when the response type is different from the deferred fragment typecase.

Here is a snippet of a generated model to illustrate the above three points:
```swift
public struct Fragments: FragmentContainer {
  public let __data: DataDict
  public init(_dataDict: DataDict) {
    __data = _dataDict
    _root = Deferred(_dataDict: _dataDict)
  }

  @Deferred public var deferredFragmentFoo: DeferredFragmentFoo?
}

public struct DeferredFragmentFoo: AnimalKingdomAPI.InlineFragment {
}
```

Below is the expected property wrapper:
```swift
public protocol Deferrable: SelectionSet { }

@propertyWrapper
public struct Deferred<Fragment: Deferrable> {
  public enum State { // the naming of these cases is not final
    case pending
    case notExecuted
    case fulfilled(Fragment)
  }

  public init(_dataDict: DataDict) {
    __data = _dataDict
  }

  public var state: State {
    let fragment = ObjectIdentifier(Fragment.self)
    if __data._fulfilledFragments.contains(fragment) {
      return .fulfilled(Fragment.init(_dataDict: __data))
    }
    else if __data._deferredFragments.contains(fragment) {
      return .pending
    } else {
      return .notExecuted
    }
  }

  private let __data: DataDict
  public var projectedValue: State { state }
  public var wrappedValue: Fragment? {
    guard case let .fulfilled(value) = state else {
      return nil
    }
    return value
  }
}
```

`DataDict`, the underlying data dictionary to data fields will now need to keep track of deferred fragments in a new property, as it does for fulfilled fragments:
```swift
public struct DataDict: Hashable {
  // initializer and other properties not shown

  @inlinable public var _deferredFragments: Set<ObjectIdentifier> {
    _storage.deferredFragments
  }

  // functions not shown
}
```

**A new `deferred(if:type:label:)` case in `Selection`**

This is necessary for the field selection collector to be able to handle both inline and named fragments the same, which is different from the separate case logic that exists for them today.

Here is a snippet of a generated model to illustrate the selection:
```swift
public static var __selections: [ApolloAPI.Selection] { [
  .deferred(if: "a", DeferredFragmentFoo.self, label: "deferredFragmentFoo")
] }
```

**Field merging**

Field merging is a feature in Apollo iOS where fields from fragments that have the same `__parentType` as the enclosing `SelectionSet` are automatically merged into the enclosing `SelectionSet`. This makes it easier to consume fragment fields instead of having to access the fragment first.

Deferred fragment fields will **not** be merged into the enclosing selection set. Merging in the fields of a deferred fragment would require the field types to become optional or use another wrapper-type solution where the field value and state can be represented. We decided it would be better to treat deferred fragments as an isolated selection set with clearer sementics on the collective state and values.

**Selection set initializers**

In the preview release of `@defer`, operations with deferred fragments will **not** be able to have generated selection set initializers. This is due to the complexities of field merging which is dependent on work being done by other members of the team. Once we can support this the fields will be optional properties on the initializer and fragment fulfillment will be determined at access time, in a lightweight version of the GraphQL executor, to determine if all deferred fragment field values were provided.   

## Networking 

### Request header

If an operation can support an incremental delivery response it must add an `Accept` header to the HTTP request specifying the protocol version that can be parsed in the response. An [example](https://github.com/apollographql/apollo-ios/blob/spike/defer/Sources/Apollo/RequestChainNetworkTransport.swift#L115) is HTTP subscription requests that include the `subscriptionSpec=1.0` specification. `@defer` introduces another incremental delivery response protocol. The defer response specification supported at the time of development is `deferSpec=20220824`.

All operations will have an `Accept` header specifying the supported incremental delivery response protocol; Subscription operations will have the `subscriptionSpec` protocol, Query and Mutation operations will have the `deferSpec` protocol in the `Accept` header.

### Response parsing

Apollo iOS already has support for parsing incremental delivery responses. That provides a great foundation to build on however there are some changes needed.

#### Multipart parsing protocol

The current `MultipartResponseParsingInterceptor` implementation is specific to the `subscriptionSpec` version `1.0` specification. Adopting a protocol with implementations for each of the supported specifications will enable us to support any number of incremental delivery specifications in the future.

These would be registered with the `MultipartResponseParsingInterceptor` each with a unique specification string, to be used as a lookup key. When a response is received the specification string is extracted from the response `content-type` header, and the correct specification parser can be used to parse the response data.

```swift
// Sample code in MultipartResponseParsingInterceptor
public struct MultipartResponseParsingInterceptor: ApolloInterceptor {
  private static let responseParsers: [String: MultipartResponseSpecificationParser.Type] = [
    MultipartResponseSubscriptionParser.protocolSpec: MultipartResponseSubscriptionParser.self,
    MultipartResponseDeferParser.protocolSpec: MultipartResponseDeferParser.self,
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
      let protocolParser = Self.responseParsers[protocolSpec],
      let dataString = String(data: response.rawData, encoding: .utf8)
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

    for chunk in dataString.components(separatedBy: "--\(boundary)") {
      if chunk.isEmpty || chunk.isBoundaryMarker { continue }

      parser.parse(chunk: chunk, dataHandler: dataHandler, errorHandler: errorHandler)
    }
  }
}

// Sample protocol for multipart specification parsing
protocol MultipartResponseSpecificationParser {
  static var protocolSpec: String { get }

  static func parse(
    chunk: String,
    dataHandler: ((Data) -> Void),
    errorHandler: ((Error) -> Void)
  )
}

// Sample implementations of multipart specification parsers

struct MultipartResponseSubscriptionParser: MultipartResponseSpecificationParser {
  static let protocolSpec: String = "subscriptionSpec=1.0"

  static func parse(
    chunk: String,
    dataHandler: ((Data) -> Void),
    errorHandler: ((Error) -> Void)
  ) {
    // parsing code currently in MultipartResponseParsingInterceptor
  }
}

struct MultipartResponseDeferParser: MultipartResponseSpecificationParser {
  static let protocolSpec: String = "deferSpec=20220824"

  static func parse(
    chunk: String,
    dataHandler: ((Data) -> Void),
    errorHandler: ((Error) -> Void)
  ) {
    // new code to parse the defer specification
  }
}
```

#### Response data

The initial response data and data received in each incremental response will need to be retained and combined so that each incremental response can insert the latest received incremental response data at the correct path and return an up-to-date response to the request callback.

The data being retained and combined will be passed through the GraphQL executor on each response, initial and incremental.

### Completion handler

`GraphQLResult` should be modified to provide query completion blocks with a high-level abstraction of whether the request has been fulfilled or is still in progress. This prevents clients from having to dig into the deferred fragments to identify the state of the overall request.

**Preferred solution (see the end of this document for discarded solutions)**

Introduce a new property on the `GraphQLResult` type that can be used to express the state of the request.

```swift
// New Response type and property
public struct GraphQLResult<Data: RootSelectionSet> {
  // other properties and types not shown

  public enum Response {
    case partial
    case complete
  }

  public let response: Response
}

// Sample usage in an app completion block
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

## GraphQL execution

The executor currently executes on an entire operation selection set. It will need to be adapted to be able to execute on a partial response when deferred fragments have not been received. Each response will be passed to the GraphQL executor.

There is an oustanding question about whether the Apollo Router has implemented early execution of deferred fragments, potentially returning them in the initial response. If it does then that could have an outsided impact on the changes to the executor. This problem does appear to have been addressed in GraphQL spec edits after `2022-08-24`.

## Caching

Similarly to GraphQL execution the cache write interceptor is designed to work holistically on the operation and write cache records for a single response. This approach still works for HTTP-based subscriptions because each incremental response contains a selection set for the entire operation.

This approach is not going to work for the incremental responses of `@defer` though and partial responses cannot be written to the cache for the operation. Instead all deferred responses will need to be fulfilled before the record is written to the cache.

```swift
// Only write cache records for complete responses
public struct CacheWriteInterceptor: ApolloInterceptor {
  // other code not shown

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

# Discarded solutions

## Update graphql-js dependency
1. Add support for Client Controlled Nullability to `17.0.0-alpha.2`, or the latest 17.0.0 alpha release, and publish that to NPM. The level of effort for this is unknown but it would allow us to maintain support for CCN.
2. Use `17.0.0-alpha.2`, or the latest 17.0.0 alpha release, as-is and remove the experimental Client Controlled Nullability feature. We do not know how many users rely on the CCN functionality so this may be a controversial decision. This path doesn’t necessarily imply an easier dependency update because there will be changes needed to our frontend javascript to adapt to the changes in graphql-js.

## Generated models
1. Property wrappers - I explored Swift's property wrappers but they suffer from the limitation of not being able to be applied to a computed property. All GraphQL fields in the generated models are computed properties because they simply route access to the value in the underlying data dictionary storage. It would be nice to be able to simply annotate fragments and fields with something like `@Deferred` but unfortunately that is not possible.
2. Optional types - this solution would change the deferred property type to an optional version of that type. This may not seem necessary when considering that only fragments can be marked as deferred but it would be required to cater for the way that Apollo iOS does field merging in the generated model fragments. Field merging is non-optional at the moment but there is an issue ([#2560](https://github.com/apollographql/apollo-ios/issues/2560)) that would make this a configuration option. This solution hides detail though because you wouldn't be able to tell whether the field value is `nil` because the response data hasn't been received yet (i.e.: deferred) or whether the data was returned and it was explicitly `null`. It also gets more complicated when a field type is already optional; would that result in a Swift double-optional type? As we learnt with the legacy implementation of GraphQL nullability, double-optionals are difficult to interpret and easily lead to mistakes.
3. `Enum` wrapper - an idea that was suggested by [`@Iron-Ham`](https://github.com/apollographql/apollo-ios/issues/2395#issuecomment-1433628466) is to wrap the type in a Swift enum that can expose the deferred state as well as the underlying value once it has been received. This is an improvement to option 2 where the state of the deferred value can be determined.

```swift
// Sample enum to wrap deferred properties
enum DeferredValue<T> {
    case loading
    case result(Result<T, Error>)
}

// Sample model with a deferred property
public struct ModelSelectionSet: GraphAPI.SelectionSet {
  // other properties not shown

  public var name: DeferredValue<String?> { __data["name"] }
}
```

4. Optional fragments (disabling field merging) - optional types are only needed when fragment fields are merged into entity selection sets. If field merging were disabled automatically for deferred fragments then the solution is simplified and we only need to alter the deferred fragments to be optional. Consuming the result data is intuitive too where a `nil` fragment value would indicate that the fragment data has not yet been received (i.e.: deferred) and when the complete response is received the fragment value is populated and the result sent to the client. This seems a more elegant and ergonimic way to indicate the status of deferred data but complicates the understanding of field merging.

```swift
// Sample usage in a generated model
public class ExampleQuery: GraphQLQuery {
  // other properties and types not shown

  public struct Data: ExampleSchema.SelectionSet {
    public static var __selections: [ApolloAPI.Selection] { [
      .fragment(EntityFragment?.self, deferred: true)
    ] }
  }
}

// Sample usage in an app completion block
client.fetch(query: ExampleQuery()) { result in
  switch (result) {
  case let .success(data):
    client.fetch(query: ExampleQuery()) { result in
      switch (result) {
      case let .success(data):
        guard let fragment = data.data?.item.fragments.entityFragment else {
          // partial result
        }
    
        // complete result
      case let .failure(error):
        print("Query Failure! \(error)")
      }
    }
  case let .failure(error):
  }
}

```

Regardless of the fragment/field solution chosen all deferred fragment definitions in generated models `__selections` will get an additional property to indicate they are deferred. This helps to understand the models when reading them as well as being used by internal code.

```swift
// Updated Selection enum
public enum Selection {
  // other cases not shown
  case fragment(any Fragment.Type, deferred: Bool)
  case inlineFragment(any InlineFragment.Type, deferred: Bool)

  // other properties and types not shown
}

// Sample usage in a generated model
public class ExampleQuery: GraphQLQuery {
  // other properties and types not shown

  public struct Data: ExampleSchema.SelectionSet {
    public static var __selections: [ApolloAPI.Selection] { [
      .fragment(EntityFragment.self, deferred: true),
      .inlineFragment(AsEntity.self, deferred: true),
    ] }
  }
}
```
## Networking

1. Another way which may be a bit more intuitive is to make the `server` case on `Source` have an associated value since `cache` sources will always be complete. The cache could return partial responses for deferred operations but for the initial implementation we will probably only write the cache record once all deferred fragments have been received. This solution becomes invalid though once the cache can return partial responses, with that in mind maybe option 1 is better.

```swift
// Updated server case on Source with associated value of Response type
public struct GraphQLResult<Data: RootSelectionSet> {
  // other properties and types not shown

  public enum Response {
    case partial
    case complete
  }

  public enum Source: Hashable {
    case cache
    case server(_ response: Response)
  }
}

// Sample usage in an app
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
