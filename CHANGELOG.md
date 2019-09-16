# Change log

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
    - Fixes issue where removing redundant modifiers was a little too agressive 
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
