# Change log

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

- Updated required version of `apollo-cli` to `1.9`. A nice addition to `1.9.2` is that Swift Enums now conforms to Hashable enabling among other things comparision between fetch objects. ([#578](https://github.com/apollographql/apollo-cli/pull/578))
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
