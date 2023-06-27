* Feature Name: GraphQL `@defer`
* Start Date: 2023-06-26
* RFC PR:

# Summary

The specification for `@defer`/`@stream` is slowly making it's way through the GraphQL Foundation approval process and once formally merged into the GraphQL specification Apollo iOS will need to support it. Apollo already has support for `@defer` in the other OSS offerings, namely Apollo Server, Apollo Client, and Apollo Kotlin.

Based on the progress of `@defer`/`@stream` through the approval process there may be some differences in the final specification vs. what is currently implemented in Apollo's OSS. This project does not attempt to preemptively anticipate those changes and comply with the potential merged specification. The goal of this project is to implement support for `@defer` that matches the other OSS clients. Any client affecting-changes in the merged specification will be implemented into Apollo iOS.

# Proposed Changes

## Update graphql-js dependency

Apollo iOS uses [graphql-js](https://github.com/graphql/graphql-js) for validation of the GraphQL schema and operation documents as the first step in the code generation workflow. The version of this dependency is fixed at [`16.3.0-canary.pr.3510.5099f4491dc2a35a3e4a0270a55e2a228c15f13b`](https://www.npmjs.com/package/graphql/v/16.3.0-canary.pr.3510.5099f4491dc2a35a3e4a0270a55e2a228c15f13b?activeTab=versions). This is a version of graphql-js that supports the [Client Controlled Nullability](https://github.com/graphql/graphql-wg/blob/main/rfcs/ClientControlledNullability.md) feature but does not support the `@defer` directive.

The latest `16.x` release of graphql-js with support for the `@defer` directive is [`16.1.0-experimental-stream-defer.6`](https://www.npmjs.com/package/graphql/v/16.1.0-experimental-stream-defer.6) but it looks like the 'experimental' named releases for `@defer` have been discontinued and the recommendation is to use [`17.0.0-alpha.2`](https://www.npmjs.com/package/graphql/v/17.0.0-alpha.2). This is further validated by the fact that [`16.7.0` does not](https://github.com/graphql/graphql-js/blob/v16.7.0/src/type/directives.ts#L167) include the @defer directive whereas [`17.0.0-alpha.2` does](https://github.com/graphql/graphql-js/blob/v17.0.0-alpha.2/src/type/directives.ts#L159).

There are a few options for updating the graphql-js dependency:
1. Add support for Client Controlled Nullability to `17.0.0-alpha.2` and publish that to NPM. The level of effort for this is unknown but it would allow us to maintain support for CCN.
2. Use `17.0.0-alpha.2` as-is and remove the experimental feature of Client Controlled Nullability. We do not know how many users rely on the CCN functionality so this may be a controversial decision. This path doesn’t necessarily imply an easier dependency update because there will be changes needed to our frontend javascript to adapt to the changes in graphql-js.
3. Another option is a staggered approach where we adopt `17.0.0-alpha.2` limiting the changes to our frontend javascript only and at a later stage bring the CCN changes from [PR `#3510`](https://github.com/graphql/graphql-js/pull/3510) to the `17.x` release path and reintroduce support for CCN to Apollo iOS. This would also require the experiemental CCN feature to be removed, with no committment to when it would be reintroduced.

## Rename PossiblyDeferred types/functions

Adding support for `@defer` brings new meaning of the word 'deferred' to the codebase. There is an enum type named [`PossiblyDeferred`](https://github.com/apollographql/apollo-ios/blob/main/Sources/Apollo/PossiblyDeferred.swift#L47) which would cause confusion when trying to understand it’s intent. This type and its related functions should be renamed to disambiguate it from the incoming `@defer` related types and functions.

`PossiblyDeferred` is an internal type so this should have no adverse effect to users’ code.

## Generated models

_In progress_

## Networking 

### Request header

Operation requests that want an incremental delivery response need to send the version of the protocol specification that they are compliant with. Apollo iOS currently requests incremental delivery responses for HTTP-based subscriptions. `@defer` would introduce another operation feature that would request an incremental delivery response.

At the time of writing the latest `deferSpec` version is `20220824`. This should not be sent with all requests though so operations will need to be identifiable as having deferred fragments to signal inclusion of the request header.

### Response parsing

Apollo iOS already has support for parsing incremental delivery responses. That provides a great foundation to build on however there are some changes needed.

#### Specification

The current `MultipartResponseParsingInterceptor` implementation is specific to the `subscriptionSpec` version `1.0` specification. Adopting a `MultipartResponseSpecification` protocol that states the specification and version will enable us to support any number of incremental delivery specifications in the future. These will be registered with the `MultipartResponseParsingInterceptor` and when a response is received the correct specification parser will be used.

#### Data

The initial response data and data received in each incremental response will need to be retained and combined so that each incremental response can insert the latest received incremental response data at the correct path and return an up-to-date response to the request callback.

The data being retained and augmented should not require another pass through the GraphQL executor though.

## GraphQL execution

The executor currently executes on an entire operation selection set. It will need to be adapted to be able to execute on an isolated fragment selection set so that incremental responses can be parsed in isolation instead of needing to execute on the whole operation’s selection set.

## Caching

Similarly to GraphQL execution the cache write interceptor is designed to work holistically on the operation and write cache records for a single response. This currently works in HTTP-based subscriptions because each incremental response is a selection set for the entire operation.

Resolve cache key info on each incremental payload to gather the key required for the incremental data update to the cache record.
