# Change Log

## v1.3.3

### Fixed
- **Fix two issues with generated models:** See PR ([#3168](https://github.com/apollographql/apollo-ios/pull/3168)). _Thank you to [@iAmericanBoy](https://github.com/iAmericanBoy) for finding these issues and providing a reproduction case._
- **Fix computation of operation identifiers for persisted queries:** See PR ([#3163](https://github.com/apollographql/apollo-ios/pull/3163)). _Thank you to [@WolframPRO](https://github.com/WolframPRO) for finding these issues._

## v1.3.2

### Improved
- **Throw an error when an invalid key is present in the codegen configuration JSON ([#2942](https://github.com/apollographql/apollo-ios/issues/2942)):** See PR ([#3125](https://github.com/apollographql/apollo-ios/pull/3125)) _Thank you to [@Iron-Ham](https://github.com/Iron-Ham) for the contribution._
- **Cleanup unused imports and declarations. ([#3099](https://github.com/apollographql/apollo-ios/issues/3099)):** See PR ([#3100](https://github.com/apollographql/apollo-ios/pull/3100)) _Thank you to [@Iron-Ham](https://github.com/Iron-Ham) for raising the issue and contributing the fix._
- **Improvement to response code error API ([#2426](https://github.com/apollographql/apollo-ios/issues/2426)):** See PR ([#3123](https://github.com/apollographql/apollo-ios/pull/3123)). _Thank you to [@dfperry5](https://github.com/dfperry5) for the contribution._
- **Improved file path support for operation manifest generation:** See PR ([#3128](https://github.com/apollographql/apollo-ios/pull/3128))

### Fixed
- **Fix two issues in test mock generation:** See PR ([#3120](https://github.com/apollographql/apollo-ios/pull/3120)). _Thank you to [@TizianoCoroneo](https://github.com/TizianoCoroneo) for finding this issue and contributing the fix._
- **Fixed precondition failure when surpassing graphql-js max error count ([#3126](https://github.com/apollographql/apollo-ios/issues/3126)):** See PR ([#3132](https://github.com/apollographql/apollo-ios/pull/3132)).

### Deprecated
- **Deprecated `queryStringLiteralFormat` in `ApolloCodegenConfiguration`:** Query string literals will now always be generated as single line strings. See PR ([#3129](https://github.com/apollographql/apollo-ios/pull/3129)).

## v1.3.1

### Fixed
- **Fix crashes in test mocks when setting an array of union types ([#3023](https://github.com/apollographql/apollo-ios/pull/3023)):** See PR ([#3089](https://github.com/apollographql/apollo-ios/pull/3089)). _Thank you to [@jabeattie](https://github.com/jabeattie) & [@scottasoutherland](https://github.com/scottasoutherland) for raising the issue._

### Deprecated
- **Deprecated `APQConfig` & `operationIdentifiersPath` in `ApolloCodegenConfiguration`:** These have been replaced with `OperationDocumentFormat` and `OperationManifestFileOutput` respectively. Please see the documentation for [`ApolloCodegenConfiguration`](https://www.apollographql.com/docs/ios/code-generation/codegen-configuration) for more information. 

## v1.3.0

Though `1.3.0` is a minor version bump, some critical issues were addressed in this version that requires a small breaking change during the upgrade.  While we strive to make the upgrade path for minor versions seamless, these issues could not be reasonably resolved without requiring this migration.

For a detailed explanation of the breaking changes and a guide on how to migrate to `1.3.0`, see our [migration guide](https://www.apollographql.com/docs/ios/migrations/1.3).

### Breaking
- **Using reserved keyword `Type` as in selection fields does not compile ([#3006](https://github.com/apollographql/apollo-ios/issues/3006)):** See PR [#3058](https://github.com/apollographql/apollo-ios/pull/3058). _Thank you to [@Nielssg](https://github.com/Nielssg) for raising the issue._
- **Memory leak from `InterceptorRequestChain` when ending the chain with `returnValueAsync` ([#3057](https://github.com/apollographql/apollo-ios/issues/3057)):** See PR [#3070](https://github.com/apollographql/apollo-ios/pull/3070). _Thank you to [@marksvend](https://github.com/marksvend) for raising the issue._

## v1.2.2

### Added
- **Support SOCKS proxies for debugging websocket based subscriptions([#2788](https://github.com/apollographql/apollo-ios/issues/2788)):** _Thank you to [@tahirmit](https://github.com/tahirmt) for the contribution._ 

### Fixed
- **Fix conversion of generated models into nested type cases ([#2989](https://github.com/apollographql/apollo-ios/issues/2989) & [#2980](https://github.com/apollographql/apollo-ios/issues/2980)):** In some cases, the generated models were missing types when calculating which fragments were fulfilled for a selection set. This was causing type case conversion to return `nil` incorrectly. See PR [#3067](https://github.com/apollographql/apollo-ios/pull/3067). _Thank you to [@tgyhlsb](https://github.com/tgyhlsb) and [@dafurman](https://github.com/dafurman) for raising these issues._
- **Fix crashes in code generation when merging fragments at definition root ([#3071](https://github.com/apollographql/apollo-ios/issues/3071)):** When fragments with type conditions were defined on the root of an operation or named fragment, the code generation engine was crashing. See PR [#3073](https://github.com/apollographql/apollo-ios/pull/3073). _Thank you to [@tahirmit](https://github.com/tahirmt) for raising and helping us reproduce this issue._
- **Fix parsing of input objects as default values for input params ([#2978](https://github.com/apollographql/apollo-ios/issues/2978)):** The codegen engine will no longer crash in this situation. _Thank you to [@ecunha-ta](https://github.com/ecunha-ta) for raising the issue._

## v1.2.1

### Improved
- **Added new validation to alert users to type naming conflict when running code generation([#2405](https://github.com/apollographql/apollo-ios/issues/2405)):** See PR [#3041](https://github.com/apollographql/apollo-ios/pull/3041).

### Fixed
- **Int values failing to cast to Scalar Type during cache key resolution ([#3034](https://github.com/apollographql/apollo-ios/issues/3034)):** See PR [#3037](https://github.com/apollographql/apollo-ios/pull/3037). _Thank you to [@asbhat](https://github.com/asbhat) for raising the issue._
- **Fix malformed RootEntityType on generated fragment with `@include` condition. ([#2962](https://github.com/apollographql/apollo-ios/issues/2962)):** See PR [#3045](https://github.com/apollographql/apollo-ios/pull/3045). _Thank you to [@alexisbronchart](https://github.com/alexisbronchart) for raising the issue._


## v1.2

Though 1.2 is a minor version bump, a critical problem was addressed in this version that requires a small breaking change during the upgrade.  While we strive to make the upgrade path for minor versions seamless, this issue could not be reasonably resolved without requiring this migration.

**For most users, this migration will only require a single change to your `SchemaConfiguration.swift` file.**

For a detailed explanation of the breaking changes and a guide on how to migrate to v1.2, see our [migration guide](https://www.apollographql.com/docs/ios/migrations/1.2).

### Breaking
- **Cache Key Configuration API Changes ([#2990](https://github.com/apollographql/apollo-ios/pull/2990)):** The API for configuring custom cache keys has had a minor change in this version. The signature of the `cacheKeyInfo(for:object:)` function, defined in your generated SchemaConfiguration.swift file, has been modified. For more information, see our [migration guide](https://www.apollographql.com/docs/ios/migrations/1.2).

### Improved
- **Improved performance of GraphQL execution ([#2990](https://github.com/apollographql/apollo-ios/pull/2990)):** Improvements to the `GraphQLExecutor` resulted in a ~15-20% reduction in execution time for parsing and mapping network response or cache data onto generated models.
- **Improved performance of generated model initialization and type conversions ([#2990](https://github.com/apollographql/apollo-ios/pull/2990)):** The `DataDict` used to store the data for generated models has been updated to use copy-on-write value semantics. This resulted in a ~70-80% reduction in the execution time of initialization and type case conversions in the generated models.

### Fixed
- **Pruning generated files for `.relative(subpath:)` operations ([#2969](https://github.com/apollographql/apollo-ios/issues/2969)):** See PR [#2994](https://github.com/apollographql/apollo-ios/pull/2994). _Thank you to [@jimisaacs](https://github.com/jimisaacs) for raising the issue._
- **InputObjects generated with incorrect getter/setter key ([#2858](https://github.com/apollographql/apollo-ios/issues/2858)):** See PR [#2996](https://github.com/apollographql/apollo-ios/pull/2996). _Thank you to [@Austinpayne](https://github.com/Austinpayne) for raising the issue._
- **Generates conflicting types for fields of singular and plural names ([#2850](https://github.com/apollographql/apollo-ios/issues/2850)):** See PR [#3009](https://github.com/apollographql/apollo-ios/pull/3009). _Thank you to [@sgade](https://github.com/sgade) for raising the issue._
- **Equality operator shows incorrect values based on value of `__fulfilled` ([#2944](https://github.com/apollographql/apollo-ios/issues/2944)):** See PR [#2990](https://github.com/apollographql/apollo-ios/pull/2990). _Thank you to [@scottasoutherland](https://github.com/scottasoutherland) for raising the issue._

### New
- **Add option to generate objects with `internal` access modifier ([#2630](https://github.com/apollographql/apollo-ios/issues/2630)):** See PR [#2917](https://github.com/apollographql/apollo-ios/pull/2917). _Thank you to [@simonbilskyrollins](https://github.com/simonbilskyrollins) for the feature request._

## v1.1.3

### Fixed
- **`@dynamicMember` conflicting field name ([#2950](https://github.com/apollographql/apollo-ios/issues/2950)):** The subscript setters have been changed to allow a selection set property named `hash`. [#2965](https://github.com/apollographql/apollo-ios/pull/2965) _Thank you to [@renanbdias](https://github.com/renanbdias) for raising the issue._
- **Disallow certain targetNames in code generation ([#2958](https://github.com/apollographql/apollo-ios/issues/2958)):** `apollo` is no longer allowed as a target name otherwise it causes a conflict when importing `Apollo` as a module. [#2972](https://github.com/apollographql/apollo-ios/pull/2972) _Thank you to [@moopoints](https://github.com/moopoints) for raising the issue._
- **Fully Qualify name of RootEntityType and mergedSources ([#2949](https://github.com/apollographql/apollo-ios/issues/2949)):** Selection set types use fully qualified namespacing to prevent conflicts with other types. [#2956](https://github.com/apollographql/apollo-ios/pull/2956) _Thank you to [@martin-muller](https://github.com/martin-muller) for raising the issue._
- **SelectionSet Codegen `__typename` fix ([#2955](https://github.com/apollographql/apollo-ios/issues/2955)):** Custom root types defined in the schema are now correctly applied to selection set fields typename definitions [#2983](https://github.com/apollographql/apollo-ios/pull/2983) _Thank you to [@ynnadrules](https://github.com/ynnadrules) for raising the issue._

## v1.1.2

### Fixed
- **Crash after calling `cancel()` on `Cancellable` ([#2932](https://github.com/apollographql/apollo-ios/issues/2932)):** Calling `cancel()` on a non-subscription `Cancellable` will now correctly handle the lifetime of the internally `Unmanaged` object. [#2943](https://github.com/apollographql/apollo-ios/pull/2943) - _Thank you to [@yonaskolb](https://github.com/yonaskolb) for raising the issue._
- **Deprecation messages are not escaped ([#2879](https://github.com/apollographql/apollo-ios/issues/2879)):** If escaped characters are used in GraphQL deprecation messages they are now properly escaped in the rendered Swift warning or attribution message. [#2951](https://github.com/apollographql/apollo-ios/pull/2951) _Thank you to [@djavan-bertrand](https://github.com/djavan-bertrand) for raising the issue._

### Added
- **Add injecting additionalErrorHandler for upload operations to RequestChainNetworkTransport ([#2948](https://github.com/apollographql/apollo-ios/pull/2948)):** `Upload` operations can now have custom error interceptors like other operations. [#2948](https://github.com/apollographql/apollo-ios/pull/2948) _Thank you to [@RobertDresler](https://github.com/RobertDresler) for the contribution._

## v1.1.1

### Fixed
- **Version 1.1.0 does not compile when installed via CocoaPods ([#2936](https://github.com/apollographql/apollo-ios/issues/2936)):** Module names not present in CocoaPods builds have been removed from type declarations. [#2937](https://github.com/apollographql/apollo-ios/pull/2937) - _Thank you to [@simonliotier](https://github.com/simonliotier) for raising the issue._
- **Crash when using mocks for Double Nested Arrays ([#2809](https://github.com/apollographql/apollo-ios/issues/2809)):** Test mock data is now correctly applied to the selection set. [#2939](https://github.com/apollographql/apollo-ios/pull/2939) - _Thank you to [@scottasoutherland](https://github.com/scottasoutherland) for raising the issue._
- **In 1.1.0, passing custom scalars or GraphQLEnum to mocks fails ([#2928](https://github.com/apollographql/apollo-ios/issues/2928)):** Test mock data is now correctly applied to the selection set. [#2939](https://github.com/apollographql/apollo-ios/pull/2939) - _Thank you to [@scottasoutherland](https://github.com/scottasoutherland) for raising the issue._

## v1.1.0

Apollo iOS v1.1 primarily focuses on adding generated initializers to the generated operation models.

In most cases, the upgrade from v1.0 to v1.1 should require no changes to your code. 

### **Breaking** 
- **Changed generated fragment accessors with inclusion conditions:** When conditionally spreading a fragment with an `@include/@skip` directive that has a different parent type than the selection set it is being spread into, the shape of the generated models has changed.  
  - For example, a fragment accessor defined as `... on DetailNode @include(if: $includeDetails)` would have previously been named `asDetailNode`; it will now be generated as `asDetailNodeIfIncludeDetails`.
- While no breaking changes were made to official public APIs, some *underscore prefixed* APIs that are `public` but intended for internal usage only have been changed.
  - **SelectionSet fulfilled fragment tracking:** `SelectionSet` models now keep track of which fragments were fulfilled during GraphQL execution in order to enable conversions between type cases. While this does not cause functional changes while using public APIs, this is a fundamental change to the way that the underlying data for a `SelectionSet` is formatted, it is now required that all `SelectionSet` creation must be processed by the `GraphQLExecutor` or a generated initializer that is guaranteed to correctly format the data. **This means that initializing a `SelectionSet` using raw JSON data directly will no longer work.** Please ensure that raw JSON data is only used with the new `RootSelectionSet.init(data: variables)` initializer.
### Fixed
- **Null/nil value parsing issues**. In some situations, writing/reading `null` or `nil` values to the cache was causing crashes in 1.1 Beta 1. This is now fixed.  
### Added
- **Configuration option for generating initializers on SelectionSet models:** You can now get initializers for your generated selection set models by setting the `selectionSetInitializers` option on your code generation configuration. Manually initialized selection sets can be used for a number of purposes, including:
  * Adding custom data to the normalized cache
  * Setting up fixture data for SwiftUI previews or loading states
  * An alternative to Test Mocks for unit testing      
- **Safe initialization of `SelectionSet` models with raw JSON:** In 1.0, initializing `SelectionSet` models with raw JSON was unsafe and required usage of *underscore prefixed* APIs that were intended for internal usage only. Apollo iOS 1.1 introduces a new, safe initializer: `RootSelectionSet.init(data: variables)`.
  * Previously, if you provided invalid JSON, your selection set's were unsafe and may cause crashes when used. The new initializer runs a lightweight version of GraphQL execution over the provided JSON data. This quickly parses, validates, and transforms the JSON data into the format required by the `SelectionSet` models. If the provided data is invalid, this initializer `throws` an error, ensuring that your model usage is always safe.
- **Added support for multipart subscriptions over HTTP.**   
### Changed
- **Generate `__typename` selection for generated models:** In 1.1, the code generator adds the `__typename` field to each root object. In previous versions, this selection was automatically inferred by the `GraphQLExecutor`, however generating it directly should improve performance of GraphQL execution. 

## v1.1.0-beta.1

This is the first Beta Release of Apollo iOS 1.1. Version 1.1 primarily focuses on adding generated initializers to the generated operation models.

While no breaking changes were made to official public APIs, some *underscore prefixed* APIs that are `public` but intended for internal usage only have been changed.

### Added
- **Configuration option for generating initializers on SelectionSet models:** You can now get initializers for your generated selection set models by setting the `selectionSetInitializers` option on your code generation configuration. Manually initialized selection sets can be used for a number of purposes, including:
  * Adding custom data to the normalized cache
  * Setting up fixture data for SwiftUI previews or loading states
  * An alternative to Test Mocks for unit testing      
- **Safe initialization of `SelectionSet` models with raw JSON:** In 1.0, initializing `SelectionSet` models with raw JSON was unsafe and required usage of *underscore prefixed* APIs that were intended for internal usage only. Apollo iOS 1.1 introduces a new, safe initializer: `RootSelectionSet.init(data: variables)`.
  * Previously, if you provided invalid JSON, your selection set's were unsafe and may cause crashes when used. The new initializer runs a lightweight version of GraphQL execution over the provided JSON data. This quickly parses, validates, and transforms the JSON data into the format required by the `SelectionSet` models. If the provided data is invalid, this initializer `throws` an error, ensuring that your model usage is always safe.
- **Added support for multipart subscriptions over HTTP.**   
### Changed
- **SelectionSet fulfilled fragment tracking:** `SelectionSet` models now keep track of which fragments were fulfilled during GraphQL execution in order to enable conversions between type cases. While this does not cause functional changes while using public APIs, this is a fundamental change to the way that the underlying data for a `SelectionSet` is formatted, it is now required that all `SelectionSet` creation must be processed by the `GraphQLExecutor` or a generated initializer that is guaranteed to correctly format the data. **This means that initializing a `SelectionSet` using raw JSON data directly will no longer work.** Please ensure that raw JSON data is only used with the new `RootSelectionSet.init(data: variables)` initializer.   
- **Generate `__typename` selection for generated models:** In 1.1, the code generator adds the `__typename` field to each root object. In previous versions, this selection was automatically inferred by the `GraphQLExecutor`, however generating it directly should improve performance of GraphQL execution. 
- **Changed generated fragment accessors with inclusion conditions:** When conditionally spreading a fragment with an `@include/@skip` directive that has a different parent type than the selection set it is being spread into, the shape of the generated models has changed. This does not affect generated call sites, but only affects the generated `selection` metadata used internally by the `GraphQLExecutor`.

## v1.0.7

### Fixed
- **Couldn't build when using some reserved words in a schema ([#2765](https://github.com/apollographql/apollo-ios/issues/2765)):** `for` has been added to the list of reserved keywords that are escaped with backticks when used in schema types and operations. [#2772](https://github.com/apollographql/apollo-ios/pull/2772) - _Thank you to [@torycons](https://github.com/torycons) for raising the issue._
- **Subscript GraphQL variable from dictionary crash when Swift modifier used as key ([#2759](https://github.com/apollographql/apollo-ios/issues/2759)):** Backticks have been removed from subscript keys of input objects. [#2773](https://github.com/apollographql/apollo-ios/pull/2773) - _Thank you to [@SzymonMatysik](https://github.com/SzymonMatysik) for raising the issue._
- **Unnamed fields in schema results in broken generated Swift code ([#2753](https://github.com/apollographql/apollo-ios/issues/2753)):** The `_` character can be used as a GraphQL field name. [#2769](https://github.com/apollographql/apollo-ios/pull/2769) - _Thank you to [@neakor](https://github.com/neakor) for raising the issue._
- **LocalCacheMutation with an enum field fails ([#2775](https://github.com/apollographql/apollo-ios/issues/2775)):** When writing selection set data back into the cache, custom scalars are now re-encoded back into their `_jsonValue`. [#2778](https://github.com/apollographql/apollo-ios/pull/2778) - _Thank you to [@dabby-wombo](https://github.com/dabby-wombo) for raising the issue._
- **DataDict subscript function crashes on iOS 14.4 and under ([#2668](https://github.com/apollographql/apollo-ios/issues/2668)):** `AnyHashable` conversions when accessing `DataDict` properties now perform checks on the base type. [#2784](https://github.com/apollographql/apollo-ios/pull/2784) - _Thank you to [@bdunay3](https://github.com/bdunay3) for raising the issue._
- **`@include` directive based on variable with default value drops the included data ([#2690](https://github.com/apollographql/apollo-ios/issues/2690)):** The GraphQL executor will now correctly evaluate `GraphQLNullable` conditional variables. [#2794](https://github.com/apollographql/apollo-ios/pull/2794) - _Thank you to [@klanchman](https://github.com/klanchman) for raising the issue._
- **Interfaces implemented by schema root are not generated ([#2756](https://github.com/apollographql/apollo-ios/issues/2756)):** Interfaces references on the root type Query, Mutation or Subscription are now included in the schema module. [#2816](https://github.com/apollographql/apollo-ios/pull/2816) - _Thank you to [@litso](https://github.com/litso) for raising the issue._

### Changed
- **HTTP headers format in schema download configuration JSON ([#2661](https://github.com/apollographql/apollo-ios/issues/2661)):** `HTTPHeaders` in the `ApolloSchemaDownloadConfiguration` section of the codegen configuration JSON file can now be specified using the more intuitive format `{ "Authorization": "<token>"}`. [#2811](https://github.com/apollographql/apollo-ios/pull/2811) - _Thank you to [@nikitrivedii](https://github.com/nikitrivedii) for raising the issue._

## v1.0.6

### Fixed
- **Quotes in operation identifiers are not escaped ([#2671](https://github.com/apollographql/apollo-ios/issues/2671)):** Query strings are now enclosed within extended delimiters to allow inclusion of special characters such as quotation marks. [#2701](https://github.com/apollographql/apollo-ios/pull/2701) - _Thank you to [@StarLard](https://github.com/StarLard) for raising the issue._
- **Cannot find type `graphQLSchema` in scope ([#2705](https://github.com/apollographql/apollo-ios/issues/2705)):** Generated fragments now use the correct schema namespace casing. [#2730](https://github.com/apollographql/apollo-ios/pull/2730) - _Thank you to [@iAmericanBoy](https://github.com/iAmericanBoy) for raising the issue._
- **Updating a local cache mutation with an optional field fails with a `ApolloAPI.JSONDecodingError.missingValue` error ([#2697](https://github.com/apollographql/apollo-ios/issues/2697)):** Cache mutations will now allow incomplete data to be written to the cache without expecting all fields to be set. Please note that cache manipulation is an advanced feature and you should be aware of how the data written will affect network requests and cache policies. [#2751](https://github.com/apollographql/apollo-ios/pull/2751) - _Thank you to [@amseddi](https://github.com/amseddi) for raising the issue._
- **`GraphQLEnum` value camel case conversion strategy ([#2640](https://github.com/apollographql/apollo-ios/issues/2640)), ([#2749](https://github.com/apollographql/apollo-ios/issues/2749)):** The camel case conversion logic for GraphQL enums has been improved to handle a wider range of edge cases that were causing invalid Swift code generation. [#2745](https://github.com/apollographql/apollo-ios/pull/2745) - _Thank you to [@ddanielczyk](https://github.com/ddanielczyk) and [@hispanico94](https://github.com/hispanico94) for raising the issues._
- **Naming collision with `Selection` type from apollo ([#2708](https://github.com/apollographql/apollo-ios/issues/2708)):** `ParentType` and `Selection` types in generated selection sets now use a fully qualified namespace to prevent typename conflicts. [#2754](https://github.com/apollographql/apollo-ios/pull/2754) - _Thank you to [@tahirmt](https://github.com/tahirmt) for raising the issue._
- **Namespace collision when using "Schema" for `schemaName` ([#2664](https://github.com/apollographql/apollo-ios/issues/2664)):** Certain strings are now disallowed for use as the schema namespace. [#2755](https://github.com/apollographql/apollo-ios/pull/2755) - _Thank you to [@StarLard](https://github.com/StarLard) for raising the issue._
- **Naming collision with fragments and scalars ([#2691](https://github.com/apollographql/apollo-ios/issues/2691)):** Shared referenced schema types will always use the fully qualified names as the types of fields in selections sets. This prevents collisions with names of other generated selection sets for entity type fields whose names are the same as a referenced schema type. [#2757](https://github.com/apollographql/apollo-ios/pull/2757) - _Thank you to [@scottasoutherland](https://github.com/scottasoutherland) for raising the issue._
- **Naming collision with `DocumentType` in generated mock code ([#2719](https://github.com/apollographql/apollo-ios/issues/2719)):** All shared referenced schema types within test mocks now use a fully qualified named type. [#2762](https://github.com/apollographql/apollo-ios/pull/2762) - _Thank you to [@dafurman](https://github.com/dafurman) for raising the issue._
- **Schema/Target/Module name with spaces in it breaks generated code ([#2653](https://github.com/apollographql/apollo-ios/issues/2653)):** Spaces are no longer allowed in the schema namespace. Additional validation has been added to the CLI commands to provide the correct error response. [#2760](https://github.com/apollographql/apollo-ios/pull/2760) - _Thank you to [@Narayane](https://github.com/Narayane) for raising the issue._

### Changed
- **Raised minimum required tooling versions:** Swift 5.7 and Xcode 14 are now the minimum required versions to build Apollo iOS and the generated code. [#2695](https://github.com/apollographql/apollo-ios/pull/2695)

## v1.0.5

#### Fixed
- **Fixed - Missing SPM plug-in:** The missing Swift Package product has been added and the `Install CLI` plug-in is now available from the SPM command line and the Xcode project menu. [#2683](https://github.com/apollographql/apollo-ios/pull/2683)

## v1.0.4

#### Fixed
- **Fixed - Convenience initializer for mock objects without fields:** When mock objects did not have any fields a convenience initializer would still be generated causing infinite recursion during initialization. [#2634](https://github.com/apollographql/apollo-ios/pull/2634) _Thank you to [@Gois](https://github.com/Gois) for the contribution!_
- **Fixed - Ambiguous use of operator '??':** When the nil coalescing operator was used on variables without a type the compiler could not determine which one to use. [#2650](https://github.com/apollographql/apollo-ios/pull/2650). _Thanks to [@skreberem](https://github.com/skreberem) for raising the issue._
- **Fixed - Generate library for test mock target:** Previous versions would generate the SPM target for test mocks but not a library to properly import it into your unit tests. [#2638](https://github.com/apollographql/apollo-ios/pull/2638) _Thank you to [@Gois](https://github.com/Gois) for the contribution!_
- **Fixed - Podspec Swift version mismatched with SPM package version:** The Swift version is now the same between the two dependency managers. [#2657](https://github.com/apollographql/apollo-ios/pull/2657)
- **Fixed - Conflicting configuration values:** There is now an error during code generation when the given configuration has conflicting values that cannot be fulfilled. [#2677](https://github.com/apollographql/apollo-ios/pull/2677)
- **Fixed - `DocumentType` namespacing:** The correct module namespacing is now used for `DocumentType` in generated operation code. [#2679](https://github.com/apollographql/apollo-ios/pull/2679)

#### New
- **New - CLI version checker:** This ensures that the version of the CLI being used to generate Swift code is the same as the version of the Apollo iOS dependency being used. [#2562](https://github.com/apollographql/apollo-ios/issues/2562)

#### Changed
- **Changed - Removed SPM plug-ins:** The SPM plug-ins for the CLI commands `init`, `fetch-schema`, and `generate` have been removed. There is a new plug-in to install the CLI and the CLI commands should be used from the command line instead. [#2649](https://github.com/apollographql/apollo-ios/pull/2649)
- **Changed - CLI defaults:** The updated default for the output of operation files is now `.inSchemaModule`, and the `init` command now requires a module type to be specified when creating a configuration file. [#2673](https://github.com/apollographql/apollo-ios/pull/2673)

## v1.0.3

- **Fixed - Generated code produces compile error when accessing `data` dictionary in the `InputDict` struct if the name of the accessed property is `hash`:** Dyanamic Member Lookup has been removed from `InputDict` to prevent potential name clashes. [#2607](https://github.com/apollographql/apollo-ios/pull/2607)
- **Fixed - XCFramework archive builds:** `@inlinable` has been removed from parts of `ApolloAPI` that were preventing xcframework builds with the `BUILD_LIBRARY_FOR_DISTRIBUTION` build setting. [#2613](https://github.com/apollographql/apollo-ios/pull/2613)
- **Fixed - `Variables` type in local cache mutations is not properly namespaced:** The `Variables` type in `LocalCacheMutation` now has the required prefix of `GraphQLOperation` to build successfully. [#2615](https://github.com/apollographql/apollo-ios/pull/2615)
- **Fixed - Return error if no matches to schema or operation search paths:** When a schema file could not be found errors were emitted but they were not indicative of the underlying problem. There is now validation to ensure that at least one match of the schema/operation search paths is found otherwise an error is thrown. [#2618](https://github.com/apollographql/apollo-ios/pull/2618)
- **Fixed - File generation should ignore the `.build`/`.swiftpm`/`.Pods` folders:** If code generation was executed from a path where subfolders contained the apollo-ios repo, it would find internal test schemas and fail. These special folders are now ignored. [#2628](https://github.com/apollographql/apollo-ios/pull/2628)
- **Fixed - Download schema relative to root URL:** Even though a root URL could be provided it was not being used in all schema download logic to output the downloaded schema file to the correct locaiton. This is now fixed. [#2609](https://github.com/apollographql/apollo-ios/pull/2609) _Thanks to [@Anteo95](https://github.com/Anteo95) for the contribution._

## v1.0.2

- **Fixed - Not generating code for subtypes only used as input to mutations:** If you are using a JSON format schema that was fetched via GraphQL introspection code generation will now generate all referenced subtypes. [#2583](https://github.com/apollographql/apollo-ios/pull/2583) _Thank you to [@vrutberg](https://github.com/vrutberg) for reporting the issue._
- **Fixed - When using the test mock, touching a `GraphQLEnum` property will cause a crash:** JSON Encoding the mocks into the `SelectionSet.DataDict` was causing `CustomScalar` values to get encoded into their JSON values. The mock data is now converted into the correct format for the `SelectionSet.DataDict`. [#2584](https://github.com/apollographql/apollo-ios/pull/2584) _Thank you to [@asapo](https://github.com/asapo) for reporting the issue._
- **Fixed - Add namespace for ApolloAPI types in generated code:** The Apollo `DocumentType` enum is now correctly namespaced in generated code. [#2585](https://github.com/apollographql/apollo-ios/pull/2585) _Thank you to [@matijakregarGH](https://github.com/matijakregarGH) for reporting the issue._
- **Fixed - Problems with schema name in generated code:**
  - Schema name is now correctly cased for generated code namespacing. [#2586](https://github.com/apollographql/apollo-ios/pull/2586) _Thank you to [@pchmelar](https://github.com/pchmelar) for reporting the issue._
  - The schema name is now not allowed to match any referenced schema type, entity field, or entity list field names. [#2589](https://github.com/apollographql/apollo-ios/pull/2589)
- **Fixed - Test mocks crash when touching array of objects:** Test mock list of objects is now correctly converted into selection set data. [#2591](https://github.com/apollographql/apollo-ios/pull/2591) _Thank you to [@konomae](https://github.com/konomae) for reporting the issue._
- **Fixed: `GraphQLNullable` nil coalescing:** @exported import statements now ensure that the operator overload is imported when using the generated models. [#2600](https://github.com/apollographql/apollo-ios/pull/2600) _Thank you to bassrock for reporting the issue._

## v1.0.1

- **Fixed - apollo-ios-cli code generation on CocoaPods installation:** All required resources for the CLI are now bundled correctly. This was an issue in CocoaPods installations where the `generate` command of `apollo-ios-cli` would result in a fatal error. [#2548](https://github.com/apollographql/apollo-ios/pull/2548) _Thank you to [@ilockett](https://github.com/ilockett) for reporting the issue._
- **Fixed - Xcode integration for Swift Package Plugins:** The SwiftPM plugins now support `XcodePluginContext` from Xcode 14 and accepts the additional command line options that Xcode sends. [#2554](https://github.com/apollographql/apollo-ios/pull/2554) _Thank you to [@SilverTab](https://github.com/SilverTab) for reporting the issue._
- **Fixed - Escaping input param names:** Input parameter names recognized as reserved words are now escaped to prevent build errors. [#2561](https://github.com/apollographql/apollo-ios/pull/2561) _Thank you to [@puls](https://github.com/puls) for the contribution._
- **Fixed - Multiline deprecation messages:** Deprecation messages that span multiple lines would previously result in build errors. [#2579](https://github.com/apollographql/apollo-ios/pull/2579) _Thank you to [@TizianoCoroneo](https://github.com/TizianoCoroneo) for the contribution._  
- **Changed - Warnings for deprecated enums:** Deprecated enum cases are no longer annotated with the Swift `@available` attribute. They will now have comments indicating their deprecated status. [#2579](https://github.com/apollographql/apollo-ios/pull/2579)

## v1.0.0

**This is the first major version release of Apollo iOS! The primary goal of Apollo iOS 1.0 is to stabilize the API of the model layer and provide a foundation for future feature additions and evolution of the library.**

In a nutshell, v1.0.0 brings:
* A new code generation engine built entirely in Swift
* Improvements to the generated models
* Syntax and performance improvements across the entire library

There is [documentation](https://www.apollographql.com/docs/ios) and a blog post coming soon. Feel free to ask questions by either [opening an issue on our GitHub repo](https://github.com/apollographql/apollo-ios/issues), or [joining the community](https://community.apollographql.com/tags/c/help/6/mobile).

Thank you to all contributors who have helped us get to this first major release! ❤️

## v1.0.0-rc.1 - Release Candidate #1

This is the first Release Candidate for Apollo iOS 1.0. The Release Candidate is a fully featured and code-complete representation of the final 1.0 version. This includes full feature parity with the 0.x.x releases.

API breaking changes are not expected between the Release Candidate and the General Availability (GA) release. The only code changes will be non-breaking bug fixes due to user feedback. The Release Candidate does not have complete documentation or usage guides, which will be completed prior to GA.

This first major version will include a new code generation engine, better generated models, and many syntax and performance improvements across the entire library. The primary goal of Apollo iOS 1.0 is to stabilize the API of the model layer and provide a foundation for future feature additions and evolution of the library.

* **New: Option to Include Deprecated Input Arguments on Fields During Schema Download** Thanks to [@dave-perry](https://github.com/dave-perry) for this addition!
* **Fixed: Code Generation Config JSON File Compatibility** 
  * Previously, the `apollo-codegen-config.json` file used by the Apollo CLI needed to contain values for all optional fields. When new codegen options were added, this would cause errors until all newly added options has values provided. 
  * The `Codable` implementation for the `ApolloCodgenConfiguration` has been implemented manually to prevent this. Now, only required fields must be provided, all optional fields can be omitted from the config file safely. 
  * The CLI's `init` command also now generates a template config file with only the required fields.
* **Fixed: Swift Keywords are escaped when used as names of Input Parameters**
* **Fixed: Compilation Error when using `@skip` and `@include` conditions on the same field**
* **Fixed: Added permissions request to SPM Code Generation Plugin**
  * When running the code generation plugin, you will be prompted to give permission for the plugin to write to the package directory.
  * This permission check can be avoided by passing the `--allow-writing-to-package-directory` flag when executing the plugin command.
* **Fixed: APQ Operations Will no Longer be Retried when Unrecognized if using `.persistedOperationsOnly`**
  * `.persistedOperationsOnly` is for use with allow-listed operations only. If an operation identifier is not recognized by the server, there is no way to register the operation in this configuration.   
* **Breaking: Updated `ApolloAPI` internal metadata properties to be `__` prefixed.**
  * Generated GraphQL files expose certain properties/functions that are consumed by the `Apollo` library during GraphQL Execution. These members must be public in order to be exposed to `Apollo`, but are not intended for external consumption. We have added underscore prefixes to each of these members to signify that intention, using `__` for GraphQL Metadata (in alignment with the GraphQL Specification) and `_` for `Apollo`'s utility and helper functions.
  * The affected signatures are:
    * `SelectionSet.schema` -> `SelectionSet.__schema`
    * `SelectionSet.selection` -> `SelectionSet.__selection`
    * `JSONEncodable.jsonValue` -> `JSONEncodable._jsonValue`
    * `JSONDecodable.init(jsonValue:)` -> `JSONDecodable.init(_jsonValue:)`
    * `AnyHashableConvertible.asAnyHashable` -> `AnyHashableConvertible._asAnyHashable`
    * `OutputTypeConvertible.asOutputType` -> `OutputTypeConvertible._asOutputType`
    * `GraphQLOperation.variables` -> `GraphQLOperation._variables`
    * `LocalCacheMutation.variables` -> `LocalCacheMutation._variables`

## v1.0.0-beta.4

This is the fourth Beta Release of Apollo iOS 1.0. The Beta version has full feature parity with the 0.x.x releases. The API is expected to be mostly stable. Some breaking changes may occur due to user feedback prior to General Availability (GA) Release. The Beta does not have complete documentation or usage guides, which will be completed prior to GA.

This first major version will include a new code generation engine, better generated models, and many syntax and performance improvements across the entire library. The primary goal of Apollo iOS 1.0 is to stabilize the API of the model layer and provide a foundation for future feature additions and evolution of the library.

* **Breaking: Generated Files now have the file extension `.graphql.swift`.**
  * This allows you to clearly distinguish which files in your project are Apollo generated files.
  * Generated template files that are user-editable will still have the `.swift` file extension. 
    * `CustomScalar` templates as well as the `SchemaConfiguration` file are user-editable. Once these are generated, they are never overwritten by future code generation execution.
  * This change is also necessary for the identification of generated files for the pruning functionality.
* **New: Pruning of Unused Generated Files**
  * Generated files that no longer should exist are automatically deleted now. This occurs when a `.graphql` file is removed from your project. The generated file will also be deleted the next time code generation is run.
  * This can be disabled with the new `pruneGeneratedFiles` codegen option.
  * **Breaking: Automatic Deletion will not delete files generated in previous Alpha/Beta versions.**
    * Only files with the `.graphql.swift` file extension will be deleted.
    * If you have used previous Alpha/Beta versions, you will need to delete your generated files manually one last time before running code generation with this version.
* **New: Enum Case Names are Converted to Camel Case in Generated Enums.** 
  * **Breaking: This is enabled by default, your call sites will need to be updated.**
  * Camel case conversion for enum cases can be disabled with the new `conversionStrategies.enumCases` codegen option.
  * Thanks [@bannzai](https://github.com/bannzai) for this one!
* **Fixed: Swift Keywords are escaped when used as names of Enum Values** Thanks [@bannzai](https://github.com/bannzai) for the fix!
* **Fixed: Compilation Error when Using Fragment with Lowercased Name** This was an edge case that only occured when referencing a nested, merged selection set from the lowercase named fragment.
* **Fixed: Retain Cycle in `ReadTransaction`** Thanks [@lorraine-hatch](https://github.com/lorraine-hatch) for the fix!
* **Fixed: String `jsonValue` Initializer for Large Numbers** Thanks [@Almaz5200](https://github.com/Almaz5200) for the fix!

## v1.0.0-beta.3

This is the third Beta Release of Apollo iOS 1.0. The Beta version has full feature parity with the 0.x.x releases. The API is expected to be mostly stable. Some breaking changes may occur due to user feedback prior to General Availability (GA) Release. The Beta does not have complete documentation or usage guides, which will be completed prior to GA.

This first major version will include a new code generation engine, better generated models, and many syntax and performance improvements across the entire library. The primary goal of Apollo iOS 1.0 is to stabilize the API of the model layer and provide a foundation for future feature additions and evolution of the library.

* **Breaking: Changed the generated Schema files** 
  * The schema will now have two generated files, `SchemaMetadata.swift` and `SchemaConfiguration.swift.`
  * We wanted to more clearly separate the parts of the schema that are generated for you (metadata) from the parts that you can configure yourself (configuration).    
  * **If you were using the last beta, you’ll need to move your cache key resolution logic into `SchemaConfiguration.swift`. You should also delete the old generated files.*
  * *We will be implementing automatic deletion of generated files that should no longer be part of your project in a future beta, so you won't need to delete those files manually anymore.*
* **New: Added SPM Plugin for Code Generation CLI**
  * When including Apollo iOS via Swift Package Manager, the Code Generation CLI is now accessible as an SPM Plugin.
  * After installing the `apollo-ios` package, run `swift package --disable-sandbox apollo-initialize-codegen-config` to create the codegen configuration file.
  * Then you can run `swift package --disable-sandbox apollo-generate` to run code generation.
  * The `--disable-sandbox` or `--allow-writing-to-directory .` arguments must be used when running the Code Generation CLI via the SPM plugin to give the plugin permission to write the generated files to the output directory configured in your codegen configuration file. 
* **Fixed: Compilation errors when schema types had lowercase names**
* **Fixed: Codegen engine crashing in specific situations** 
  * There were some bugs in the codegen compiler when merging nested fragments with non-matching parent types and using default values for input object list fields.
* **Fixed: Issues with websocket reconnections** Thanks [@STomperi](https://github.com/STomperi) for the fix!

## v1.0.0-beta.2

This is the second Beta Release of Apollo iOS 1.0. The Beta version has full feature parity with the 0.x.x releases. The API is expected to be mostly stable. Some breaking changes may occur due to user feedback prior to General Availability (GA) Release. The Beta does not have complete documentation or usage guides, which will be completed prior to GA.

This first major version will include a new code generation engine, better generated models, and many syntax and performance improvements across the entire library. The primary goal of Apollo iOS 1.0 is to stabilize the API of the model layer and provide a foundation for future feature additions and evolution of the library.

**Breaking: Changed API for Cache Key Configuration:** Cache Key Resolution is now easier to configure. See `CacheKeyInfo` for examples and documentation.
**Breaking: Changed API for generated Schema Types to support dynamic types** The API for generated schema types now initializes instances of `Object`, `Interface`, and `Union` for each corresponding type in your schema. These are still generated by the code generation engine. This differs from the previous API which generated static types that were subclasses of `Object`, `Interface`, and `Union`. The change provides the API to support the future addition of dynamic types added to your schema at runtime.
**New: Codegen CLI will now automatically create output directories:** You no longer are required to have already created all intermediary directories for your codegen output paths prior to running code generation. 
**New: Codegen CLI is built locally with CocoaPods installations:** This is to ensure that the version of the Codegen CLI is the same as ApolloCodegenLib. This behaviour will be extended to Swift Package Manager installations too.
**New: Swift Keywords are escaped when used as names of fields or types in generated objects:** Previously, using Swift keywords (eg. `self`, `protocol`, `Type`) as the names of fields in your operations or types in your schema would cause compilation errors in your generated code. Now, these names will be escaped with backticks to prevent compiler errors. **The names `\_\_data` and `fragments` cannot be used as field names as they conflict with Apollo's generated object APIs** Using these names will result in a validation error being thrown when attempting to run the code generation engine.
**Fixed: Fragments with lowercase names caused compilation errors:** This bug is fixed. Fragments with lowercase names will be correctly uppercased when referencing the generated `Fragment` objects. 
**Fixed: Build errors in Xcode 14/Swift 5.7:** The library was updated to support the Swift 5.7 language version. Swift 5.6 is still supported. 
**Fixed: Xcode 14 does not support Bitcode:** Starting with Xcode 14, bitcode is no longer required for watchOS and tvOS applications, and the App Store no longer accepts bitcode submissions from Xcode 14.  
**Fixed: "No such module `ApolloAPI`" error when using CocoaPods:** The podspec was not configured to import all required source files and some import statements were unnecessary in a CocoaPods environment. A code generation configuration option was added to order to ensure generated files are generated with the correct import statements in a CocoaPods environment. **When generating code for a project that includes `Apollo` via Cocoapods, you must set the `cocoapodsCompatibleImportStatements` option to `true` in your `ApolloCodegenConfiguration`.** When using the Codegen CLI that is built for you during `pod install` the `apollo-ios-cli init` command will default this option to `true`. When building the Codegen CLI in by other method, this option will default to `false`.  
**Removed: ApolloUtils target no longer necessary:** The things that used to be shared here are actually no longer shared. There is no code shared between the `Apollo` and `ApolloCodegenLib` targets.  
**Removed: ApolloCodegenConfiguration.validation:** This method was incorrectly requiring destination paths to exist before code generation. Once that was removed it was no longer necessary. Any errors that are encountered with destination output paths will be raised during code generation.

## v1.0.0-beta.1

This is the first Beta Release of Apollo iOS 1.0. The Beta version has full feature parity with the 0.x.x releases. The API is expected to be mostly stable. Some breaking changes may occur due to user feedback prior to General Availability (GA) Release. The Beta does not have complete documentation or usage guides, which will be completed prior to GA.

This first major version will include a new code generation engine, better generated models, and many syntax and performance improvements across the entire library. The primary goal of Apollo iOS 1.0 is to stabilize the API of the model layer and provide a foundation for future feature additions and evolution of the library.

* **New: Additional Generated Code Output Configuration Options.**
  * `queryStringLiteralFormat`: Configures how the generated operations render the operation document source. Either multi-line (as defined in operation definition) or minified to a single line.
  * `schemaDocumentation`: Documentation of fields and objects from your schema will now be included as in-line documentation on generated objects. This can be disabled by setting `schemaDocumentation` to `.excluded` in your codegen configuration.
  * `warningsOnDeprecatedUsage`: Adds warning annotation when using fields and arguments in generated operations that are deprecated by the schema.
  * `additionalInflectionRules`: Allows you to configure custom singularization rules for generated fields names.
* **New: Support Automatic Persisted Queries:** APQs are now fully functional. *Note: Legacy operation safelisting support may experience issues in some cases.* If you have problems using operation safelisting, please create an issue so that we may understand and resolve the edge cases in the safelisting process. 
* **Fixed: Singularization of plural names for non-list fields.**
* **Fixed: Runtime failure on execution of operations with InputObjects.**
* **Fixed: `__typename` field no longer generated when manually included:** `__typename` is automatically included in all operations and fragments and has a default property on all Selection Sets. Generating the field was redundant and caused compilation errors.

## v1.0.0-alpha.8

This is the eighth Alpha Release of Apollo iOS 1.0. This first major version will include a new code generation engine, better generated models, and many syntax and performance improvements across the entire library. The primary goal of Apollo iOS 1.0 is to stabilize the API of the model layer and provide a foundation for future feature additions and evolution of the library.

* **New: Added `Equatable` and `Hashable` Conformance to public API Models:** Object's like `GraphQLRequest` and `GraphQLError` now can be compared!
* **New: Code Generation now supports Schema Extensions**.
* **Fixed: Namespacing and Access Control on Generated Models:** Generated models were failing to compile due to namespacing and access control issues in certain code generation configurations. This is fixed now!
* **Improved: Custom Scalar Default Float Behavior:** If the response for a custom scalar is provided as a `Float`, it will automatically be converetd to a `String` (just like it's always done for `Int`).
* **Improved: GraphQL Float now treated as Swift Double:** The `Float` defined in the GraphQL spec is actually compliant with a Swift `Double`. Generated code will now generate Swift code with fields of type `Double` for GraphQL `Float`.
* **Improved: Rename `SelectionSet.data` to `SelectionSet.__data`:** This is to prevent naming conflicts with GraphQL fields named `data`.
* **Fixed: `graphql_transport_ws` protocol now sends 'complete' to end subscription:** The protocol implementation was previously sending the wrong message to close the connection.
* **Improved: Generated Operations Folder Structure:** The generated output folder structure for fragments and operations are now organized into sub-folders.
* **New: Introspection Schema Download can output JSON:** Schema downloads via Introspection now support output as JSON instead of only SDL. Note that Apollo Registry schema downloads still only support SDL as the output.

## v1.0.0-alpha.7

This is the seventh Alpha Release of Apollo iOS 1.0. This first major version will include a new code generation engine, better generated models, and many syntax and performance improvements across the entire library. The primary goal of Apollo iOS 1.0 is to stabilize the API of the model layer and provide a foundation for future feature additions and evolution of the library.

* **New: Local Cache Mutations are now supported:** In order to perform a local cache mutation, define a `.graphql` file with an operation or a fragment and mark it with the directive `@apollo_client_ios_localCacheMutation`. This will ensure the code generator generates a mutable cache mutation operation.
  * **Note: Local Cache Mutation operations cannot be used for fetching from the network!** You should define separate GraphQL operations for network operations and local cache mutations.
  * Example Usage:
  
```graphql
/// SampleLocalCacheMutation.graphql
query SampleLocalCacheMutation @apollo_client_ios_localCacheMutation {
  allAnimals {
    species
    skinCovering
    ... on Bird {
      wingspan
    }
  }
}

/// SampleLocalCacheMutationFragment.graphql
fragment SampleLocalCacheMutationFragment on Pet @apollo_client_ios_localCacheMutation {
  owner {
    firstName
  }
}
```
  
* **New: Support Code Generation Configuration Option: `deprecatedEnumCases`:** If `deprecatedEnumCases` is set to `exclude`, deprecated cases in graphql enums from your schema will not be generated and will be treated as unknown enum values.  
* **Fixed - Compilation Errors in Generated Code When Schema was Embedded In Target:** When embedding the generated schema in your own target, rather than generating a separate module for it, there were compilation errors due to access control and namespacing issues. These are resolved. This fixes #2301 & #2302. Thanks [@kimdv](https://github.com/kimdv) for calling attention to these bugs!
  * **Note: Compilation Errors for Test Mocks are still present.** We are aware of ongoing issues with generated test mocks. We are actively working on fixing these issues and they will be resolved in a future alpha release soon.
* **Fixed: Crash When Accessing a Conditionally Included Fragment That is Nil.** This is fixed now and will return `nil` as it should. This fixes #2310.

## v1.0.0-alpha.6

This is the sixth Alpha Release of Apollo iOS 1.0. This first major version will include a new code generation engine, better generated models, and many syntax and performance improvements across the entire library. The primary goal of Apollo iOS 1.0 is to stabilize the API of the model layer and provide a foundation for future feature additions and evolution of the library.

* **New: Objects and InputObjects are now equatable:** Many objects now conform to `AnyHashable` bringing with them the ability to conform to `Equatable`, this should make tests easier to write.
* **Change: GraphQLOperation fields are now static:** Previously an instance of a GraphQLOperation was required to query any of it's properties, you can do that on the type now.
* **Fixed - Nested fragment type cases:** Nested fragment type cases were not being generated causing a crash in selection set generation.
* **New - Code generation now has a CLI:** A new command line executable has been built and will be available on Homebrew very soon! Check it out [here](https://github.com/apollographql/apollo-ios/tree/release/1.0/CodegenCLI).
* **Fixed - SelectionSet and InlineFragment protocol definitions:** These were incorrectly being generated within the namespace when a module of type `.embeddedInTarget` was being used.
* **Fixed - Test mock convenience initializers:** These were incorrectly definining parameter types for Interface and Union fields and the generated package could not successfully build.

## v1.0.0-alpha.5

This is the fifth Alpha Release of Apollo iOS 1.0. This first major version will include a new code generation engine, better generated models, and many syntax and performance improvements across the entire library. The primary goal of Apollo iOS 1.0 is to stabilize the API of the model layer and provide a foundation for future feature additions and evolution of the library.

* **Test Mocks are now supported!**
  * Test mocks can be generated to make it much easier to create mocks of your generated selection sets for unit testing.
  * This long requested feature can be enabled in your code generation config with the option `config.output.testMocks`.
  * Once you've generated test mocks, import the new `ApolloTestSupport` target (as well as your generated mocks) in your unit tests to start.
  * More documentation for test mocks will be coming soon. In the mean time, here is some example usage: 

```swift
let mockDog = Mock<Dog>()
mock.species = "Canine"
mock.height = Mock<Height>(feet: 3, inches: 6)

// To mock an object in a generated operation:
let generatedDogMock: AnimalQuery.Data.Animal = AnimalQuery.Data.Animal.mock(from: mockDog)

// To mock an entire query:
let queryMock = Mock<Query>()
queryMock.animals = [mockDog]
let generatedSelectionSetMock: AnimalQuery.Data = AnimalQuery.Data.mock(from: queryMock)
```

* `GraphQLNullable` and `GraphQLEnum` from the `ApolloAPI` target are now exported by your generated operations. This prevents you from having to `import ApolloAPI` everywhere that you are consuming your generated models.
* `CacheKeyProvider` now supports grouping multiple types that share key uniqueness.   
* Lots of performance improvements
  * Using `StaticString` instead of `String` in generated files.
  * Added `@inlinable` to many `ApolloAPI` functions consumed by generated code.
  * And more!

## v1.0.0-alpha.4

This is the fourth Alpha Release of Apollo iOS 1.0. This first major version will include a new code generation engine, better generated models, and many syntax and performance improvements across the entire library. The primary goal of Apollo iOS 1.0 is to stabilize the API of the model layer and provide a foundation for future feature additions and evolution of the library.

* **Client Controlled Nullability (CCN) is now supported!**
  * CCN is an experimental new feature addition to GraphQL. This feature allows you to override the optionality of fields from a schema in your client operations. CCN can help you create cleaner generated models that require less optional unwrapping.
  * You can read more about CCN [here](https://github.com/graphql/graphql-spec/issues/867). 
  * Because CCN is an experimental feature, the API is subject to change before its final release.
  * Apollo iOS 1.0.0 is the first client to provide support for this new functionality! Huge thanks to [@twof](https://github.com/twof)!
* **Fixed - Names of generated objects are now correctly uppercased.**
* **Fixed - Names of inline fragments with inclusion conditions were sometimes generated incorrectly.**
* **Fixed - `__typename` field is now selected by executor on all entities automatically.**

## v1.0.0-alpha.3

This is the third Alpha Release of Apollo iOS 1.0. This first major version will include a new code generation engine, better generated models, and many syntax and performance improvements across the entire library. The primary goal of Apollo iOS 1.0 is to stabilize the API of the model layer and provide a foundation for future feature additions and evolution of the library.

* **Include/Skip Directives are now supported!**
  * Adding `@include/@skip` directives to fields, inline fragments, or fragment spreads will now generate code that respects the optionality of these conditionally included selections.
* **Changed - Generated TypeCase renamed to InlineFragment** These are now used for both type cases and inline fragments that are conditionally included using `@include/@skip` directives. 
* **Custom Scalars are now supported!**
  * Template Files will be generated for custom scalars. The template files `typealias` each custom scalar to a `String` by default. These generated files can be edited to provide custom functionality for advanced custom scalars. Custom scalar template files that have been edited will not be overwritten on later code generation executions.    
* **Improved multi-module support** 
  * Including your generated code using package managers other than SPM can be done using the `.other` option for `moduleType` in your code generation configuration.  
* **Nil Coalescing Operator added to `GraphQLNullable`
  * This allows for optional variables to easily be used with `GraphQLNullable` parameters and a default value

```swift
class MyQuery: GraphQLQuery {

  var myVar: GraphQLNullable<String>

  init(myVar: GraphQLNullable<String> { ... }
 // ...
}

let optionalString: String?

// Before

let query = MyQuery(myVar: optionalString.map { .some($0) } ?? .none)

// After
let query = MyQuery(myVar: optionalString ?? .none)
```
* **Fixed - `fragments` not accessible on generated `SelectionSet`s.
* **Fixed - `__typename` is now added to all operation and fragment definitions.
* **Fixed - Missing Generated Interface Types** 
  * Interface types that were only referenced as an implemented interface of a referenced concrete type were not being generated previously.

## v1.0.0-alpha.2

This is the second Alpha Release of Apollo iOS 1.0. This first major version will include a new code generation engine, better generated models, and many syntax and performance improvements across the entire library. The primary goal of Apollo iOS 1.0 is to stabilize the API of the model layer and provide a foundation for future feature additions and evolution of the library.

* **Operation Variables and Field Arguments are now supported!**
* **Fixed - Capitalized field names generate code that doesn't compile**[#2167](https://github.com/apollographql/apollo-ios/issues/2167) 

## v1.0.0-alpha.1

This is the first Alpha Release of Apollo iOS 1.0. This first major version will include a new code generation engine, better generated models, and many syntax and performance improvements across the entire library. The primary goal of Apollo iOS 1.0 is to stabilize the API of the model layer and provide a foundation for future feature additions and evolution of the library.

### What’s New

* The size of generated code has been reduced dramatically. In the most complex operations, the generated code can be up to **90% smaller** than in the previous version.
* Generated response objects are more powerful and easier to consume.
    * The response objects now intelligently merge fields from not only their parents, but also other matching siblings.

```
query AnimalQuery {
  allAnimals {
    species
    ... on Pet {
      name
    }
    ... on Cat {
      furColor
    }
}
```

In the past, the `AsCat` model would have fields for `species`, and `furColor`, but to access the `name` field, you would need to keep a reference to the `AllAnimal` object and call `AsPet.name`. This means that you couldn’t just pass the `AsCat` object to a UI component. 

In 1.0, because we know that `Cat` implements the `Pet` interface, the `name` field is merged into the `Cat` object. 

*Any property that should exist based on the type of the object will be accessible.* This makes consuming our generated response objects in your applications much easier. This should greatly reduce the need for view models to wrap our generated response objects.

* The code generation engine is now written in native Swift! This makes it easier for Swift developers to contribute to the project or alter the generated code for their specific needs! In future iterations, we hope to open up the code generation templating API to allow for even easier customization of your generated code!
* Computation of Cache Keys is protocol oriented now. Instead of a single `cacheKeyForObject` closure on your `ApolloClient`, you can implement cache key computation on individual object types with the `CacheKeyProvider` protocol. See [Cache Key Resolution](https://github.com/apollographql/apollo-ios/blob/release/1.0-alpha-incubating/CodegenProposal.md#cache-key-resolution) in the RFC for more information.

## v0.53.0
- **Remove all instances of bitcode as not supported in Xcode 14**: Starting with Xcode 14, bitcode is no longer required for watchOS and tvOS applications, and the App Store no longer accepts bitcode submissions from Xcode 14. [#2398](https://github.com/apollographql/apollo-ios/pull/2398) - _Thanks to [@stareque-atlassian](stareque-atlassian) for the contribution!_

## v0.52.0
- **Add codegen option for excludes**: There is a new property on the codegen configuration options to allow files matching the pattern to be excluded, in the case they are found in the `includes` path. [#2205](https://github.com/apollographql/apollo-ios/pull/2205) - _Thanks to [@bannzai](https://github.com/bannzai) for the contribution!_
- **Fixed - Using the `graphql_transport_ws` protocol could result in `4400` errors from the server**: The correct protocol message is now being sent to the server to end communication. [#2320](https://github.com/apollographql/apollo-ios/pull/2320)
- **Replace `print` statement with `CodegenLogger.log`**: All codegen output is logged with `CodegenLogger` which can be disabled if needed. [#2348](https://github.com/apollographql/apollo-ios/issues/2348) - _Thanks to [@hiltonc](https://github.com/hiltonc) for the contribution!_
- **Expose `GraphQLResultError` path string**: Adds a new publicly available computed property to `GraphQLResultError` which just exposes the `path` description. [#2361](https://github.com/apollographql/apollo-ios/pull/2361) - _Thanks to [@joshuashroyer-toast](https://github.com/joshuashroyer-toast) for the contribution!_

## v0.51.2
- **Fixed - APQ Retrying Failing in 0.51.1**: Fixes a bug introduced in the last version that broke APQs. _Thanks to [Kyle Browning](https://github.com/kylebrowning) for bringing this to our attention._

## v0.51.1
- **Expose request body creation to better support custom interceptors**: Enable lazy access to the request body creation for leverage in custom built interceptors, since JSONRequest.toURLRequest() encapsulates the creation. This enables the GraphQLMap to be accessed without re-creating the body. [#2184](https://github.com/apollographql/apollo-ios/pull/2184) - _Thanks to [Rick Fast](https://github.com/rickfast) for the contribution._

## v0.51.0
- **Allow periods in arguments to be ignored when parsing cacheKeys**: If your query arguments include periods they will no longer cause broken cache keys. This means the cached data for those queries can be correctly found and returned. The caveat with this change though is that if you use a persisted cache, after the upgrade you could see cache misses and the data would be refetched. [#2057](https://github.com/apollographql/apollo-ios/pull/2057) - _Thanks to [Hesham Salman](https://github.com/Iron-Ham) for the contribution._
- **Fixed - [`Sendable` class `JavaScriptError` cannot inherit from another class other than `NSObject`](https://github.com/apollographql/apollo-ios/issues/2146):** Xcode 13.3 introduced some additional requirements for `Error` types and `JavaScriptError` did not conform causing compile errors in `ApolloCodegenLib`. This change disables `Sendable` type checking for `JavaScriptError` while maintaining type-safety across concurrency boundaries. [#2147](https://github.com/apollographql/apollo-ios/pull/2147) - _Thank you to [Tiziano Coroneo](https://github.com/TizianoCoroneo) for the contribution._
- **Fixed - [Watcher using a policy that shouldn't hit the network, can still hit the network](https://github.com/apollographql/apollo-ios/issues/2170):** If the cache policy given to the `watch(query:cachePolicy:)` method of `ApolloClient` was `.returnCacheDataDontFetch` it could still trigger a remote fetch of the query. - _Thank you to [Peter Potrebic](https://github.com/potrebic) for raising the issue._
- **BREAKING CHANGE - [`graphql-ws` Protocol Support](https://github.com/apollographql/apollo-ios/issues/1622):** We've added official support for the [graphql-ws](https://github.com/enisdenjo/graphql-ws) library and its [`graphql-transport-ws`](https://github.com/enisdenjo/graphql-ws/blob/master/PROTOCOL.md) protocol. This is a breaking change because the `WebSocket` initializers now require you to specify which protocol to use.

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
