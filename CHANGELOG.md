# Change log

## v0.51.0
- **Allow periods in arguments to be ignored when parsing cacheKeys**: If your query arguments include periods they will no longer cause broken cache keys. This means the cached data for those queries can be correctly found and returned. The caveat with this change though is that if you use a persisted cache, after the upgrade you could see cache misses the data would need to be refetched. [#2057](https://github.com/apollographql/apollo-ios/pull/2057) - _Thanks to [Hesham Salman](https://github.com/Iron-Ham) for the contribution!_

## v0.50.0
- **Dropped SPM support for Swift 5.2**: The minimum version of the Swift tools and language compatibilty required to process the SPM manifest is Swift 5.3. This means a minimum of Xcode version 12 is required for Swift Package Manager support. [#1992](https://github.com/apollographql/apollo-ios/pull/1992)
- **Removed unnecessary assertion failure**: The completion handler on `returnResultAsyncIfNeeded` is defined as optional but if not included would cause debug builds to crash with an `assertionFailure` in the case of a `failure` of the `Result`. [#2005](https://github.com/apollographql/apollo-ios/pull/2005) - _Thank you to [Richard Topchii](https://github.com/richardtop) for raising this issue!_
- **`CachePolicy.default` is now a stored property**: It is now easier to configure a different default value for the `CachePolicy` property on any `ApolloClient` instance instead of having to override it in a subclass. [#1998](https://github.com/apollographql/apollo-ios/pull/1998) - _Thank you to [Tiziano Coroneo](https://github.com/TizianoCoroneo) for the contribution!_
- **Exposed `cacheKey` function as `public`**: The access modifier of this function on `GraphQLField` has changed from `internal` to `public`. It is not recommended to rely on internal behaviour of the cache, and this is subject to change in future major versions. [#2014](https://github.com/apollographql/apollo-ios/pull/2014) - _Thank you to [Peter Potrebic](https://github.com/potrebic) for the discussion!_
- **GET method support for `ApolloSchemaDownloader`**: Introspection-based schema downloads can now be queried using a GET request. [#2010](https://github.com/apollographql/apollo-ios/pull/2010) - _Thank you to [Mike Pitre](https://github.com/mikepitre) for the contribution!_
- **Updated to version 2.33.9 of the Apollo CLI**: This update will add `__typename` fields to inline fragments in operations to match the output from the `client:push` CLI command which used for operation safelisting. This should not affect the behaviour of your operations. [#2028](https://github.com/apollographql/apollo-ios/pull/2028).
- **Updated to version 0.13.1 of SQLite.swift**: This update brings in some iOS 14 fixes and new table functionality such as `upsert` and `insertMany`.  [#2015](https://github.com/apollographql/apollo-ios/pull/2015) - _Thank you to [Hesham Salman](https://github.com/Iron-Ham) for the contribution._

## v0.49.1
- **`ApolloSchemaDownloadConfiguration.HTTPHeader` initializer was not public**: The struct initializer that Swift automatically generates is marked with the `internal` access level, which meant that custom HTTP headers could not be added to an instance of `ApolloSchemaDownloadConfiguration`. [#1962](https://github.com/apollographql/apollo-ios/pull/1962) - _Thank you to [Nikolai Sivertsen](https://github.com/nsivertsen) for the contribution!_
- **Documentation update**: Fixed an inline code block that had specified language where such specification is not supported. [#1954](https://github.com/apollographql/apollo-ios/pull/1954) - _Thank you to [Kim Røen](https://github.com/kimroen) for the contribution!_
- **Fix - ApolloCodegenOptions could not find schema input file**: - If you created `ApolloSchemaDownloadConfiguration` and `ApolloCodegenOptions` objects using only output folders the default output filename for the schema download was different from the default schema input filename for codegen. [#1968](https://github.com/apollographql/apollo-ios/pull/1968) - _Thank you to [Arnaud Coomans](https://github.com/acoomans) for finding this issue!_

## v0.49.0
- **Breaking - Schema download is now Swift-based:** The dependency on the Apollo CLI (Typescript-based) for schema downloading has been removed. Schema downloading is now Swift-based, outputs GraphQL SDL (Schema Definition Language) by default, and is maintainable/extensible within apollo-ios with full [API documentation](https://www.apollographql.com/docs/ios/api/ApolloCodegenLib/structs/ApolloSchemaDownloader/). This is a breaking change because some of the API signatures have changed. [Swift scripting](https://www.apollographql.com/docs/ios/swift-scripting/) offers a convenient way to perform certain operations that would otherwise require the command line - it's worth a look if you haven't tried it yet. [#1935](https://github.com/apollographql/apollo-ios/pull/1935)

## v0.48.0
- **Customizable subscription message identifiers:** The `WebSocketTransport` initializer can be configured with a subclass of `OperationMessageIdCreator` to provide a unique identifier per request. The default implementation is `ApolloSequencedOperationMessageIdCreator` and retains the current behavior of sequential message numbering. [#1919](https://github.com/apollographql/apollo-ios/pull/1919) - _Thank you to [Clark McNally](https://github.com/cmcnally-beachbody) for the contribution!_
- **AWS AppSync Compatibility:** Apollo-ios will now correctly handle the `start_ack` message that AWS AppSync servers respond with when a subscription is requested. [#1919](https://github.com/apollographql/apollo-ios/pull/1919) - _Thank you to [Clark McNally](https://github.com/cmcnally-beachbody) for the contribution!_
- **Updated to version 2.33.6 of the Apollo CLI:** Applies some new vulnerability patches to the CLI, but should not change any output. [#1929](https://github.com/apollographql/apollo-ios/pull/1929)
- **Improved documentation:** Clarification of cache normalization concepts. [#1710](https://github.com/apollographql/apollo-ios/pull/1710) - _Thank you to [Daniel Morgan](https://github.com/morgz) for the contribution!_

## v0.47.1
- **Fixed - Websocket default implementation not included in `ApolloWebSocket` via Cocoapods:** _Thank you to [ketenshi](https://github.com/ketenshi) for the contribution!_

## v0.47.0
- **Breaking - Removed Starscream dependency:** Due to dependency management conflicts it has become easier for us to maintain our WebSockets as part of the `ApolloWebSockets` target instead of an external dependency on a forked version of Starscream. [#1906](https://github.com/apollographql/apollo-ios/pull/1906)
  - Removed Starscream as an external dependency in Cocoapods and Swift Package Manager.
  - The `DefaultWebSocket` implementation has been replaced with `WebSocket`.
- **Fixed - `clearCache` not using the provided callback queue:** `ApolloClient` was not passing the provided callback queue to `ApolloStore` and therefore the completion block for `clearCache` was being called on the main queue. [#1904](https://github.com/apollographql/apollo-ios/pull/1904), [#1901](https://github.com/apollographql/apollo-ios/pull/1901) - _Thank you to [Isaac Ressler](https://github.com/isaacressler) for the contribution!_
- **Removed - Swift playground:** The playground has been moved to a [separate repository](https://github.com/apollographql/apollo-client-swift-playground). [#1905](https://github.com/apollographql/apollo-ios/pull/1905)

## v0.46.0
- **Removed - Swift experimental codegen:** The [experimental Swift code generation](https://github.com/apollographql/apollo-ios/blob/0.45.0/Sources/ApolloCodegenLib/ApolloCodegenOptions.swift#L21) has been removed from `main` and will instead become available in the [`release/1.0-alpha-incubating` branch](https://github.com/apollographql/apollo-ios/tree/release/1.0-alpha-incubating) until a 1.0 release. [#1873](https://github.com/apollographql/apollo-ios/pull/1873)
- **Fixed - [Query watcher not being called when the cache is updated on an element by another query/subscrition/mutation](https://github.com/apollographql/apollo-ios/issues/1422):** The long-term solution is to integrate web sockets into the request chain but this is an interim fix that allows `WebSocketTransport` to be configured with a store to update the cache when receiving data. This should not break any workarounds others have already implemented. [#1889](https://github.com/apollographql/apollo-ios/pull/1889), [#1892](https://github.com/apollographql/apollo-ios/pull/1892) - _Thank you to [tgyhlsb](https://github.com/tgyhlsb) for the contribution!_

## v0.45.0
- **Breaking - Downgraded from Starscream v4 to v3!** After upgrading to Starscream 4.0, a lot of our users started to experience crashes while using web sockets. We've decided to revert to the more stable Starscream version 3. In order to fix a few known bugs in Starscream 3, we have made a fork of Starscream that Apollo will depend on going forward. In preparation for moving to Apple WebSockets in the future, we have also fully inverted the dependency on Starscream. Between these two changes, a lot of breaking changes to our Web Socket API have been made:
  - The `ApolloWebSocketClient` protocol was removed and replaced with `WebSocketClient`.
  - `WebSocketClient` does not rely directly on Starscream anymore and has been streamlined for easier conformance.
  - `ApolloWebSocket`, the default implementation of the `WebSocketClient` has been replaced with `DefaultWebSocket`. This implementation uses Starscream, but implementations using other websocket libraries can now be created and used with no need for Starscream.
  - `WebSocketClientDelegate` replaces direct dependency on `Starscream.WebSocketDelegate` for delegates.
- **Breaking:** Renamed some of the request chain interceptors object:
  - `LegacyInterceptorProvider` -> `DefaultInterceptorProvider`
  - `LegacyCacheReadInterceptor` -> `CacheReadInterceptor`
  - `LegacyCacheWriteInterceptor` -> `CacheWriteInterceptor`
  - `LegacyParsingInterceptor` -> `JSONResponseParsingInterceptor`
- **Breaking:** `WebSocketTransport` is now initialized with an `ApolloWebSocket` (or other object conforming to the `ApolloWebSocketClient` protocol.) Previously, the initializer took in the necessary parameters to create the web socket internally. This provides better dependency injection capabilities and makes testing easier.
- Removed class constraint on `ApolloInterceptor` and converted to structs for all interceptors that could be structs instead of classes.
- Added `removeRecords(matching pattern: CacheKey)` function to the normalized cache.

## v0.44.0

- **BREAKING**: Split `ApolloCore` into two more granular libraries, `ApolloAPI` (which will contain the parts necessary to compile generated code) and `ApolloUtils` (which will contain code shared between `Apollo` and `ApolloCodegenLib`). If you were previously importing `ApolloCore`, in most places you will need to import `ApolloUtils`. If you're using Carthage, you will need to remove the old `ApolloCore` xcframework and replace it with the two `ApolloAPI` and `ApolloUtils` frameworks. ([#1817](https://github.com/apollographql/apollo-ios/pull/1817))
- Fixed a stray CocoaPods warning. ([#1769](https://github.com/apollographql/apollo-ios/pull/1769))
- Updated the Typescript CLI to version 2.32.13. ([#1773](https://github.com/apollographql/apollo-ios/pull/1773)) 
- Added the ability to specify a `cachePolicy` when calling `refresh` on a `GraphQLWatcher`. ([#1802](https://github.com/apollographql/apollo-ios/pull/1802))

## v0.43.0
- **BREAKING** (or hopefully, fixing): We removed our test libraries from our `Package.swift` file since we're not using it to run tests directly at this time. This prevents SPM from trying to resolve test dependencies that are not actually used in the library, which should reduce any version conflicts. However, if you were using any of our test libs in an unsupported fashion, these will no longer be directly available. ([#1745](https://github.com/apollographql/apollo-ios/pull/1745))
- Fixed an issue where when `Starscream` returned multiple errors in close succession, an exponential number of web socket reconnections could be created. ([#1762](https://github.com/apollographql/apollo-ios/pull/1762))
- Updated `class` constraints to `AnyObject` constraints, which should silence a few warnings in 12.5 and be more forward compatible. ([#1733](https://github.com/apollographql/apollo-ios/pull/1733))
- Added the ability to specify a callback queue for the result handler of `GraphQLWatcher`. ([#1723](https://github.com/apollographql/apollo-ios/pull/1723))
- Fixed a crash when closing a web socket connection and re-opening it immediately. ([#1740](https://github.com/apollographql/apollo-ios/pull/1740))
- You can now skip auto-reconnection for updating the header values and connecting payload in `ApolloWebSocket`. ([#1759](https://github.com/apollographql/apollo-ios/pull/1759))
- Now avoids the `?` when generating a `GET` URL if `queryItems` is empty. ([#1729](https://github.com/apollographql/apollo-ios/pull/1729))
- Updated use of the `default` fetch policy to include fetch and watch. Note that under the hood, this does not change what fetch policy was pointed to at this time, it just centralizes the logic. ([#1737](https://github.com/apollographql/apollo-ios/pull/1737))

## v0.42.0
- **BREAKING**: Finally updates our `Starscream` dependency to 4.0.x. Note that due to SOCKS proxy support being removed from `Starscream`, we've correspondeingly removed such support.([#1659](https://github.com/apollographql/apollo-ios/pull/1659))
- **BREAKING**, but only to Swift Scripting: Updated `ApolloSchemaOptions` to more clearly handle introspection (ie, from a URL) vs registry (ie, from Apollo Studio) requests by using an enum. If you were passing in an `endpointURL` previously, you need to use the `.introspection` enum value going forward. Also changed the name of the field to match the new type. ([#1691](https://github.com/apollographql/apollo-ios/pull/1691))
- **BREAKING**: Removed `CoadableParsingInterceptor` and related code designed for new codegen (which is still in progress) since we were wildly over-optimistic on how quickly we'd be using it. ([#1670](https://github.com/apollographql/apollo-ios/pull/1670))
- Fixed an issue where tasks that were in the `canceling` state could trigger a `No data found for task` assertion failure. ([#1677](https://github.com/apollographql/apollo-ios/pull/1677))
- Fixed an issue with encoding `+` in `GET` requests. ([#1653](https://github.com/apollographql/apollo-ios/pull/1653))
- Fixed an issue where creating `GET` requests removed existing query params from the URL. ([#1687](https://github.com/apollographql/apollo-ios/pull/1687))
- Prevented a retain cycle during web socket reconnection. ([#1674](https://github.com/apollographql/apollo-ios/pull/1674))
- Added better handling for calling `cancel` on a `RequestChain` which has already been cancelled. ([#1679](https://github.com/apollographql/apollo-ios/pull/1679))

## v0.41.0
- **BREAKING**: Fixed an issue in which `UploadRequests` were not getting headers added via the `RequestChainNetworkTransport`'s `additionalHeaders`. Please note that if you've subclassed the RCNT, you'll need to update your overrides since we had to add a parameter. ([#1644](https://github.com/apollographql/apollo-ios/pull/1644))
- Stopped `GET` requests from sending a `Content-Type` header, which could cause servers not configured to ignore that header when the body is empty to freak out. ([#1649](https://github.com/apollographql/apollo-ios/pull/1649))

## v0.40.0
- **BREAKING**: Dropped support for iOS/tvOS < 12, watchOS < 5, and macOS < 10.14. This also involved removing a couple of public functions that were workarounds for support for lower versions. ([#1605](https://github.com/apollographql/apollo-ios/pull/1605))
- Updated the typescript CLI to version `2.32.1`. There may be some structural changes to generated code but it should not actually break anything. Please file bugs immediately if it does. ([#1618](https://github.com/apollographql/apollo-ios/pull/1618))

## v0.39.0

- **POSSIBLY BREAKING**: Updated `swift-tools` version to 5.3, and added a fallback version of `Package.swift` for 5.2. ([#1584](https://github.com/apollographql/apollo-ios/pull/1584))
- **BREAKING**, technically: Switched `cachePolicy` to a `var` on `HTTPRequest`. This makes it possible for retries to use a different cache policy, such as when an error has occurred at the network level and you want to fall back to showing what's in the cache without retrying the network call. ([#1569](https://github.com/apollographql/apollo-ios/pull/1569))
- Added validation in Swift Codegen wrapper that a URL passed in for `singleFile` code generation is a `.swift` file and a URL passed in for `multipleFiles` code generation is a folder. ([#1580](https://github.com/apollographql/apollo-ios/pull/1580))

## v0.38.3
- Fixes an issue that could cause callbacks to fail if a `retry` was performed in an `additionalErrorInterceptor`. ([#1563](https://github.com/apollographql/apollo-ios/pull/1563))

## v0.38.2

- Updates a dependency used for Experimental Swift Codegen to use a version to fix an issue with resolution failures 

## v0.38.1

- Updates `apollo-tooling` version to include a bugfix there. ([#1554](https://github.com/apollographql/apollo-ios/pull/1554))

## v0.38.0

- **BREAKING**: We've made some significant (~4x) performance improvements to the cache and eliminated _all_ our known Thread Sanitizer issues by removing some overly agressive multithreading and our internal Promises implementation. ([#1531](https://github.com/apollographql/apollo-ios/pull/1531)) Related Changes: 
    - **POSSIBLY BREAKING**: These improvements caused changes in our `NormalizedCache` and `ApolloClientProtocol` protocols, so if you're implementing these yourself, you'll need to update. 
    - **BREAKING**: Removed the `loadRecords(forKeys:)` method on `ReadTransaction`. We'd recommended that you use either `read` or `readObject` with the transaction, but if you were using `loadRecords`, you will need to shift to those other methds.
    - **NEW**: `ApolloStore`'s `load(query:resultHandler:)` method now also takes an optional callback queue. 
- **NEW**: Added the ability to say whether the results from a mutation should be published to the store are not. This is a boolean value which defeaults to `true`, to match existing behavior. ([#1521](https://github.com/apollographql/apollo-ios/pull/1521))
- **BREAKING**: The setter for `Atomic`'s `value` is no longer public to prevent accidental misuse. If you were using this, use the `mutate` method instead to ensure the thread lock works properly. ([#1538](https://github.com/apollographql/apollo-ios/pull/1538))

## v0.37.0

- **POSSIBLY BREAKING**: Updated behavior of `URLSessionClient` when it's been invalidated to throw an error instead of crashing. If you were relying on this failing loudly before, please be aware it's going to fail a lot more quietly now. ([#1489](https://github.com/apollographql/apollo-ios/pull/1489))
- Improved performance of `loadRecords` for the SQLite cache. ([#1519](https://github.com/apollographql/apollo-ios/pull/1519))
- Added support for use of `Apollo` as a dynamic lib. ([#1483](https://github.com/apollographql/apollo-ios/pull/1483))
- Updated the legacy CLI to `2.31.0`. ([#1510](https://github.com/apollographql/apollo-ios/pull/1510))
- Fixed some bugs in our `JSONSerialization` handling. ([#1478](https://github.com/apollographql/apollo-ios/pull/1478))
- Fixed an issue with callback queue handling for websockets. ([#1507](https://github.com/apollographql/apollo-ios/pull/1507))
- Fixed an issue with callback queue handling for errors. ([#1468](https://github.com/apollographql/apollo-ios/pull/1468))
- Removed a redundant `nil` check while clearing the cache. ([#1508](https://github.com/apollographql/apollo-ios/pull/1508))

## v0.36.0
- **POSSIBLY BREAKING**: We removed some default parameters for the `ApolloStore` from `ApolloClient` and `LegacyInterceptorProvider` to prevent an issue where developers could accidentally create these objects with different caches. ([#1461](https://github.com/apollographql/apollo-ios/pull/1461))
- Added a new parameter to allow the option to not automatically connect a websocket on initialization. ([#1458](https://github.com/apollographql/apollo-ios/pull/1458))

## v0.35.0
- **BREAKING**: Removed the now-unused-in-the-SDK `GraphQLHTTPResponseError` type. If you were relying on this class, please copy it out of v0.34.1. ([#1437](https://github.com/apollographql/apollo-ios/pull/1437))
- **BREAKING**: Removed default parameters from `RequestBodyCreator`'s default implementation to fix an issue where when default parameters were passed, the compiler would always select the default implementation even if a full alternate implementation was provided. ([#1450](https://github.com/apollographql/apollo-ios/pull/1450))
- Removed unnecessary manual task clearing when invalidating a URLSession. ([#1443](https://github.com/apollographql/apollo-ios/pull/1443))

## v0.34.1

- Fixes an issue that would cause headers to get lost when sending with `useGETForQueries`. ([#1420](https://github.com/apollographql/apollo-ios/pull/1420))

## v0.34.0

- **SPECTACULARLY BREAKING**: As noted in the Beta release notes below, the networking stack for HTTP requests has been completely rewritten. This is described in great detail in the [RFC for the networking changes](https://github.com/apollographql/apollo-ios/issues/1340), as well as the [updated documentation for Advanced Client Creation](https://www.apollographql.com/docs/ios/initialization/#advanced-client-creation) and the [updated tutorial section on setting up authentication](https://www.apollographql.com/docs/ios/tutorial/tutorial-mutations/). Thank you all for the excellent feedback and looking forward to hearing about the cool stuff you're able to build with this! ([#1386](https://github.com/apollographql/apollo-ios/pull/1386)) 
- **REMINDER**: If you're using Carthage with Xcode 12, please make sure you're using the workaround script as outlined in the [release notes for `0.33.0`](#v0330).

## v0.34.0-rc.2

Networking Stack, Release Candidate

- Made `RequestChainNetworkTransport` subclassable and changed two methods to be `open` so they can be subclassed in order to facilitate using subclasses of `HTTPRequest` when needed. ([#1405](https://github.com/apollographql/apollo-ios/pull/1405))
- Made numerous improvements to creating upload requests - all upload request setup is now happening through the `UploadRequest` class, which is now `open` for your subclassing funtimes. ([#1405](https://github.com/apollographql/apollo-ios/pull/1405))
- Renamed `RequestCreator` to `RequestBodyCreator` to more accurately reflect what it's doing (particularly in light of the fact that we didn't have a `Request` in the old networking stack, and now we do), and renamed associated properties and parameters. ([#1405](https://github.com/apollographql/apollo-ios/pull/1405))

## v0.34.0-rc.1

Networking Stack, Release Candidate

- Added some final tweaks: 
    - Updated `ApolloStore` to take a default cache of the `InMemoryNormalizedCache`.
    - Updated LegacyInterceptorProvider to take a default store of the `ApolloStore` with that default cache.
    - Added a method to `InterceptorProvider` to provide an error interceptor, along with a default implementation that returns `nil`.
    - Updated `JSONRequest` to be open so it can be subclassed.

    This is now at the point where if there are no further major bugs, I'd like to release this - get your bugs in ASAP! ([#1399](https://github.com/apollographql/apollo-ios/pull/1399)

## v0.34.0-beta2

Networking Stack, Beta 2

- Merges `0.33.0` changes into the networking stack for Swift 5.3 and Xcode 12.

## v0.33.0
- Adds support for Xcode 12 and Swift 5.3. ([#1280](https://github.com/apollographql/apollo-ios/pull/1280))
- Adds workaround script for Carthage support in Xcode 12. Please see [Carthage-3019](https://github.com/Carthage/Carthage/issues/3019) for details. TL;DR: cd into `[YourProject]/Carthage/Checkouts/apollo-ios/scripts` and then run `./carthage-build-workaround.sh` to actually get Carthage builds that work. (#yolo committed to `main`)

### 0.33.0-beta1

Networking Stack, Beta 1

- **SPECTACULARLY BREAKING**: The networking stack for HTTP requests has been completely rewritten. This is described in great detail in the [RFC for the networking changes](https://github.com/apollographql/apollo-ios/issues/1340), as well as the [updated documentation for Advanced Client Creation](https://deploy-preview-1386--apollo-ios-docs.netlify.app/docs/ios/initialization/#advanced-client-creation). Please, please, please file bugs or requests for clarification of the docs as soon as possible. Note that all changes until the networking stack comes out of beta will live on the `betas/networking-stack` branch. ([#1341](https://github.com/apollographql/apollo-ios/issues/1341))

## v0.32.1
- Improves invalidation of a `URLSesionClient` to include cancellation of in-flight operations. ([#1376](https://github.com/apollographql/apollo-ios/issues/1376))

## v0.32.0
- Fixes an issue that would occur when a GraphQL query watcher's dependent keys would not get updated. ([#1375](https://github.com/apollographql/apollo-ios/issues/1375))
- Adds an `extensions` dictionary property to `GraphQLResult`. ([#1370](https://github.com/apollographql/apollo-ios/pull/1370))
- Makes a couple of response parsing helpers public for advanced use cases. ([#1372](https://github.com/apollographql/apollo-ios/pull/1372))

## v0.31.0
- Adds the ability to pause and resume a WebSocket connection without dumping existing subscriptions. ([#1335](https://github.com/apollographql/apollo-ios/pull/1335)) 
- Adds an initializer to `SQLiteNormalizedCache` that takes a `SQLite.swift` `DatabaseConnection` to more easily allow setup of pre-configured connections. ([#1330](https://github.com/apollographql/apollo-ios/pull/1330))
- Addresses a retain cycle that could cause memory leaks when using multiple instances of `HTTPNetworkTransport`.

    **NOTE:** If you're using `URLSessionClient` outside the context of `HTTPNetworkTransport`, make sure to call `invalidate()` on it when whatever is holding onto it hits `deinit()` to prevent leaks. ([#1366](https://github.com/apollographql/apollo-ios/pull/1366))

## v0.30.0
- **BREAKING**: Updates the CLI to `2.30.1` to fix a long-standing issue where when generating operation IDs and their related JSON file, the correct operations + fragments would be used in generating the operation ID, but not output with the JSON file. This will slightly change the output in `API.swift`, but it also means we can remove a related workaround from the iOS SDK. ([#1316](https://github.com/apollographql/apollo-ios/pull/1316))
- **BREAKING**: Removed the `Cartfile` which declared our dependencies, since we're now internally managing them with SPM, and newer versions of Carthage just use the SPM dependencies. Note that this can cause issues if you need to use a fork of dependencies, or if you're using an older version of Carthage. ([#1311](https://github.com/apollographql/apollo-ios/pull/1311))
- **POSSIBLY BREAKING**: Works around an issue that could cause some attempts to store untyped JSON dictionaries to throw unexpected errors about optional encoding. This also added handling of creating a dictionary from a `JSONValue`, which may cause problems if you've already implemented this yourself, but which should mostly just replace the need to implement it yourself. Please file issues ASAP if you run into problems here. ([#1317](https://github.com/apollographql/apollo-ios/pull/1317))
- Works around an issue causing some attempts to store arrays of JSON dictionaries to have arbitrary key ordering. ([#1281](https://github.com/apollographql/apollo-ios/pull/1281))
- Adds clearer error descriptions to a few errors. ([#1295](https://github.com/apollographql/apollo-ios/pull/1295))

## v0.29.1
- Updates the CLI to `2.28.3` to fix an issue where linter failures would cause a silent failure exit. ([#1284](https://github.com/apollographql/apollo-ios/pull/1284), #1288](https://github.com/apollographql/apollo-ios/pull/1288))
- Adds a check to swift scripting that the downloaded file has the correct SHASUM, otherwise forcing redownload. ([#1288](https://github.com/apollographql/apollo-ios/pull/1288))

## v0.29.0

- **NEW**: Swift scripting is officially out of Beta! Please check out [our updated guide to integration](https://www.apollographql.com/docs/ios/swift-scripting/). The tutorial should be updated to recommend using Swift Scripting within the next week or so. NOTE: The shell script is not deprecated yet, but will be shortly. ([#1263](https://github.com/apollographql/apollo-ios/pull/1263))
- **BREAKING**: Found some workarounds to conditional conformance and updated all extensions to use the `apollo.extensionMethod` syntax introduced in `0.28.0`. ([#1256](https://github.com/apollographql/apollo-ios/pull/1256))
- **BREAKING**: Moved a few things into the new `ApolloCore` library. For CocoaPods and SPM users, this should be automatically picked up by your package manager. **Carthage users, you will need to drag the new `ApolloCore` library into  your project manually** as you have with the other Apollo libs. ([https://github.com/apollographql/apollo-ios/pull/1256](https://github.com/apollographql/apollo-ios/pull/1256))
- **BREAKING**: Updated to version `2.28.0` of the Apollo JS CLI. This includes moving a bunch of `static let` allocations to computed `static var`s to prevent memory overuse. ([#1246](https://github.com/apollographql/apollo-ios/pull/1246))
- Made `GraphQLGetTransformer` and its methods public and made a couple more methods on `MultipartFormData` public. ([#1273](https://github.com/apollographql/apollo-ios/pull/1273))
- Fixes an issue when uploading multiple files for different variables. ([#1279](https://github.com/apollographql/apollo-ios/pull/1279), special thanks to [#1081](https://github.com/apollographql/apollo-ios/pull/1081))
- Fixes a crash when encoding `GraphQLVariable` objects which conform to `JSONEncodable`. ([#1262](https://github.com/apollographql/apollo-ios/pull/1262))

## v0.28.0
- **BREAKING**: Changed a few things in the `ApolloCodegen` library to use `object.apollo.extensionMethod` syntax rather than `object.apollo_extensionMethod`. There's a few things that are still using `apollo_` notation due to constraints around conditional conformance, but you should particularly check your swift scripts for changes around `FileManager` APIs. ([#1183](https://github.com/apollographql/apollo-ios/pull/1183))
- **BREAKING**: `NormalizedCache` now has a method for explicitly clearing the cache synchronously, in addition to the existing method to clear it asynchronously. If you've got a custom `NormalizedCache` implementation, you'll need to add an implementation for this method. ([#1186](https://github.com/apollographql/apollo-ios/pull/1186))
- Fixed race conditions in `URLSessionClient` that were causing unexpected behavior. Turns out concurrency is hard! ([#1227](https://github.com/apollographql/apollo-ios/pull/1227))
- Improved handling of a dependent key update cancelling an in-flight server fetch on a watcher. ([#1156](https://github.com/apollographql/apollo-ios/pull/1156))
- Added option to Swift Codegen to pass in a prefix for custom scalars. ([#1216](https://github.com/apollographql/apollo-ios/pull/1216))
- Added ability to change a header on a websocket connection and automatically reconnect. ([#1224](https://github.com/apollographql/apollo-ios/pull/1224))

## v0.27.1
- Better defense against multithreading crashes in `URLSessionClient`. ([#1184](https://github.com/apollographql/apollo-ios/pull/1184))
- Fix for watchOS availability for `URLSessionClient`. ([#1175](https://github.com/apollographql/apollo-ios/pull/1175))

## v0.27.0
- **BREAKING**: Replaced calls directly into the closure based implementation of `URLSession` with a delegate-based implementation called `URLSessionClient`. 
    - This (finally) allows background session configurations to be used with `ApolloClient`, since background session configurations immediately error out if you try to use the closure-based `URLSession` API. 
    - **This makes a significant change to the initialization of `HTTPNetworkTransport` if you're using a custom `URLSession`**: Because `URLSession` must have its delegate set at the point of creation, `URLSessionClient` is now creating the URL session. You can initialize a `URLSessionClient` with a `URLSessionConfiguration`. if before you were using:

        ```swift
        let session = URLSession(configuration: myCustomConfiguration)
        let url = URL(string: "http://localhost:8080/graphql")!
        let transport = HTTPNetworkTransport(url: url,
                                             session: session)
        ```
        
        You will now need to use: 
        
        ```swift
        let client = URLSessionClient(sessionConfiguration: myCustomConfiguration)
        let url = URL(string: "http://localhost:8080/graphql")!
        let transport = HTTPNetworkTransport(url: url,
                                             client: client)
        ```
        
    - If you were passing in a session you'd already set yourself up to be the delegate of to handle GraphQL requests, you'll need to subclass `URLSessionClient`  and override any delegate methods off of `URLSessionDelegate`, `URLSessionTaskDelegate`, or `URLSessionDataDelegate` you need to handle. Unfortunately only one class can be a delegate at a time, and that class must be declared when the session is instantiated. 

        Note that if you don't need your existing delegate-based session to do any handling for things touched by Apollo, you can keep it completely separate if you'd prefer.
    - This does *not* change anything at the point of calls - everything is still closure-based in the end
   
      Please file bugs on this ASAP if you run into problems. Thank you! ([#1163](https://github.com/apollographql/apollo-ios/pull/1163))


## v0.26.0
- **BREAKING**, though in a good way: Updated the typescript CLI to [2.27.2](https://github.com/apollographql/apollo-tooling/releases/tag/apollo%402.27.2), and updated the script to pull from a CDN (currently backed by GitHub Releases) rather than old Circle images. This should significantly increase download performance and stability. ([#1166](https://github.com/apollographql/apollo-ios/pull/1166))
- **BREAKING**: Updated the retry delegate to allow more fine-grained control of what error to return if an operation fails in the process of retrying. ([#1128](https://github.com/apollographql/apollo-ios/pull/1128), [#1167](https://github.com/apollographql/apollo-ios/pull/1167))
- Added support to the Swift scripting package to be able to use multiple headers when downloading a schema. ([#1153](https://github.com/apollographql/apollo-ios/pull/1153))
- Added the ability to set the SSL trust validator on a websocket. ([#1124](https://github.com/apollographql/apollo-ios/pull/1124))
- Fixed an issue deserializing custom scalars in `ApolloSQLite`. ([#1144](https://github.com/apollographql/apollo-ios/pull/1144))

## v0.25.1

- Repoints download link to our CDN for the CLI for people on 0.25.0 who can't upgrade to 0.26.0 or higher immediately.

## v0.25.0
- **BREAKING**: Updated the `swift-tools` version to 5.2 in `Package.swift`. Note that if you're using `swift-tools` 5.2, you'll need to update the syntax of your `Package.swift` file and specify the name of the library manually for Apollo. ([#1099](https://github.com/apollographql/apollo-ios/pull/1099), [#1106](https://github.com/apollographql/apollo-ios/pull/1106))
- **POSSIBLY BREAKING**: Upgraded the typescript CLI to [2.26.0](https://github.com/apollographql/apollo-tooling/releases/tag/apollo%402.26.0). No changes were found in test frameworks, but this could theoretically break some stuff. ([#1107](https://github.com/apollographql/apollo-ios/pull/1107), [#1113](https://github.com/apollographql/apollo-ios/pull/1113))
- **NEW**: Added the ability to set Starscream's underlying `enableSOCKSProxy` to better allow debugging web sockets in tools like Charles Proxy. ([#1108](https://github.com/apollographql/apollo-ios/pull/1108))
- Fixed several issues using paths with spaces in the Swift Codegen. ([#1092](https://github.com/apollographql/apollo-ios/pull/1092), [#1097](https://github.com/apollographql/apollo-ios/pull/1097)). 
- `ApolloCodegenLib` is now properly passing the `header` argument last when downloading a schema. ([#1096](https://github.com/apollographql/apollo-ios/pull/1096))
- Automatic Persisted Queries now also work with mutations. ([#1110](https://github.com/apollographql/apollo-ios/pull/1110))

## v0.24.1
- Repoints download link to our CDN for the CLI for people on 0.24.0 who can't upgrade to 0.26.0 or higher immediately.

## v0.24.0
- **BREAKING**: Updated `GraphQLResponse` to be generic over the response type rather than the operation type. This will allow more flexibility for generic modifications to methods that need to use `GraphQLResponse`. ([#1061](https://github.com/apollographql/apollo-ios/pull/1061))
- **BREAKING**: Updated the file URL-based initializer of `GraphQL` to throw with a clear error instead of failing silently. Removed the ability to pass in an input stream since that can't be recreated on a failure. Updated initializers take either raw `Data` or a file URL so that the input stream can be recreated on a retry. ([#1086](https://github.com/apollographql/apollo-ios/pull/1086), [#1089](https://github.com/apollographql/apollo-ios/pull/1089))
- In the Swift Package Manager based codegen, made sure that the folder the CLI will be downloaded to is created if it doesn't exist. ([#1069](https://github.com/apollographql/apollo-ios/pull/1069))

## v0.23.3
- Repoints download link to our CDN for the CLI for people on 0.23.x who can't upgrade to 0.26.0 or higher immediately.

## v0.23.2
- Changed the `@available` flags added in 0.23.1 to `#if os(macOS)`, since the former is runtime and the latter is compile time, to work around a bug where SwiftUI compiles the `ApolloCodegenLib` library even if it's not included in the target being previewed. ([#1066](https://github.com/apollographql/apollo-ios/pull/1066))
- Added support for `omitDeprecatedEnumCases` command line option I missed for `ApolloCodegenOptions` ([#1053](https://github.com/apollographql/apollo-ios/pull/1053))

## v0.23.1
- Added some `@available` flags to prevent accidental compilation of `ApolloCodegenLib` on platforms other than macOS. ([#1041](https://github.com/apollographql/apollo-ios/pull/1041))
- Made the `Query` on `GraphQLQueryWatcher` public so it can be referenced. ([#1037](https://github.com/apollographql/apollo-ios/pull/1037))

## v0.23.0
- **BETA**: Now available, SPM-based code generation, Phase 0 of our transition to Swift Codegen.
  
    Note that the underlying codegen is still using `apollo-tooling`, but that will change as we proceed with Phase 1 of the [Swift Codegen Project](https://github.com/apollographql/apollo-ios/projects/2), generating the code in Swift.

    Documentation is available at our [Swift Scripting page](https://www.apollographql.com/docs/ios/swift-scripting/).
  
    When this gets to the final version this **will** supersede existing codegen, so please file bugs galore on this so we can get it good to go as quickly as possible. Thank you! ([#940](https://github.com/apollographql/apollo-ios/pull/940), [#1033](https://github.com/apollographql/apollo-ios/pull/1033))\

- Fixed some memory leaks in our internal Promises implementation. ([#1016](https://github.com/apollographql/apollo-ios/pull/1016))

### v0.22.1
- Repoints download link to our CDN for the CLI for people on 0.22.0 who can't upgrade to 0.26.0 or higher immediately.

### v0.22.0
- **BREAKING**: Updated CLI to [v2.22.1](https://github.com/apollographql/apollo-tooling/releases/tag/apollo%402.22.1), including a bunch of fixes on the Swift side: 
    - Marked files which are generated as `@generated`
    - Added documentation to the constructors of input structs
    - Added additional type annotations to improve compile times.
- **BREAKING**: Updated delegate in `HTTPNetworkTransport` to be a `weak var` and to not be passed in as a parameter to the initializer. ([#990](https://github.com/apollographql/apollo-ios/pull/990), [#1002](https://github.com/apollographql/apollo-ios/pull/1002))
- Added a lock to `InMemoryNormalizedCache` to reduce possible race conditions. ([#552](https://github.com/apollographql/apollo-ios/pull/552))
- Added the ability to not send duplicates on a websocket. ([#1004](https://github.com/apollographql/apollo-ios/pull/1004))
- Fixed an issue that could lead to an undefined cache key in the SQLite library. ([#991](https://github.com/apollographql/apollo-ios/pull/991))
- Fixed an issue where existing fetch operations in a watcher would not be canceled before a new one was started. ([#1012](https://github.com/apollographql/apollo-ios/pull/1012))

### v0.21.1
- Repoints download link to our CDN for the CLI for people on 0.21.0 who can't upgrade to 0.26.0 or higher immediately.

### v0.21.0
- **BREAKING**, but by popular request: Removed the requirement that the `clientName` and `clientVersion` on `NetworkTransport`, and added a default implementation so custom implementations don't need to set these up themselves. ([#954](https://github.com/apollographql/apollo-ios/pull/954))

### v0.20.1
- Repoints download link to our CDN for the CLI for people on 0.20.0 who can't upgrade to 0.26.0 or higher immediately.

### v0.20.0

- Fixed a bunch of data races in `ApolloWebSocket`. ([#880](https://github.com/apollographql/apollo-ios/pull/880))
- Updated `ApolloWebSocket` to depend on `Apollo` in `Package.swift` since there is a dependency there. ([#906](https://github.com/apollographql/apollo-ios/pull/906))
- **POSSIBLY BREAKING** Updated Swift tools version in package declaration to 5.1. ([#883](https://github.com/apollographql/apollo-ios/pull/883))

### v0.19.1
- Repoints download link to our CDN for the CLI for people on 0.19.0 who can't upgrade to 0.26.0 or higher immediately.

### v0.19.0
- **NEW**: Added a retry delegate to allow retries based on GraphQL errors returned from your server, not just network-level errors. NOTE: Be careful with which errors you retry for - the mere presence of an error doesn't necessarily indicate a full failure since GraphQL queries can return partial results. ([#770](https://github.com/apollographql/apollo-ios/pull/770))
- **NEW**: Automatically generates ApolloEngine/ApolloGraphManager headers based on your main bundle's ID and version number. These can also be configured when you set up your `NetworkTransport` if you need something more granular for different versions of your application. ([#858](https://github.com/apollographql/apollo-ios/pull/858))
- **POSSIBLY BREAKING**: The `NetworkTransport` protocol is now class-bound. If you built your own `NetworkTransport` implementation instead of one of the ones included with the library, this now must be a `class` instead of a `struct`. ([#770](https://github.com/apollographql/apollo-ios/pull/770))
- **POSSIBLY BREAKING**: Removed an `unzip` method for arrays of arays which we were not using. However, since it was public, we figured we should let you know. ([#872](https://github.com/apollographql/apollo-ios/pull/872))
- Bumped Starscream dependency to `3.1.1`. ([#873](https://github.com/apollographql/apollo-ios/pull/873))

### v0.18.2
- Repoints download link to our CDN for the CLI for people on 0.18.x who can't upgrade to 0.26.0 or higher immediately.

### v0.18.1
- Removes TSAN from run on schemes to fix Carthage issue. ([#862](https://github.com/apollographql/apollo-ios/pull/862))


### v0.18.0
- **POSSIBLY BREAKING**: Updated CLI to no longer be directly bundled, but to be downloaded if needed. This allows us to avoid bloating the iOS repo with the CLI zip, and to make it easier to test different versions of the CLI in the future. This change should automatically download the updated CLI version for you. 

  Note one significant change from prior bundled versions: If you are connected to the internet when you download the iOS dependency through SPM/Carthage/CocoaPods, you will now need to build your target while still connected to the internet in order to download the proper version of the CLI. Once the correct version of the CLI is downloaded, internet access should no longer be necessary to build. If you disconnect from the internet before the correct version downloads, you will not be able to build. ([#855](https://github.com/apollographql/apollo-ios/pull/855))
- Updated version of CLI to download to [`2.21.0`](https://github.com/apollographql/apollo-tooling/releases/tag/apollo%402.21.0). ([#855](https://github.com/apollographql/apollo-ios/pull/855)) This includes: 
    - Ability to have the codegen ignore deprecated enum cases by using the `--omitDeprecatedEnumCases` flag
    - Fix for generating input fields for `null` values
- Fixes a number of weak references with closures. Note [that this may reveal some places you weren't hanging onto a strong reference to your `ApolloClient` object](https://github.com/apollographql/apollo-ios/pull/854#issuecomment-545673975), which will cause it to get deallocated. ([#854](https://github.com/apollographql/apollo-ios/pull/854))

### v0.17.0
- **NEW**: Support for [Automatic Persisted Queries](https://www.apollographql.com/docs/apollo-server/performance/apq/). This feature allows you to send the hash of a query to your server, and if the server recognizes the hash, it can perform the whole query without you having to send it again. This is particularly useful for large queries, since it can reduce the amount of data you have to send from your user's device pretty significantly. ([#767](https://github.com/apollographql/apollo-ios/pull/767))
- **BREAKING**: Removed old script files which have been deprecated. If you were still using these, please check out the updated [codegen build step setup instructions](https://www.apollographql.com/docs/ios/installation/#adding-a-code-generation-build-step) to get up and running with the `run-bundled-codegen` script. ([#820](https://github.com/apollographql/apollo-ios/pull/820))
- **POSSIBLY BREAKING**: Updated bundled CLI to v2.19.1. Please check out the [CLI changelog](https://github.com/apollographql/apollo-tooling/blob/master/CHANGELOG.md#apollo2191) for full details, but this version actually moves to using multi-line Swift strings for queries. If you prefer to have condensed queries, it also introduces a `--suppressSwiftMultilineStringLiterals` flag which produces single-line queries stripped of whitespace. ([#831](https://github.com/apollographql/apollo-ios/pull/831))
- Fixed a couple places we were not using `LocalizedError` properly. ([#818](https://github.com/apollographql/apollo-ios/pull/818))

### v0.16.1
- Updated the way `run-bundled-codegen` checks whether the bundled codegen has already been unzipped and has node locally. ([#806](https://github.com/apollographql/apollo-ios/pull/806))
- Updated how default parameters are provided for `RequestCreatorProtocol`. ([#804](https://github.com/apollographql/apollo-ios/pull/804))

### v0.16.0
- **BREAKING**: We've switched to a much simpler setup which does not involve NPM in order to use our CLI. This requires updating your build scripts. Please follow the [updated instructions for setting up the build script here](https://www.apollographql.com/docs/ios/installation/#adding-a-code-generation-build-step). The existing build script will continue to work until the next minor release, at which point it will be removed. ([#766](https://github.com/apollographql/apollo-ios/pull/766))
- Included CLI version fixes issues which showed up in `0.15.2`. 
- **BREAKING**: We've removed all public references to our internal `Promise` implementation, which was never intended to be public. ([#709](https://github.com/apollographql/apollo-ios/pull/709))
- Fixed a deadlock in a transaction. ([#763](https://github.com/apollographql/apollo-ios/pull/763), [#365](https://github.com/apollographql/apollo-ios/pull/365))
- Added a `RequestCreatorProtocol` to allow you to more easily muck with and/or mock creating multipart requests. ([#771](https://github.com/apollographql/apollo-ios/pull/771))
- Fixed an issue causing problems building with SPM in Xcode 11. ([#784](https://github.com/apollographql/apollo-ios/pull/784))

### v0.15.3
- Revert CLI update from `0.15.2` due to unexpected build issues. 

### v0.15.2
- Update Apollo CLI requirement to 2.18. This should pull in a couple fixes to the CLI: 
    - Way better escaping of identifiers, types, and strings ([Tooling #1515](https://github.com/apollographql/apollo-tooling/pull/1515))
    - Fix compiler warning when an optional has a `.none` case ([Tooling #1482](https://github.com/apollographql/apollo-tooling/pull/1482))
  
  If you run into any weird build issues after this update, try deleting your local `node_modules` folder and rebuilding before filing an issue. ([#760](https://github.com/apollographql/apollo-ios/pull/760))
- Better handling of the `localizedDescription` for `HTTPResponseError`. ([#756](https://github.com/apollographql/apollo-ios/pull/756))

### v0.15.1
- Add platform name to framework bundle identifier to work around a change to app store submission. Please see the PR for more details. ([#751](https://github.com/apollographql/apollo-ios/pull/751))
- Expose the initializer for `GraphQLQueryWatcher` so it can actually be instantiated. ([#750](https://github.com/apollographql/apollo-ios/pull/750))

### v0.15.0
- **BREAKING**: Finally swapped out `URLSessionConfiguration` on initializer for `HTTPNetworkTransport` to use `URLSession` directly instead. If you were previously passing in a configuration, first hand it to a `URLSession` instance and then pass that instance into the initializer. 

  This allows many new things including: 
    - Support for background sessions
    - Easier mocking through `NSURLProtocol`
    - Certificate pinning
    - Self-signed certificates
    - Metrics inspection
    - Authentication challenge handling
 
 All these are pretty much entirely through the ability to use `URLSessionDelegate` directly since we're now accepting a `URLSession` you can declare yourself to be the delegate of rather than just the configuration. ([#699](https://github.com/apollographql/apollo-ios/pull/699), inspired by [#265](https://github.com/apollographql/apollo-ios/pull/265))
- **BREAKING**, though hopefully in a good way: Significant updates to the Upload functionality to make it conform more closely to the [GraphQL Upload Spec](). Also added a goodly bit of documentation around this functionality. ([#707](https://github.com/apollographql/apollo-ios/pull/707))
- Way better support for Swift Package Manager, especially for `ApolloSQLite` and `ApolloWebSocket`. ([#674](https://github.com/apollographql/apollo-ios/pull/674))
- Created `ApolloClientProtocol` to match all public methods of `ApolloClient` for easier mocking. ([#715](https://github.com/apollographql/apollo-ios/pull/715), inspired by [#693](https://github.com/apollographql/apollo-ios/pull/693))


### v0.14.0

- **BREAKING** Updated codegen to use 2.17 of the Apollo CLI. Please see the [full release notes](https://github.com/apollographql/apollo-tooling/blob/master/CHANGELOG.md#apollo2170-apollo-codegen-swift0350) for that version of the CLI, but in short: 
    - Stops force-unwrapping and instead nil-coalesce to `.none` when the thing being unwrapped was a double-optional, which was causing some crashes
    - Fixes issue where removing redundant modifiers was a little too aggressive 
    - Fixes escaping for `Self` as a type name
    - Adds `CaseIterable` for all known cases of an enum. If you were adding this yourself previously, you'll have to take it back out.
    - Adds comment with original operation to `operationDefinition`, stripped excess whitespace from actual definition.

- Added explicit support for Catalyst builds. ([#688](https://github.com/apollographql/apollo-ios/pull/688))
- Added support for `Int` custom scalars. ([#402](https://github.com/apollographql/apollo-ios/pull/402))
- Exposed `clearCache` directly on stores so a store being used by multiple clients can be more explicitly cleared. ([#518](https://github.com/apollographql/apollo-ios/pull/518))
- Fixed an issue where an error on cache write would not be propagated correctly. ([#673](https://github.com/apollographql/apollo-ios/pull/673))
- Updated supported Node version to the Long-Term Support version. ([#672](https://github.com/apollographql/apollo-ios/pull/672))

### v0.13.0 

**PLEASE READ THESE RELEASE NOTES BEFORE INSTALLING IF YOU WERE USING AN OLDER VERSION!**

- **SUPER-BREAKING**: Updated a ton of completion closures that could use it to use `Result` instead of optional parameter / optional error. ([#644](https://github.com/apollographql/apollo-ios/pull/644)). There are a few details to this one to be particularly aware of: 
  - If you see a bunch of Swift build errors that are claiming **Generic Parameter "Query" could not be inferred**, that means you need to update your completion closure to take the single `Result<Parameter, Error>` parameter instead of the two (`Parameter?`, `Error?`) parameters. 
  - Particularly around caching, if there are places where **both** parameters were `nil` in previous iterations, you will now get an `Error`. This will generally be a `JSONDecodingError.missingValue`, either as the direct error or as the `underlying` error of a `GraphQLResultError`. Please check out the changes to [`FetchQueryTests` in PR #644](https://github.com/apollographql/apollo-ios/pull/644/files#diff-43b7c3a7619bfcbf87cf3eabe314d908) for a better look at how some of that has changed.
- **BREAKING**: Updated the codegen to use v2.16 of the Apollo CLI. ([#647](https://github.com/apollographql/apollo-ios/issues/647)). This is a major version change so some things need to be added, and some parameter names have changed: 
  - You must add `--target=swift` so the CLI knows to generate Swift code.
  - If you were using `--schema=schema.json`, use `--localSchemaFile="schema.json"` instead (the quotes are required!).
  - If you were using `--queries="$(find . -name '*.graphql')"` to pass in an array of all your GraphQL files, use `--includes=./*.graphql` instead. 

  If you get error messages about multiple versions of node when you attempt to run, delete the `node_modules` folder in your source root and rebuild. 
  
  Upgrading fixes several issues:
  
  - `operationName` is now generated for all operations.
  - Trailing newlines are now added to all generated files. 
- **NEW**: Ability to upload files according to the [GraphQL Multi-part request spec](https://github.com/jaydenseric/graphql-multipart-request-spec). ([#626](https://github.com/apollographql/apollo-ios/pull/626), [#648](https://github.com/apollographql/apollo-ios/pull/648), inspired by [#116](https://github.com/apollographql/apollo-ios/pull/116))
- **NEW**: Now that `operationName` is generated for all operations, we're sending it along with all requests. ([#657](https://github.com/apollographql/apollo-ios/pull/657), inspired by [#492](https://github.com/apollographql/apollo-ios/pull/492))
- **NEW**: We're also sending `operationName` as the `X-APOLLO-OPERATION-NAME` header and when an `operationIdentifier` is provided, sending that as the `X-APOLLO-OPERATION-ID` header. ([#658](https://github.com/apollographql/apollo-ios/pull/658))
- **NEW**: Option to run `VACUUM` on your SQLite store when clearing to help obliterate all traces of data. ([#652](https://github.com/apollographql/apollo-ios/pull/652))
- **NEW**: Auto-generated API documentation from inline comments. Now available [on the website](https://www.apollographql.com/docs/ios/api-reference/) NOTE: Any manual changes made to markdown files will get overwritten, if you want to contribute to the docs, please add inline comments to the code and then I'll get the docs updated. ([#642](https://github.com/apollographql/apollo-ios/pull/642)). 
- Made `GraphQLResultError` and its underlying error `public` for better error handling. ([#655](https://github.com/apollographql/apollo-ios/pull/655))



### v0.12.0
- **BREAKING**: Removed internal `Result` type in favor of Swift's built in `Result` type. This allows you to not have to prefix anything that uses the built-in result type with `Swift.Result` in places where you're using the Apollo SDK. ([#641](https://github.com/apollographql/apollo-ios/pull/641))
- **BREAKING**: Set strict dependency versions for Starscream and SQLite.swift to prevent potential problems with Swift version conflicts. ([#641](https://github.com/apollographql/apollo-ios/pull/625)). 
- **BREAKING**: Made Carthage dependencies for Starscream and SQLite.swift private so they're not automatically pulled in when trying to build just the main SDK with Carthage. If you're using the `ApolloSQLite` or `ApolloWebSocket` frameworks with Carthage, **please read the updated documentation!**. ([#635](https://github.com/apollographql/apollo-ios/pull/635), [#641](https://github.com/apollographql/apollo-ios/pull/641))
- Fixed issue where `GET` requests were requiring `AnyHashable` instead of `Any` which made requests with `Bool` properties never send. ([#628](https://github.com/apollographql/apollo-ios/pull/628), big thanks to [#624](https://github.com/apollographql/apollo-ios/pull/624))

### v0.11.1
- Fixed missing `Foundation` imports for several classes that were causing issues with Buck and Swift Package Manager builds. ([#620](https://github.com/apollographql/apollo-ios/pull/620)) 
- Updated version of `SQLite.swift` dependency to one that properly supports Swift 5. ([#621](https://github.com/apollographql/apollo-ios/pull/621))
- Whole mess o'documentation updates. ([#618](https://github.com/apollographql/apollo-ios/pull/618))
- Fixed a whitespace issue with one of the build scripts. ([#618](https://github.com/apollographql/apollo-ios/pull/618))
- Made the `GraphQLResult` initializer public for testing. ([#544](https://github.com/apollographql/apollo-ios/pull/544))

### v0.11.0

- **BREAKING**: Updated Podspec to preserve paths rather than embedding scripts in the framework. Updated instructions for embedding with CocoaPods. ([#575](https://github.com/apollographql/apollo-ios/pull/575), [#610](https://github.com/apollographql/apollo-ios/pull/610))
- **NEW**: At long last, the ability to update headers on preflight requests, the ability to peer into what came to the `URLSession` and the ability to determine if an operation should be retried. ([#602](https://github.com/apollographql/apollo-ios/pull/602))
- **NEW**: Added `.fetchIgnoringCacheCompletely` caching option, which  can result in significantly faster performance if you don't need the caching. ([#551](https://github.com/apollographql/apollo-ios/pull/551))
- **NEW**: Added support for using `GET` for queries. ([#572](https://github.com/apollographql/apollo-ios/pull/572), [#599](https://github.com/apollographql/apollo-ios/pull/599), [#602](https://github.com/apollographql/apollo-ios/pull/602))
- Updated lib and dependencies to use Swift 5, and say so in the Podfile. ([#522](https://github.com/apollographql/apollo-ios/pull/522), [#528](https://github.com/apollographql/apollo-ios/pull/528), [#561](https://github.com/apollographql/apollo-ios/pull/561), [#592](https://github.com/apollographql/apollo-ios/pull/592))
- Exposed a method to ping a WebSocket server to keep it alive. ([#422](https://github.com/apollographql/apollo-ios/pull/422))
- Handling is always done on a handler queue. ([#539](https://github.com/apollographql/apollo-ios/pull/539))
- Added documentation on the `read` and `update` operations for watching queries. ([#452](https://github.com/apollographql/apollo-ios/pull/452))
- Updated build scripts for non-CocoaPods installations to account for spaces in project names or folders. ([#610](https://github.com/apollographql/apollo-ios/pull/610))
- Fixed a code generation fail if you're using MacPorts instead of Homebrew to install `npm`. ([#591](https://github.com/apollographql/apollo-ios/pull/591))

### v0.10.1

- Disabled bitcode in Debug builds for physical devices ([#499](https://github.com/apollographql/apollo-ios/pull/499))
- Don't embed the Swift standard libraries by default ([#501](https://github.com/apollographql/apollo-ios/pull/501))

### v0.10.0

- Swift 5 support ([#427](https://github.com/apollographql/apollo-ios/pull/427), [#475](https://github.com/apollographql/apollo-ios/pull/475))
- Update to newest version of Starscream ([#466](https://github.com/apollographql/apollo-ios/pull/466)
- Add ability to directly update cache with write methods ([#413](https://github.com/apollographql/apollo-ios/pull/413))
- Add docs for `read` and `update` operations ([#452](https://github.com/apollographql/apollo-ios/pull/452))

### v0.9.5

- Add ability to pass params to `Query.Data` ([#437](https://github.com/apollographql/apollo-ios/pull/437))
- Provide separate archs for the iOS Simulator ([#410](https://github.com/apollographql/apollo-ios/pull/410))
- Actually install the correct version of Node instead of just checking for it ([#434](https://github.com/apollographql/apollo-ios/pull/434))


### v0.9.4

- Updated required version of `apollo-cli` to `1.9`. A nice addition to `1.9.2` is that Swift Enums now conforms to Hashable enabling among other things comparison between fetch objects. ([#578](https://github.com/apollographql/apollo-cli/pull/578))
- Fixed internal bug that caused infinite reconnection cycle when connection is lost. A reconnectionInterval was added as a workaround. ([#368](https://github.com/apollographql/apollo-ios/pull/368))
- Fixed internal bug that prevents the `wrongType` case being returned by the `JSONDecodingError` implementation of `Matchable`. ([#367](https://github.com/apollographql/apollo-ios/pull/367))
- Added delegate for WebTransport which can handle connection/reconnection/disconnection events of websocket. ([#379](https://github.com/apollographql/apollo-ios/pull/379))

### v0.9.1

- Since `apollo-codegen` is now part of the new [`apollo-cli`](https://github.com/apollographql/apollo-cli), the build script used to generate `API.swift` needs to be updated. See [the docs](https://www.apollographql.com/docs/ios/installation.html#adding-build-step) for the updated script.

### v0.6.0

- Added read and write functions for fine-grained manual store updates.

- Added support for pluggable asynchronous caches, with an optional experimental SQLite implementation.

- Fragments are now merged into the parent result, so you only need to go through `fragments` when you want to pass a fragment explicitly.

- Generated result models are no longer immutable (but still obey value semantics).

- Generated result models now have memberwise initializers (when they represent a concrete type) or type-specific factory methods (when they represent multiple possible types).

- Any generated result model can be safely initialized from a JSON object (`init(jsonObject:)` and converted into a `jsonObject`.

- Generated input objects now differentiate between a property being `null` and a property not being present.
