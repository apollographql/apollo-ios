# iOS Codegen Proposal

# Overview

This document provides explanation, context, and examples for a proposal for the new code generation for iOS.

> **Example code in this document is used only to illustrate the concepts being discussed, as is not comprehensive. Actual generated objects may have additional properties, functions, or nested types to support all functionality. For an examples of an entire generated operation, see the [Example Generated Output](Tests/ApolloCodegenTests/AnimalKingdomAPI/ExpectedGeneratedOutput/Queries/AllAnimalsQuery.swift) in the repository.**

## Key Changes in 1.0

While the generated models in version 1.0 look much different than the current generated code, under the hood, they function relatively similarly. Though there are a few important functional differences, they are still structs backed by a dictionary of keys and values. Consuming your response data looks very similar to the previous version. Fragments and Type Cases are still accessed as nested objects. **The most noticeable difference is that the generated code will be a fraction of its previous size and should be much easier to read and understand!**

The most important functional differences are:

### Immutable Response Objects

The generated response objects are now immutable. This allows for the generated code to be much more compact. Previously, fields on the generated models could be mutated, however this was not used for mutating objects server-side. Response objects could be mutated and then saved to the local cache to make manual cache mutations.

The ability to mutate the local cache will implemented by using mutable fields on generated schema types in a follow-up to this RFC. This will be implemented prior to the 1.0 release.

Local cache mutations using response objects had a number of limitations:
- Cache data could only be mutated in the scope of a defined operation. 
- Validation of mutated data was weak.
  - In certain edge cases, data that would be invalid according to the schema could be inserted in the local cache. This could cause failures when reading cached data. In the worst case scenario, this could result in runtime crashes.
- Data that had not yet been fetched from the server was difficult to insert in the local cache.   
  - This was especially problematic when wanting to add values for Non-null fields on partially fetched objects.

### Generated Schema Types

In addition to generating the immutable operation response data models, the new codegen generates "Schema Types". Schema Types represent the backing types defined on the GraphQL schema itself. These objects provide metadata that is used by the Apollo Client under the hood to understand the relationships between the types in your generated operation response models. These generated Schema Types will also be expanded prior to the 1.0 release to include fields that allow for local cache mutations. For more information, see [Schema Type Generation](#schema-type-generation).

### Fragment Fields Are Always Merged In

In previous versions of the Code Generation tool, this functionality was exposed via the `mergeInFieldsFromFragmentSpreads` option, which defaulted to `false`. Merging in fragment fields provides for easier consumption of generated models, but it also increases the size of the generated code. Because the size of the generated code is being dramatically reduced with the new Code Generation tooling, we have opted to always merge in fragment fields. If generated code size becomes a concern with the new Code Generation, adding an option to disable fragment merging may be considered in the future. For an example of this see [Merging Fragment Fields Into Parent `SelectionSet`](#merging-fragment-fields-into-parent-selectionset)

### CacheKeyProvider

For normalization of cache data, a mechanism for providing unique cache keys for entities is necessary. In the previous version of Apollo, this was configured via a single `cacheKeyForObject` closure that could be set on the `ApolloClient`. In version 1.0, this configuration will move to extensions on the Schema Types. For more information, see [Cache Key Resolution](#cache-key-resolution)

### GraphQLNullable

The previous Apollo versions used double optionals (`??`) to represent `null` vs `nil` input values. This was unclear to most users and make reading and reasoning about your code difficult in many situations. The new version provides a custom enum for this cases named `GraphQLNullable`. For more information, see [Nullable Arguments - GraphQLNullable](#nullable-arguments---graphqlnullable)

### Multiple Module Support

We are excited to say that the 1.0 release of Apollo iOS will support code generation for projects that use multiple modules! There will be multiple options for generating your model objects:

- Single Target
  -  Single Location
     - All files will be generated into a folder that is included in your application target.
  - Co-located Models
    - Generated operation objects will be located relative to the defining `.graphql` file.
    - Schema types will be generated in a single folder.
- Modular (Built-in support for SPM & Cocoapods)
  - Single Location
    - All files will be generated into a folder that can be included as it's own module.
  - Co-located Models
    - Generated operation objects will be located relative to the defining `.graphql` file.
    - Schema types and shared fragments will be generated into a folder that can be included as it's own module.
    
The primary limitation with multi-module support is that code generation must be run on your entire project at one time. You will not be able to run code generation for modules individually at this time. More information about how to generate models for multi-module projects will be coming prior to the 1.0 release.

### Type Case Execution

The logic for generating, validating, and executing selections for Type Cases has changed significantly. While this change is entirely under the hood – it should rarely, if ever, affect the consumer – because the generated code and the way the executor parses Type Cases functionally deviates from it's previous behavior, it is included here.

Type Cases previously included all of the selections that would be selected if the underlying `__typename` of the returned object matched the Type Case. For interfaces, the same TypeCase could be used for multiple different `__typename` values.

In the new generated models, type cases are generated to only select the additional fields that should be selected if the underlying `__typename` matches that type. The executor can now handling selecting multiple different Type Cases for the same object, if it matches multiple Type Cases (ie. A concrete type and an interface). This simplifies the execution logic; reduces the amount of generated code necessary; and makes the generated objects easier to understand.

For more information see [TypeCase Selections](#typecase-selections).

## Objectives

There are a number of reasons to build a new Codegen tool. There are limitations of the current Codegen, as well as improvements and features that can be added with a new Codegen tool that are difficult to address with the current tooling.

### Dependency on Typescript

The current Codegen tooling is written in Typescript, and supports multiple languages. This code base is not maintained and is in a messy state currently. Making changes to this tooling is difficult because of the state of the code and because it must maintain compatibility with generating code for other languages. Additionally, we believe that a Codegen tool written primarily in Swift opens up more opportunity for the community to make contributions in the future. 

### Dependency on NPM

The current Codegen tooling CLI runs as a node package. This requires iOS developers to include an NPM project. This is not ideal, as it adds a lot of cruft to our user’s projects. Since many iOS engineers are not familiar with NPM, the installation and usage of it creates additional hurdles to getting a project started and maintaining projects that iOS engineers struggle with. We have pulled out the GraphQL compiler to work without NPM, and by wrapping it in a Swift library, we can remove the NPM dependency.

### Runtime Performance

This Codegen proposal uses a dictionary of values that are passed around and accessed each time a property is accessed, this has some run time implications as they must be retrieved from the dictionary each time they are accessed. This is similar to the way the current Codegen works.

An alternative approach may map field data onto stored properties on the response object once and only once during parsing, which is typically done on a background thread. However, this approach would require a lot of data duplication and would increase the complexity and size of the generated code considerably.

### Generated Code Size

The size of the generated code for large or complex queries can rapidly become very large under the current CodeGen. This is something we would like to improve upon. Though we understand that there is only so much we can do to reduce code size while accurately reflecting all the data and handling edge cases.

### Generated Code Complexity

The current Codegen generates objects that are often difficult to parse and understand for developers looking at the generated code. While we recognize that the functionality required and edge cases that must be accounted for cause complexity to be inevitable, we hope that the new Codegen can reduce the complexity. This may or may not be possible, and complexity will likely have trade-offs with functionality, generated code size, and other goals.

### Compiled Binary Size

The size of the compiled binary when using our generated data objects must also be considered. Alternatives have been proposed that use classes for models rather than structs to reduce the size of the compiled binary. While classes can reduce binary size, they incurs an additional runtime cost when consumed.

This proposal opts for using lightweight structs that only store a single property in memory — a pointer to their data dictionary. By restricting the size of our structs to a single pointer, we are able to achieve the benefits of structs without incurring the majority of the overhead they create. See [Memory Management and Performance of Value Types](https://swiftrocks.com/memory-management-and-performance-of-value-types) for more information. 

### Compilation Time

We have had customer concerns with the compilation time of large generated queries under the current Codegen. While we recognize that large queries will always add some noticeable time to compilation, it is a goal of this project to minimize the build time impact of our generated data objects.

Easy wins in this aspect of performance can be gained by explicitly providing types where they could be inferred. Other compilation time improvements should be considered and any trade-offs with other goals weighed.

### Memory Allocation

Because response data from a query may be considerably large, it is important to consider the memory usage of our generated data objects. This proposal utilizes multiple mechanisms for minimizing memory usage. 

Because the underlying storage of the current Codegen objects is a dictionary, it is already heap allocated and shared. Accessing fields through different structs (like fragments) does not lead to additional copies of the data. This proposal maintains this functionality.

### Fragment Usage

One of the primary use cases for fragments is for dependency inversion and component reuse. A fragment of data can be used with a UI component or other object, irrespective of the GraphQL operation the data comes from or the other fields that were fetched in addition to the fragments fields.

While the ideal way to provide this functionality is to generate fragments as protocols, which the generated data objects conform to, this does not work. This is due to lack of Swift language support for covariant protocol conformance and protocols with associated types as concrete properties. For more information on this see: [Appendix A: Why Fragment Protocols Don’t Work](#appendix-a-why-fragment-protocols-dont-work)

This proposal aims to provide a simple way to construct fragment objects from the generated data objects.

### Data Validation

Data received in the response of a GraphQL Operation must be validated to ensure that all required fields exist and all objects are valid. The response data objects should return data that is guaranteed to be valid. While the current Codegen does data validation appropriately, it is important to note that this is a required goal of any proposed replacement as well.

### Ease of Use

Our generated objects should be easy to use by the consumer in order to be useful. This involves the structure of the data; the manner in which type cases and fragments are accessed; usage of enums and unions; providing strict type safety and nullability; and enabling code completion for all fields (including merged fields).

Because we cannot understand or determine the optimal structure for each user’s individual use cases, it is likely that many users will use adapters to map our generated data objects onto their own models/view models. This is especially true for users who want to store data in a separate cache, such as `CoreData` or `Realm`. The generated data objects must be structured in a way that provides an easy way to access the data for mapping onto the user’s custom model types.

While we do not expect the generated data objects to be appropriate for every use case, it is our aim to maximize the instances in which custom models/view models are not necessary. This requires type safety, nullability, code completion, and merged fields to work in an intuitive manner. 

### Flexibility

The generated code, as well as the implementation of the code generation tooling, should be architected in a flexible manner that allows for additional features additions to be implemented as easily as possible.

## Example Schema

For all examples in this document, we will use the following schema:

```graphql
type Query {
  allAnimals: [Animal!]!
  allPets: [Pet!]!
  classroomPets: [ClassroomPet!]!
}

interface Animal {
  species: String!
  height: Height!
  predators: [Animal!]!
  skinCovering: SkinCovering
}

interface Pet {
  humanName: String
  favoriteToy: String!
  owner: Human
}

interface HousePet implements Animal & Pet {
  species: String!
  height: Height!
  predators: [Animal!]!
  skinCovering: SkinCovering
  humanName: String
  favoriteToy: String!
  owner: Human
  bestFriend: Pet
  rival: Pet
  livesWith: ClassroomPet
}

interface WarmBlooded implements Animal {
  species: String!
  height: Height!
  predators: [Animal!]!
  skinCovering: SkinCovering
  bodyTemperature: Int!
  laysEggs: Boolean!
}

type Height {
  relativeSize: RelativeSize!
  centimeters: Int!
  meters: Int!
  feet: Int!
  inches: Int!
  yards: Int!
}

type Human implements Animal & WarmBlooded {
  firstName: String!
  species: String!
  height: Height!
  predators: [Animal!]!
  skinCovering: SkinCovering
  bodyTemperature: Int!
  laysEggs: Boolean!
}

type Cat implements Animal & Pet & WarmBlooded {
  species: String!
  height: Height!
  predators: [Animal!]!
  skinCovering: SkinCovering
  humanName: String
  favoriteToy: String!
  owner: Human
  bodyTemperature: Int!
  laysEggs: Boolean!
  isJellicle: Boolean!
}

type Dog implements Animal & Pet & HousePet & WarmBlooded {
  species: String!
  height: Height!
  predators: [Animal!]!
  skinCovering: SkinCovering
  humanName: String
  favoriteToy: String!
  owner: Human
  bodyTemperature: Int!
  laysEggs: Boolean!
  bestFriend: HousePet
  rival: Cat
  livesWith: Bird
}

type Bird implements Animal & Pet & WarmBlooded {
  species: String!
  height: Height!
  predators: [Animal!]!
  skinCovering: SkinCovering
  humanName: String
  favoriteToy: String!
  owner: Human
  bodyTemperature: Int!
  laysEggs: Boolean!
  wingspan: Int!
}

type Fish implements Animal & Pet {
  species: String!
  height: Height!
  predators: [Animal!]!
  skinCovering: SkinCovering
  humanName: String
  favoriteToy: String!
  owner: Human
}

type Rat implements Animal & Pet {
  species: String!
  height: Height!
  predators: [Animal!]!
  skinCovering: SkinCovering
  humanName: String
  favoriteToy: String!
  owner: Human
}

type Crocodile implements Animal {
  species: String!
  height: Height!
  predators: [Animal!]!
  skinCovering: SkinCovering
  age: Int!
}

type PetRock implements Pet {
  humanName: String
  favoriteToy: String!
  owner: Human
}

union ClassroomPet = Cat | Bird | Rat | PetRock

enum RelativeSize {
  LARGE
  AVERAGE
  SMALL
}

enum SkinCovering {
  FUR
  HAIR
  FEATHERS
  SCALES  
}
```

# Core Concepts

In order to fulfill all of the stated goals of this project, the following approach is proposed for the structure of the Codegen:

## `SelectionSet` - A “View” of an Entity

We will refer to each individual object fetched in a GraphQL response as an “entity”. An entity defines a single type (object, interface, or union) that has fields on it that can be fetched. 

A `SelectionSet` defines a set of fields that have been selected to be visible for access on a given entity. The `SelectionSet` determines the shape of the generated response data objects for a given operation.

Given the query:

```graphql
query {
  allAnimals {
    species
    ... on Pet {
      humanName
    }
  }
}
```

Each animal in the list of `allAnimals` is a single entity. Each of those entities has a concrete type (Cat, Fish, Bird, etc.). For each animal entity, we define a group of `SelectionSet`s that exposes the `species` field and, if the entity is a `Pet`, the `humanName` field.

Each generated data object conforms to a `SelectionSet` protocol, which defines some universal behaviors. Type cases, fragments, and root types all conform to this protocol. For reference see [SelectionSet.swift](Sources/ApolloAPI/SelectionSet.swift).

### `SelectionSet` Data is Represented as Structs With Dictionary Storage
---

The generated data objects are structs that have a single stored property. The stored property is to another struct named `ResponseDict`, which has a single stored constant property of type `[String: Any]`.

Often times the same data can be represented by different generated types. For example, when checking a type condition or accessing a fragment on an entity. By using structs with a single dictionary pointer, we are able to reference the same underlying data, while providing different accessors for fields at different scopes. 

This allows us to store all the fetched data for an entity one time, rather than duplicating data in memory. The structs allow for hyper-performant conversions, as they are stack allocated at compile time and just increment a pointer to the single storage dictionary reference.

### Field Accessors
---

Accessors to the fields that a generated object has are implemented as computed properties that access the dictionary storage. 

Let’s start with a simple example to illustrate what the `Fields` object looks like:

**Query Input:**

```graphql
query {
  allAnimals {
    species
    height {
      feet
    }
  }
}
```

**Generated Output:** (`Animal` Object)

```swift
struct Animal: SelectionSet, HasFragments {
  let data: ResponseDict

  var species: String { data["species"] }
  var height: Height { data["height"] }
      
  struct Height: SelectionSet {
    let data: ResponseDict

    var feet: Int { data["feet"] }
  }
}
```

In this simple example, the `Animal` object has a nested `Height` object. Each conforms to `SelectionSet` and each has a single stored property let data: `ResponseDict`. The `ResponseDict` is a struct that wraps the dictionary storage, and provides custom subscript accessors for casting/transforming the underlying data to the correct types. For more information and implementation details, see: [ResponseDict.swift](Sources/ApolloAPI/ResponseDict.swift)

## GraphQL Execution

GraphQL execution is the process in which the Apollo iOS client converts raw data — either from a network response or the local cache — into a `SelectionSet`. The execution process determines which fields should be “selected”; maps the data for those fields; decodes raw data to the correct types for the fields; validates that all fields have valid data; and returns `SelectionSet` objects that are guaranteed to be valid. 

A field that is “selected” is mapped from the raw data onto the `SelectionSet` to be accessed using a generated field accessor. If data exists in the cache or on a raw network response for a field, but the field is not “selected” the resulting `SelectionSet` will not include that data after execution.

Because `SelectionSet` field access uses unsafe force casting under the hood, it is necessary that a `SelectionSet` is only ever created via the execution process. A `SelectionSet` that is initialized manually cannot be guaranteed to contain all the expected data for its field accessors, and as such, could cause crashes at run time. `SelectionSet`s returned from GraphQL execution are guaranteed to be safe.

## Nullable Arguments - `GraphQLNullable`

By default, `GraphQLOperation` field variables; fields on `InputObject`s; and field arguments are nullable. For a nullable argument, the value can be provided as a value, a `null` value, or omitted entirely. In `GraphQL`, omitting an argument and passing a `null` value have semantically different meanings. While often, they may be identical, it is up to the implementation of the server to interpret these values. For example, a `null` value for an argument on a mutation may indicate that a field on the object should be set to `null`, while omitting the argument indicates that the field should retain it's current value -- or be set to a default value.

Because of the semantic difference between `null` and ommitted arguments, we have introduced `GraphQLNullable`. `GraphQLNullable` is a generic enum that acts very similarly to `Optional`, but it differentiates between a `nil` value (the `.none` case), and a `null` value (the `.null` case). Values are still wrapped using the `.some(value)` case as in `Optional`.

The previous Apollo versions used double optionals (`??`) to represent `null` vs ` nil`. This was unclear to most users and make reading and reasoning about your code difficult in many situations. `GraphQLNullable` makes your intentions clear and explicit when dealing with nullable input values.

For more information and implementation details, see: [GraphQLNullable.swift](Sources/ApolloAPI/GraphQLNullable.swift)

# Generated Objects

An overview of the format of all generated object types.

# Schema Type Generation

In addition to generating `SelectionSet`s for your `GraphQLOperation`s, types will be generated for each type (object, interface, or union) that is used in any operations across your entire application. These types will include all the fields that may be fetched by any operation used and can include other type metadata. 

The schema types have a number of functions. 

* Include metadata that allows the `GraphQLExecutor` and runtime type checking on `TypeCase`s to operate. 
* Can be extended to provide cache key computation for types to configure the normalized cache.
* Used for interacting with the cache for manual read/write functionality.
* Used to create mock objects for generated `SelectionSet`s to be used in unit tests.


These schema types can be included directly in your application target, or be generated into a separate shared library that can be used across modules in your application.

Schema types are implemented as `class` objects, not `struct`s. They will use reference type semantics and are mutable within a cache transaction.

## `Object` Types

For each concrete type declared in your schema and referenced by any generated operation, an `Object` subclass is generated. Each `Object` type contains a `static var __metadata` containing a struct that provides a list of the interfaces implemented by the concrete type.

```swift
public final class Dog: Object {
  override public class var __typename: String { "Dog" }

  // MARK: - Metadata
  override public class var __metadata: Metadata { _metadata }
  private static let _metadata: Metadata = Metadata(
    implements: [Animal.self, Pet.self, WarmBlooded.self, HousePet.self]
  )
}
```

## `Interface` Types

For each interface type declared in your schema and referenced by any generated operation, an `Interface` subclass is generated. Interfaces wrap an underlying `Object` type and ensure that only objects of types that they are only initialized with a wrapped object of a type that implements the interface.

```swift
public final class Pet: Interface {}
```

## `Union` Types

For each union type declared in your schema and referenced by any generated operation, a `UnionType` enum is generated. `UnionType` enums have cases representing each possible type in the union. Each case has an associated value of the `Object` type represented by that case. `UnionType` enums are referenced as fields by being wrapped in a `Union<UnionType>` enum that provides access to the underlying `UnionType` and unknown cases. See [Handling Unknown Types](#handling-unknown-types) for more information. `UnionType` enums contain a `static let possibleTypes` property that provides a list of the concrete `Object` types contained in the union.
```swift
public enum ClassroomPet: UnionType, Equatable {
  case Cat(Cat)
  case Bird(Bird)
  case Rat(Rat)
  case PetRock(PetRock)

  public init?(_ object: Object) {
    switch object {
    case let ent as Cat: self = .Cat(ent)
    case let ent as Bird: self = .Bird(ent)
    case let ent as Rat: self = .Rat(ent)
    case let ent as PetRock: self = .PetRock(ent)
    default: return nil
    }
  }

  public var object: Object {
    switch self {
    case let .Cat(object as Object), let .Bird(object as Object), let .Rat(object as Object), let .PetRock(object as Object):
      return object
    }
  }

  static public let possibleTypes: [Object.Type] =
    [AnimalKingdomAPI.Cat.self, AnimalKingdomAPI.Bird.self, AnimalKingdomAPI.Rat.self, AnimalKingdomAPI.PetRock.self]
}
```

## `Schema` Metadata

A `SchemaConfiguration` object will also be generated for your schema. This object will have a function that maps the `Object` types in your schema to their `__typename` string. This allows the execution to convert data (from a network response from the cache) to the correct `Object` type at runtime.

For an example of generated schema metadata see [AnimalKindgomAPI/Schema.swift](Tests/ApolloCodegenTests/AnimalKingdomAPI/ExpectedGeneratedOutput/Schema.swift).

# `EnumType` Generation

Enums will be generated for each `enum` type in the schema that is used in any of the operations defined in your application. These enums will conform to a simple `EnumType` protocol. When used as the type for a field on a `SelectionSet`, these enums will be wrapped in the generic `GraphQLEnum`. Unlike the previous code generation engine, the new code generation will respect the capitalization of the enum cases from the schema.

```swift
enum RelativeSize: String, EnumType {
  case LARGE
  case AVERAGE
  case SMALL
}
```
```swift
struct Animal: SelectionSet {
  // ...
  var size: GraphQLEnum<RelativeSize> { data["size"] }
}
```
`GraphQLEnum` wraps your generated `EnumType`s and provides the `__unknown` case with an associated value of a raw string. This is necessary for clients to provide forward-compatibility with new enum cases added to a schema in the future. `GraphQLEnum` has pattern matching and `Equatable` conformance implemented that allows you to consume it as if it were your underlying `EnumType` in most cases. 

**Examples:**
```swift
let size: GraphQLEnum<RelativeSize> = .init(.SMALL)

size == .SMALL // true
```
When using switch, you must provide a case for the unknown value. 
```swift
switch size {
case .SMALL: break
case .AVERAGE: break
case .LARGE: break
case .__unknown(_): break
default: break
}
```
Because pattern matching is being used to match against the underling `EnumType` cases, you must also provide a default case.

To ensure exhaustive switch cases without a default case your generated cases can be wrapped in `.case()`.
```swift
switch size {
case .case(.SMALL): break
case .case(.AVERAGE): break
case .case(.LARGE): break
case .__unknown(_): break
}
```
If you want to ignore the unknown case, you can access the `.value` field, which returns an optional value of the wrapped type. If the type is an unknown case `.value` will be `nil`.
```swift
switch size.value {
case .SMALL: break
case .AVERAGE: break
case .LARGE: break
default: break 
// or
case .none: break
}
```
See [GraphQLEnum.swift](Sources/ApolloAPI/GraphQLEnum.swift) for implementation details.

# `InputObject` Generation

Input objects will be generated for each `input` type in the schema that is used in an argument for any of the operations defined in your application. Input objects are structs that are backed by a `InputDict` struct that stores the values for the fields on the input object in a dictionary. This allows for `InputObject`s to be treated as values types but use copy-on-write semantics under the hood.

Nullable fields on input objects are represented using `GraphQLNullable` to allow for both `null` and `nil` values. 

Following the [Input Coercion rules](https://spec.graphql.org/draft/#sec-Input-Objects.Input-Coercion) from the GraphQL spec, the server defined default value for a field will be used when passing `nil`.  Nullable fields on input objects are represented using `GraphQLNullable` to allow for both `null` and `nil` values.  For non-nullable fields, if the schema provides a default value, the field will be represented as an optional to allow for `nil` to be passed. 

**Examples:**

Nullable field with no default value:
```graphql
input MyInput {
  size: RelativeSize
}
```
```swift
struct MyInput: InputObject {
  public private(set) var dict: InputDict

  init(size: GraphQLNullable<RelativeSize> = nil) {
    dict = InputDict(["size": size])
  }

  var size: GraphQLNullable<RelativeSize> {
    get { dict["size"] }
    set { dict["size"] = newValue }
  }
}
```
Nullable field with a default value:
```graphql
input MyInput {
  size: RelativeSize = SMALL
}
```
```swift
struct MyInput: InputObject {
  public private(set) var dict: InputDict

  init(size: GraphQLNullable<RelativeSize>) { ... }

  /// If `.none`, defaults to server-provided default value (.SMALL)
  var size: GraphQLNullable<RelativeSize> { ... }
}
```
Non-nullable field with no default value:
```graphql
input MyInput {
  size: RelativeSize!
}
```
```swift
struct MyInput: InputObject {
  public private(set) var dict: InputDict

  init(size: RelativeSize) { ... }
  
  var size: RelativeSize { ... }
}
```
Non-nullable field with a default value:
```graphql
input MyInput {
  size: RelativeSize! = SMALL
}
```
```swift
struct MyInput: InputObject {
  public private(set) var dict: InputDict

  init(size: RelativeSize?) { ... }
  
  /// If `nil`, defaults to server-provided default value (.SMALL)
  var size: RelativeSize? { ... }
}
```
> Note that we are not generating these fields with the provided default values. This is to account for default values that may change on the schema in the future. See [Generate Default Parameter Values for `InputObject` Default Values](#generate-default-parameter-values-for-inputobject-default-values) for more discussion.


# `GraphQLOperation` Generation

A `GraphQLOperation` is generated for each operation defined in your application. `GraphQLOperation`s can be queries (`GraphQLQuery`), mutations (`GraphQLMutation`), or subscriptions (`GraphQLSubscription`).

Each generated operation will conform to the `GraphQLOperation` protocol defined in [GraphQLOperation.swift](Sources/ApolloAPI/GraphQLOperation.swift). 

**Simple Operation - Example:**

```swift
class AnimalQuery: GraphQLQuery {
  let operationName: String = "AnimalQuery"
  let document: DocumentType = .notPersisted(definition: .init(
    """
    query AnimalQuery {
      allAnimals {
        species
      }
    }
    """)

  init() {}

  struct Data: SelectionSet {
    // ...
  }
}
```

## Operation Arguments

For an operation that takes input arguments, the initializer will be generated with parameters for each argument. Arguments can be scalar types, `GraphQLEnum`s, or `InputObject`s. During execution, these arguments will be used as the operation's `variables`, which are then used as the values for arguments on `SelectionSet` fields matching the variables name.

**Operation With Scalar Argument - Example:**

```swift
class AnimalQuery: GraphQLQuery {
  let operationName: String = "AnimalQuery"
  let document: DocumentType = .notPersisted(definition: .init(
    """
    query AnimalQuery($count: Int!) {
      allAnimals {
        predators(first: $count) {
          species
        }
      }
    }
    """)

  var count: Int

  init(count: Int) {
    self.count = count
  }

  var variables: Variables? { ["count": count] }

  struct Data: SelectionSet {
    // ...
    struct Animal: SelectionSet {
      static var selections: [Selection] {[
        .field("predators", [Predator.self], arguments: ["first": .variable("count")])
      ]}
    }
  }
}
```
In this example, the value of the `count` property is passed into the `variables` for the variable with the key `"count"`. The `Selection` for the field `"predators"`, the argument `"first"` has a value of `.variable("count")`. During execution, the `predators` field will be evaluated with the argument from the operation's `"count"` variable.

### Nullable Operation Arguments

For nullable arguments, the code generator will wrap the argument value in a `GraphQLNullable`. The executor will evaluate the `GraphQLNullable` to format the operation variables correctly. See [GraphQLNullable](#nullable-arguments-graphqlnullable) for more information.

**Operation With Nullable Scalar Argument - Example:**

```swift
class AnimalQuery: GraphQLQuery {
  let operationName: String = "AnimalQuery"
  let document: DocumentType = .notPersisted(definition: .init(
    """
    query AnimalQuery($count: Int) {
      allAnimals {
        predators(first: $count) {
          species
        }
      }
    }
    """)

  var count: GraphQLNullable<Int>

  init(count: GraphQLNullable<Int>) {
    self.count = count
  }

  var variables: Variables? { ["count": count] }

  // ...
}
```

# `SelectionSet` Generation

## Metadata

Each `SelectionSet` has metadata properties that provide the Apollo library the ability to check for valid type conversions at runtime.

### `__typename`

`__typename` is a computed property on each concrete instance of a `SelectionSet` that defines the concrete type of the underlying entity that the `SelectionSet` represents. This is a `String` representation that is fetched from the server using the `__typename` metadata field in the query. All queried selection sets will automatically include the `__typename` field.

### `__objectType` 

`__objectType` is a computed property that provides a strongly typed wrapper for `__typename`. It converts the `__typename` string into a concrete case of the `Object` enum from the schema.

### `__parentType`

 `__parentType` is a static property on each `SelectionSet` *type* that defines the known type that the `SelectionSet` is being fetched on. The `__parentType` may be an `Object`, `Interface`, or `Union`. This property is represented by the `ParentType` enum. `__parentType` is generated for each `SelectionSet`, not computed at runtime.

### `selections`

Indicates the fields that should be “selected” during GraphQL execution. See [Selection Generation](#selection-generation) for more information.

### Example

To illustrate the difference between these properties, we will use an example. Given the query:

```graphql
query {
  allAnimals {
    species
  }
}
```

The `allAnimals` field has a type of `Animal`, which is an interface.  Each concrete instance of the `Animal` struct could have a different concrete type (`Cat`, `Fish`, `Bird`, etc.) 

The `__typename` field, provided by the server would provide the actual concrete type for each entity as a `String`. 
The `__objectType` property would convert this into a strongly typed `Object` from the generated schema types. This property will have different values for each concrete `Animal` object.
The `__parentType` for all of these entities would still be the same — the `Animal` interface. 

# Field Accessor Generation

Each field selected in a `SelectionSet`'s `selections` can be accessed via a generated field accessor. Generated field accessors provide type-safe access to the values for fields that are selected on the `SelectionSet`. These field accessors access the data on the underlying `ResponseDict`, which holds the data for the `SelectionSet`. The data is then cast to the correct type and any transformations needed are applied under the hood. Because the GraphQL execution validates response data before mapping it onto generated `SelectionSet`s, the data is guarunteed to exist and be the correct type.

When the `species` field on an `Animal` is selected, the following field accessor is generated:
```swift
var species: String { data["species"] }
```
The `ResponseDict` accesses the field's value and force casts it to a `String`, which will always be safe.

# `Fragment` Generation

Fragments are used in GraphQL operations primarily for two reasons:

1. Sharing common `SelectionSet`s across multiple operations
2. Querying fields on a more specific type than the current parent type

## Fragment Structs

When sharing a common `SelectionSet` across multiple operations, a fragment can be used. This can reduce the size of your operation definition files. Additionally, and often more importantly, it allows you to reuse generated `SelectionSet` data objects across multiple operations. This can enable your code to consume fragments of an operation’s response data irrespective of the operation executed. Using fragments this way acts as a form of abstraction similar to protocols. It has often been proposed that fragments should be represented as generated protocols, however due to implementation details of the Swift language, this approach has serious limitations. See [Appendix A: Why Fragment Protocols Don’t Work](#appendix-a-why-fragment-protocols-dont-work) for more information.

Instead of protocols, fragments are generated as concrete `SelectionSet` structs that any `SelectionSet` that contains the fragment can then be converted to. 

**Fragment Definition:**

```graphql
fragment AnimalDetails on Animal {
  species
}
```

**Query Input:**

```graphql
query AllAnimalSpecies {
  allAnimals {
    ...AnimalDetails
  }
}
```

**Generated Output:**
`AnimalDetails.Swift`

```swift
struct AnimalDetails: SelectionSet, Fragment {
  static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
  let data: ResponseDict

  var species: String { data["species"] }
}
```

`AllAnimalSpeciesQuery.swift` (`Animal` Object)

```swift
struct Animal: SelectionSet, HasFragments {
    static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
    let data: ResponseDict
    
    var species: String { data["species"] }
      
    struct Fragments: ResponseObject {
      let data: ResponseDict

      var animalDetails: AnimalDetails { _toFragment() }
    }
}
```

The query’s `Animal` struct conforms to `HasFragments`, which is a protocol that exposes a `fragments` property that exposes the nested `Fragments` struct. The fragments a `SelectionSet` contains are exposed in this `Fragments` struct via computed properties that utilize a `_toFragment()` helper function. This allows you to access the `AnimalDetails` fragment via `myAnimal.fragments.animalDetails`.

### Merging Fragment Fields Into Parent `SelectionSet`

In the above example you may note that the `species` field is accessible directly on the `Animal` object without having to access the `AnimalDetails` fragment first. This is because fields from fragments that have the same `__parentType` as the enclosing `SelectionSet` are automatically merged into the enclosing `SelectionSet`. 

## Inline Fragments

Inline fragments are fragments that are unnamed and defined within an individual operation. These fragments cannot be shared, and as such, individual fragment `SelectionSet`s are not generated. Inline fragments are used strictly for handling “Type Cases“.

# `TypeCase` Generation

When using a fragment to fetch fields on a more specific interface or type than the `SelectionSet`’s `__parentType`, we create a new `SelectionSet` for the more specific type. We refer to these more specific `SelectionSet`s as “Type Cases”. 


> Note: A Type Case can be defined using either an inline fragment or an independent, named fragment.


For example, an inline fragment `... on Pet { humanName }` would generate an `AsPet` object nested inside of the enclosing entity’s `SelectionSet`.

A Type Case is always represented as an optional property on the enclosing entity, as the enclosing entity may or may not be of a type that matches the fragment’s type.

Let’s take a look at an example of this:

**Query Input:**

```graphql
query {
  allAnimals {
    species
    ... on Pet {
      humanName
    }
  }
}
```

**Generated Output:** (`Animal` Object)

```swift
struct Animal: RootSelectionSet {
    static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
    let data: ResponseDict
    
    var asPet: AsPet? { _asType() }
    
    var species: String { data["species"] }
      
    struct AsPet: TypeCase {
      static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Pet.self) }
      let data: ResponseDict
      
      var species: String { data["species"] }
      var humanName: String? { data["humanName"] }      
    }
}
```

The computed property for `asPet` uses an internal function `_asType()`, which is defined in an extension on `SelectionSet`. This function checks the concrete `__objectType` against the  `__parentType` of the Type Case to see if the entity can be converted to the `SelectionSet` of the TypeCase. An `AsPet` struct will only be returned if the underlying entity for the `Animal` is a type that conforms to the `Pet` `Interface`, otherwise `asPet` will return `nil`. 

## Merging `TypeCase` Fields Into Children and Siblings

Similarly to merging in fragment fields, fields from a parent and any sibling `TypeCase`s that match the `__parentType` of a `TypeCase` are merged in as well. In the above example the `species` field that is selected by the `Animal` `SelectionSet` is merged into the child `AsPet` `TypeCase`. The `AsPet` represents the same entity as the `Animal`, and because we know that the `species` field will exist for the entity, it is merged in. Since the field will already be selected and will exist in the underlying `ResponseDict`, the child `SelectionSet` does not need to duplicate the `Selection` for the field. Only a duplicated field accessor needs to be generated. For more explanation of how the `Selection`s for `TypeCase`s work, see [`TypeCase` Selections](#typecase-selections).

Additionally, since any fields from other `TypeCases` defined on the parent `SelectionSet` that match the type of a `TypeCase` are guaranteed to exist, they are also merged in. This makes it much easier to consume the data on a generated `TypeCase`.

Expanding on the above example, we can see how sibling `TypeCase` selections can be merged.

**Query Input:**

```graphql
query {
  allAnimals {
    species
    ... on Pet {
      humanName
    }
    ... on Cat {
      isJellicle
    }
  }
}
```

**Generated Output:** (`Animal` Object)

```swift
struct Animal: RootSelectionSet {
    static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
    let data: ResponseDict    
    
    var species: String { data["species"] }
    
    var asPet: AsPet? { _asType() }
    var asCat: AsCat? { _asType() }
      
    struct AsPet: TypeCase {
      static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Pet.self) }
      let data: ResponseDict
      
      var species: String { data["species"] }
      var humanName: String? { data["humanName"] }      
    }
    
    struct AsCat: TypeCase {
      static var __parentType: ParentType { .Object(AnimalKingdomAPI.Cat.self) }
      let data: ResponseDict
      
      var species: String { data["species"] }
      var humanName: String? { data["humanName"] }      
      var isJellicle: Bool { data["isJellicle"] }      
    }
}
```

The `AsCat` `TypeCase` is on the `__parentType` “`Cat`" and the "`Cat`" object type implements the “`Pet`" `Interface`. Given this information the code generation engine can deduce that, any `AsCat` will also have the `humanName` field selected by the `AsPet` `TypeCase`. This field gets merged in and the `AsCat` has a field accessor for it.

# Union Generation

Union types are generated just like any other `SelectionSet`. Because a union has no knowledge of the underlying type or the selections available, a union `SelectionSet` will not generally include any field accessors itself. Rather, a union will only provide access to its child `TypeCases`s.

**Example:**
```graphql
query {
  classroomPets {
    ... on Pet {
      humanName
    }
    ... on Bird {
      wingspan
    }
  }
}
```
```swift
struct ClassroomPet: RootSelectionSet {
  static var __parentType: ParentType { .Union(AnimalKingdomAPI.ClassroomPet.self) }
  
  var asPet: AsPet? { _asType() }
  var asBird: AsBird? { _asType() }

  struct AsPet: TypeCase {
    static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Pet.self) }

    var humanName: String? { data["humanName"] }
  }

  struct AsBird: TypeCase {
    static var __parentType: ParentType { .Object(AnimalKingdomAPI.Bird.self) }

    var humanName: String? { data["humanName"] }
    var wingspan: Int { data["wingspan"] }
  }
}
```

# `Selection` Generation

Each `SelectionSet` includes an array of `Selection`s that indicate what fields should be “selected” during execution.
A parent `SelectionSet` will conditionally include its children’s selections as nested selections. The `GraphQLExecutor` determines if child selections should be included. 

While merged fields will be generated as  field accessors on children, the `selections` array for each `SelectionSet` does not merge in selections from parents, children, or siblings. The `selections` array will closely mirror the query operation definition that the generated objects are based upon.

`Selection` is an enum with cases representing different types of selections. A simple field selection is represented as a `Field`, but nested selections that are conditionally included are represented by additional types. 

## `Field` Selections

The `Selection.field(Field)` case represents a specific field that should be selected. It contains a `Field` struct that includes the field name; the field alias if it exists; any arguments the field takes, and the field’s type.

**Example:**

```graphql
query {
  allAnimals {
    species
  }
}
```

```swift
struct Animal: RootSelectionSet {
  static var selections: [Selection] {[
    .field("species", String.self)
  ]}
}
```

### Field Arguments

If a field takes arguments, the arguments will be generated on the field’s `Selection`. Arguments are represented as a dictionary of argument names and their values. An argument’s value is represented as an `InputValue` and can be a scalar value, a list of other `InputValue`s, a generated input type, or a variable. Variable arguments have their values provided when an instance of an operation is created.

**Scalar Value Argument Example:**

```graphql
query {
  allAnimals {
    predators(first: 3)
  }
}
```

```swift
struct Animal: RootSelectionSet {
  static var selections: [Selection] {[
    .field("predators", [Predator].self, arguments: ["first": 3])
  ]}
}
```

**Variable Argument Example:**

```
query($count: Int) {
  allAnimals {
    predators(first: $count)
  }
}
```

```swift
class Query: GraphQLQuery {
  var count: Int
  init(count: Int) { ... }

  struct Animal: RootSelectionSet {
    static var selections: [Selection] {[
      .field("predators", [Predator].self, arguments: ["first": .variable("count")])
    ]}
  }
}
```

## `@skip/@include` Selections

One or more `Selection`s may be conditionally included based on a `@skip` or `@include` directive. These `Selection`s provide a variable name for a variable of type `Boolean` on the operation that will determine if the `Selection`s are included.

**Single Field Example:**

```graphql
query($skipSpecies: Boolean) {
  allAnimals {
    species @skip(if: $skipSpecies)
  }
}
```

```swift
class Query: GraphQLQuery {
  var skipSpecies: Bool
  init(skipSpecies: Bool) { ... }

  struct Animal: RootSelectionSet {
    static var selections: [Selection] {[
      .skip(if: "skipSpecies", .field("species", String.self))
    ]}
  }
}
```

**Multiple Fields Example:**

```graphql
query($includeDetails: Boolean) {
  allAnimals {
    species 
    @include(if: $includeDetails) {
      height {
        meters
      }
      skinCovering
    }
  }
}
```

```swift
class Query: GraphQLQuery {
  var includeDetails: Bool
  init(includeDetails: Bool) { ... }

  struct Animal: RootSelectionSet {
    static var selections: [Selection] {[
      .field("species", String.self)
      .include(if: "includeDetails", [
        .field("height", Height.self),
        .field("skinCovering", GraphQLEnum<SkinCovering>.self),
       ]),
    ]}
    
    struct Height: RootSelectionSet {
      static var selections: [Selection] {[
        .field("meters", Int.self)
      ]}
    }
  }
}
```

## `Fragment` Selections

Fragments included by a `SelectionSet` reference the `Fragment` `SelectionSet` and automatically include all the fragment’s `selections`.

**Example:**

```graphql
query {
  allAnimals {
    ...AnimalDetails
  }
}

fragment AnimalDetails on Animal {
  height {
    meters
  }
  skinCovering
}
```

```swift
struct AnimalDetails: RootSelectionSet, Fragment {
    static var selections: [Selection] {[
      .field("height", Height.self)
      .field("skinCovering", GraphQLEnum<SkinCovering>.self),
    ]}
    
    struct Height: RootSelectionSet {
      static var selections: [Selection] {[
        .field("meters", Int.self)
      ]}
    }
}

class Query: GraphQLQuery {
  struct Data: RootSelectionSet {
    static var selections: [Selection] {[
      .field("allAnimals", [Animal].self),
    ]}    
    
    struct Animal: RootSelectionSet {
      static var selections: [Selection] {[
        .fragment(AnimalDetails.self)
      ]}
    }
  }
}
```

## `TypeCase` Selections

When a `SelectionSet` has a nested type case, the type case’s selections are only included if the `__typename` of the object matches a type that is compatible with the `TypeCase`’s `__parentType`. This is determined at runtime by the `GraphQLExecutor` during the process of executing the `selections` on each `SelectionSet`. While the selections for each `TypeCase` are not duplicated, field accessors for fields merged from the parent and other `TypeCase`s will be generated on each `TypeCase` struct. This is described in [Merging `TypeCase` Fields Into Children and Siblings](#merging-typecase-fields-into-children-and-siblings).

The `selections` for a `TypeCase` are included if:

* If the `__parentType`  is an `Object` type:
    * If the runtime type of the data object is equal to the object type.
* If the `__parentType`  is an `Interface` type:
    * If the runtime type of the data object is a type that implements the interface.
* If the `__parentType`  is a `Union` type:
    * If the runtime type of the data object is an object type in the union’s possible types.

**Inline TypeCase Example:**

```graphql
query {
  allAnimals {
    species
    ... on Pet {
      humanName
    }
    ... on Bird {
      wingpsan
    }
  }
}
```

```swift
struct Animal: RootSelectionSet {
  static var __parentType: ParentType { .Interface(.Animal) }
  static var selections: [Selection] {[
    .field("species", String.self),
    .typeCase(AsPet.self),
    .typeCase(AsBird.self),
  ]}
  
  var species: String { data["species" ]}

  var asPet: AsPet? { _asType() }
  var asBird: AsBird? { _asType() }

  struct AsPet: TypeCase {
    static var __parentType: ParentType { .Interface(.Pet) }
    static var selections: [Selection] {[
      .field("humanName", String?.self),
    ]}

    var species: String { data["species" ]}
    var humanName: String? { data["humanName" ]}
  }

  struct AsBird: TypeCase {
    static var __parentType: ParentType { .Interface(.Pet) }
    static var selections: [Selection] {[
      .field("wingspan", Int.self),
    ]}

    var species: String { data["species" ]}
    var humanName: String? { data["humanName" ]}
    var wingspan: Int { data["wingspan" ]}
  }
}
```

**Named Fragment TypeCase Example:** *Field and type case accessors omitted for brevity.*
```graphql
query {
  allAnimals {
    species
    ...PetDetails
  }
}

fragment PetDetails on Pet {
  humanName
}
```

```swift
struct PetDetails: RootSelectionSet, Fragment {
    static var __parentType: ParentType { .Interface(.Pet) }
    static var selections: [Selection] {[
      .field("humanName", String?.self),
    ]}
}

struct Animal: RootSelectionSet {
  static var __parentType: ParentType { .Interface(.Animal) }
  static var selections: [Selection] {[
    .field("species", String.self),
    .typeCase(AsPet.self),
  ]}
  
  struct AsPet: TypeCase {
    static var __parentType: ParentType { .Interface(.Pet) }
    static var selections: [Selection] {[
      .fragment(PetDetails.self),
    ]}
  }
}
```

## `RootSelectionSet` vs `TypeCase`

A `SelectionSet` that represents the root selections on its `__parentType` is a `RootSelectionSet`. Nested selection sets for `TypeCase`s are not `RootSelectionSet`s.

While a `TypeCase` only provides the additional selections that should be selected for its specific type, a `RootSelectionSet` guarantees that all fields for itself and its nested type cases are selected. When considering a specific `TypeCase`, all fields will be selected either by the root selection set, a fragment spread, the type case itself, or another compatible `TypeCase` on the root selection set. 

For this reason, only a `RootSelectionSet` can be executed by a `GraphQLExecutor`. Executing a non-root `SelectionSet` would result in fields from its parent `RootSelectionSet` not being collected into the `ResponseDict` for the `SelectionSet`'s data.

# Handling Unknown Types

Types that are added to your schema server side after the code generation has run could be returned in a response from the server, but will not have a generated `Object` type object that recognizes them. These types are unknown to the client-side type system. Because all data about these types is not known, certain functionality will be limited on unknown types. The `RootSelectionSet` fields will be selected properly for unknown types, but any child `TypeCase` will not be present on unknown types, as we are unable to know if the unknown type matches a `TypeCase` or not.

# Cache Key Resolution

Each generated object can provide a function for computing it's cache key by conforming to the `CacheKeyProvider` protocol. Extensions can be created manually to provide conformance to this protocol on object types.

```swift
extension Cat: CacheKeyProvider {
  static func cacheKey(for data: JSONObject) -> String? {
    guard let humanName = data["humanName"] as? String,
     let species = data["species"] as? String else { 
      return nil 
    }
    return humanName + "_" + species
  }
}
```
This function will be called whenever a cache key needs to be computed for a JSON response with a `__typename` matching the typename for a `Cat` object. (This mapping uses the generated mapper function on the `SchemaConfiguration`.)

If `nil` is returned, the object will be treated as if it does not have a unique cache key and will cached without normalization.

> When reading/writing data to the cache, the `__typename` will always be prepended to the returned cache key. It does not need to be included in the value returned by your `CacheKeyProvider`. This means that cache keys only need to be guaranteed to be unique across objects of the same type.

## Composable Cache Key Providers

Multiple types that compute their cache keys in the same way can share their cache key provider function via protocol composition.

```swift
protocol PetCacheKeyProvider: CacheKeyProvider { }
extension PetCacheKeyProvider {
  static func cacheKey(for data: JSONObject) -> String? {
    guard let humanName = data["humanName"] as? String,
     let species = data["species"] as? String else { 
      return nil 
    }
    return humanName + "_" + species
  }
}

extension Cat: PetCacheKeyProvider {}
extension Dog: PetCacheKeyProvider {}
extension Fish: PetCacheKeyProvider {}
```

> In the future, we hope to provide mechanisms to have `CacheKeyProvider` implementations automatically generated based on client-side directives that can be added as extensions to your graphql schema directly.

## Unknown Type Cache Key Providers

If you would like to automatically provide cache key computation for unknown types (types that are added to your schema after code generation), you can extend your generated `SchemaConfiguration` to conform to the `SchemaUnknownTypeCacheKeyProvider` protocol.

```swift
extension AnimalKindgomAPI: SchemaUnknownTypeCacheKeyProvider {
  static func cacheKeyForUnknownType(withTypename typename: String, data: JSONObject) -> String? {    
    guard let id = data["id"] as? String else { 
      return nil 
    }

    return id
  }
}
```

# Appendices

## Appendix A: Why Fragment Protocols Don’t Work

Consider the following fragment and queries.

```graphql
fragment HeightInMeters on Animal {
  height {
     meters
  }
 }
 
query AnimalHeight {
  allAnimals {
    ...HeightInMeters
    height {
      feet
      yards
    }
  }
}

query AnimalMeters {
  allAnimals {
    ...HeightInMeters
  }
}
```

If we generated protocols for the `HeightInMeters` fragment, it would look like this:

```swift
protocol HeightInMeters {
  associatedtype Height: HeightInMeters_Height
  
  var height: Height { get }
}

protocol HeightInMeters_Height {
  var meters: Int { get }
}
```

The generated queries `ResponseData` objects would be: *(generated code simplified for example)*

```swift
// AnimalHeightQuery.Data.Animal
struct Animal: RootSelectionSet, HeightInMeters {
  struct Height: RootSelectionSet, HeightInMeters_Height {
    let meters: Int
    let feet: Int
    let yards: Int
  } 
  
  let height: Height { data["height"] }
}

// AnimalMetersQuery.Data.Animal
struct Animal: RootSelectionSet, HeightInMeters {
  final class Height: RootSelectionSet, HeightInMeters_Height {
    let meters: Int
  } 
  
  let height: Height { data["height"] }
}

```

Then you could not reference the fragment as a concrete type for re-use (such as in a UI component).

```swift
class AnimalMetersLabelView {
  let animalHeight: HeightInMeters // Compiler Error: 
                                   // "Protocol with associatedtype cannot be 
                                   // referenced as concrete property type."
}
```

This gets even more complicated (and broken) when you nest fragments inside of each other.

While [SE-309](https://github.com/apple/swift-evolution/blob/main/proposals/0309-unlock-existential-types-for-all-protocols.md) aims to make working with existential types easier, it does not solve this problem. The error will only be moved from when you reference the `HeightInMeters` protocol, to when you attempt access its `height` field.

## Appendix B: Nested Fragments for Composition of Multiple Types

Here we want to generate the `Pet` & `WarmBlooded` types, but we also want to generate an additional composed type that is both a `Pet & Warmblooded`. We do that by explicitly copying the referenced fragment into a nested field on the `Pet` `TypeCase`. The idea here is that you are able to configure your response objects to provide data in the shape you want. Even if certain selections – or entire type cases – are redundant, you can provide them to ensure that your generated models provide fields in the way you want to consume them in your application.

**Query Input:**
```graphql
query {
  allAnimals {
    species
    ... on Pet {
      ...PetDetails
      ... on WarmBlooded {
        ...WarmBloodedDetails
      }
    }
    ...WarmBloodedDetails
  }
}

fragment PetDetails on Pet {
 humanName
 favoriteToy
}

fragment WarmBloodedDetails on WarmBlooded {
  bodyTemperature
}
```

**Output:**
```swift
public struct Animal: RootSelectionSet: HasFragments {  
  var species: String { data["species"] }

  var asPet: AsPet? { _asType() }
  var asWarmBlooded: AsWarmBlooded? { _asType() }
  
  /// Animal.AsPet 
  struct AsPet: TypeCase, HasFragments {
    var species: String { data["species"] }
    var humanName: String? { data["humanName"] }
    var favoriteToy: String { data["favoriteToy"] }

    var asWarmBlooded: AsWarmBlooded? { _asType() }

    struct Fragments: ResponseObject {
        var PetDetails: PetDetails { _toFragment() }
    }

    /// Animal.AsPet.AsWarmBlooded    
    struct AsWarmBlooded: TypeCase, HasFragments {
      var species: String { data["species"] }
      var humanName: String? { data["humanName"] }
      var favoriteToy: String { data["favoriteToy"] }
      var bodyTemperature: Int { data["bodyTemperature"] }

      struct Fragments: ResponseObject {
        var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
      }
    }
  }

  /// Animal.AsWarmBlooded  
  struct AsWarmBlooded: TypeCase, HasFragments {
    var species: String { data["species"] }
    var bodyTemperature: Int { data["bodyTemperature"] }

    struct Fragments: ResponseObject {
        var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
    }    
  }
}
```

# Alternatives & Suggestions

## `Codable` Support For Generated Objects

Previous proposals for iOS code generation have implemented `Codable` on generated model object. This functionality has been discussed by the community frequently. However, this proposal does not include `Codable` conformance. While `Codable` has become a commonly used standard in iOS development, we do not believe it adds value to our generated objects.

Under the hood, all the JSON from a response must be parsed and validated through the `GraphQLExecutor` before being mapped onto the generated `SelectionSet` models. It cannot be automatically decoded onto `Codable` objects using the `JSONDecoder`. We could explore creating a custom decoder that uses the `GraphQLExecutor`, but adding this additional layer of abstraction would only add more complexity to the internal execution process and likely negatively impact performance without providing any new user-facing functionality.

We also see little value in `Codable` conformance for encoding the objects after the data has been executed and mapped onto them. The ideal way to persist GraphQL data is in the `NormalizedCache` that provided by the Apollo Client. The `NormalizedCache` relies on the `GraphQLExecutor` for reading and writing cache data, so `Codable` doesn't provide us any value internally. 

Storing GraphQL data outside of the `NormalizedCache` is generally discouraged. While we won't prevent users from doing so, it is not officially supported by the Apollo iOS Client. We are looking into features to make the `NormalizedCache` more feature rich and performant in future versions. Investing in `Codable` support provides no value to users that are using the `NormalizedCache`, and as such is outside the scope of this project at the current time.

## Generate Default Parameter Values for InputObject Default Values

For fields with default values provided by the schema, we have decided to generate the fields as optional, but not include the default values in the generated code.

```graphql
input MyInput {
  size: RelativeSize = SMALL
}
```
```swift
struct MyInput: InputObject {
  public private(set) var dict: InputDict

  init(size: GraphQLNullable<RelativeSize>) { ... }
  
  /// If `nil`, defaults to server-provided default value (.SMALL)
  var size: GraphQLNullable<RelativeSize> { ... }
}
```
An alternative approach is to provide the default value as a generated default argument.
```swift
struct MyInput: InputObject {
  public private(set) var dict: InputDict

  init(size: GraphQLNullable<RelativeSize> = .some(.SMALL)) { ... }
  
  /// If `nil`, defaults to server-provided default value (.SMALL)
  var size: GraphQLNullable<RelativeSize> { ... }
}
```
This however does not account for the fact that future changes to the default value of a field on an input type in a schema are considered to be backwards compatible. By generating the default value, we create a client that explicitly sends the value that *was* the default value when the type was generated – not necessarily the current default value of the server. In this case, the user could still explicitly pass `nil` to the initializer to indicate the intention to use the current default value as resolved by the server. However this is unclear at the call site and does not fall inline with the intentions of input coercion in the GraphQL Spec.

For this reason, we have opted to not generate default values.

## Concrete Subtypes as Enums

[@designatedNerd’s initial proposal includes enums with associated values for subtypes.](https://github.com/apollographql/StarWarsiOSMk2/blob/master/StarWarsMark2/Queries/HeroTypeDependentAliasedFieldQueryMk2.swift#L43)

These `SubType` enums work for concrete types but not interfaces (because a type could conform to multiple interfaces). We don't plan on generating all the concrete types as data structures unless they are specifically enumerated (`... on Pet`)

It is undecided if we should implement these or not. They are only valuable in the specific scenario where you have inline fragments for multiple concrete types. 

Given this query:

```graphql
query {
  allAnimals {
    ... on Bird {
      wingspan
    }
    ... on Cat {
      bodyTemperature
    }
  }
}
```

Without the `Subtypes` enum:

```swift
struct Animal: RootSelectionSet {
  var asBird: AsBird? { _asType() }
  var asCat: Cat? { _asType() }
  
  struct AsBird: TypeCase { ... }
  struct AsCat: TypeCase { ... }
}
```

With the `Subtypes` enum:

```swift
struct Animal: RootSelectionSet {
  var asBird: AsBird? { _asType() }
  var asCat: Cat? { _asType() }
  
  enum Subtype {
    case bird(AsBird)
    case cat(AsCat)
    case _other(Animal)
  }

  var subtype: Subtype {
    switch __objectType {
    case is Bird.self: return .bird(AsBird(data: data))
    case is Cat.Type: return .cat(AsCat(data: data))    
    default: return ._other(self)
    }
  }

  struct AsBird: TypeCase { ... }
  struct AsCat: TypeCase { ... }
}
```

Possible Options:

* Don't implement the subtypes enum at all
* Use a directive `@generateSubTypeEnum` (or some other name) to inform us that the subtypes enum should be generated (if the directive is not present default is option #1.)    
    ```graphql
    query {
    allAnimals @generateSubTypeEnum {
      ... on Bird {
        wingspan
      }
      ... on Cat {
        bodyTemperature
      }
    }
    }
    ```
* Implement logic so that if your query has _**one or more**_ fragments on a concrete type, then we generate the subtypes (generate the enum with only 1 case + `_other`)
* Implement logic so that if your query has _**more than one**_ fragment on a concrete type, then we generate the subtypes

# Possible Future Additions

Looking towards the future, the 1.0 implementation of the code generation engine opens the door to many possible future improvements to Apollo iOS. Here are some of the most highly considered additions that may come in future versions.

## Client-Side Directives For Automatic `CacheKeyProvider` Generation

Under this proposal, computation of cache keys must be implemented manually using the process described in [Cache Key Resolution](#cache-key-resolution). In the future, we hope to add a `keyFields` client-side directive that can be added to your project as extensions to the types on your GraphQL schema. This would allow us to generate the `CacheKeyProviders` for you.

## Better Support For Types Added To Schema After Code Generation 

In order to cast new concrete types to type conditions, we would need to know the metadata about what interfaces the types implement. We could possibly use a schema introspection query to fetch additional types added to the schema after code generation. Some information about these types may also be able to be assumed based on the response data returned from the server, indicating if a specific unknown type matches with some certain type cases. 

## Generation of Enums Providing All Known Possible Types for Unions

 Similar to the [proposal for subtype enums for Type Cases](#concrete-subtypes-as-enums), subtypes enum could be genera
