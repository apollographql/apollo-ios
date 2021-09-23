# iOS Codegen Proposal

# Overview

This document provides explanation, context, and examples for a proposal for the new code generation for iOS.


> **Example code in this document is used only to illustrate the concepts being discussed, as is not comprehensive. Actual generated objects may have additional properties, functions, or nested types to support all functionality. For complete examples of generated code, see the code repository for this proposal..**

# Objectives

There are a number of reasons to build a new Codegen tool. There are limitations of the current Codegen, as well as improvements and features that can be added with a new Codegen tool that are difficult to address with the current tooling.

### Dependency on Typescript

The current Codegen tooling is written in Typescript, and supports multiple languages. This code base is not maintained and is in a messy state currently. Making changes to this tooling is difficult because of the state of the code and because it must maintain compatibility with generating code for other languages. Additionally, we believe that a Codegen tool written primarily in Swift opens up more opportunity for the community to make contributions in the future. 

### Dependency on NPM

The current Codegen tooling CLI runs as a node package. This requires iOS developers to include an NPM project. This is not ideal, as it adds a lot of cruft to our user’s projects. Since many iOS engineers are not familiar with NPM, the installation and usage of it creates additional hurdles to getting a project started and maintaining projects that iOS engineers struggle with. We have pulled out the GraphQL compiler to work without NPM, and by wrapping it in a Swift library, we can remove the NPM dependency.

### Runtime Performance

This Codegen proposal uses a dictionary of values that are passed around and accessed each time a property is accessed, this has some run time implications as they must be computed and transformed each time they are accessed. This is similar to the way the current Codegen works.

An alternative approach may improve runtime performance by computing field data once and only once during parsing, which is typically done on a background thread. However, this approach has trade-offs that cause for us to sacrifice on some of our other objectives — complexity, memory allocation, and generated code size. This approach also is slower at runtime when accessing subtypes (fragments or type cases), while using a single data dictionary per object allows for transformations between types to be nearly free.

### Generated Code Size

The size of the generated code for large or complex queries can rapidly become very large under the current CodeGen. This is something we would like to improve upon. Though we understand that there is only so much we can do to reduce code size while accurately reflecting all the data and handling edge cases.

### Generated Code Complexity

The current Codegen generates objects that are often difficult to parse and understand for developers looking at the generated code. While we recognize that the functionality required and edge cases that must be accounted for cause complexity to be inevitable, we hope that the new Codegen can reduce the complexity. This may or may not be possible, and complexity will likely have trade-offs with functionality, generated code size, and other goals.

### Compiled Binary Size

The size of the compiled binary when using our generated data objects must also be considered. AirBnB has used classes for their fields rather than structs to reduce the size of the compiled binary. While classes can reduce binary size, it incurs an additional runtime cost when consumed.

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

# Example Schema

For all examples in this document, we will use the following schema:

```
type Query {
  allAnimals: [Animal!]!
  allPets: [Pet!]!
  classroomPets: [ClassroomPet!]!
}

interface Animal {
  species: String!
  height: Height!
  predators(first: Int = 5): [Animal!]!
  skinCovering: SkinCovering
}

interface Pet {
  humanName: String
  favoriteToy: String!
  owner: Human
}

interface WarmBlooded implements Animal {
  species: String!
  height: Height!
  predators(first: Int = 5): [Animal!]!
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
  predators(first: Int = 5): [Animal!]!
  skinCovering: SkinCovering
  bodyTemperature: Int!
  laysEggs: Boolean!
}

type Cat implements Animal & Pet & WarmBlooded {
  species: String!
  height: Height!
  predators(first: Int = 5): [Animal!]!
  skinCovering: SkinCovering
  humanName: String
  favoriteToy: String!
  owner: Human
  bodyTemperature: Int!
  laysEggs: Boolean!
  isJellicle: Boolean!
}

type Bird implements Animal & Pet & WarmBlooded {
  species: String!
  height: Height!
  predators(first: Int = 5): [Animal!]!
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
  predators(first: Int = 5): [Animal!]!
  skinCovering: SkinCovering
  humanName: String
  favoriteToy: String!
  owner: Human
}

type Rat implements Animal & Pet {
  species: String!
  height: Height!
  predators(first: Int = 5): [Animal!]!
  skinCovering: SkinCovering
  humanName: String
  favoriteToy: String!
  owner: Human
}

type Crocodile implements Animal {
  species: String!
  height: Height!
  predators(first: Int = 5): [Animal!]!
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
---

We will refer to each individual object fetched in a GraphQL response as an “entity”. An entity defines a single type (object, interface, or union) that has fields on it that can be fetched. 

A `SelectionSet` defines a set of fields that have been selected to be visible for access on a given entity. The `SelectionSet` determines the shape of the generated response data objects for a given operation.

Given the query:

```
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

```
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
---

GraphQL execution is the process in which the Apollo iOS client converts raw data — either from a network response or the local cache — into a `SelectionSet`. The execution process determines which fields should be “selected”; maps the data for those fields; decodes raw data to the correct types for the fields; validates that all fields have valid data; and returns `SelectionSet` objects that are guaranteed to be valid. 

A field that is “selected” is mapped from the raw data onto the `SelectionSet` to be accessed using a generated field accessor. If data exists in the cache or on a raw network response for a field, but the field is not “selected” the resulting `SelectionSet` will not include that data after execution.

Because `SelectionSet` field access uses unsafe force casting under the hood, it is necessary that a `SelectionSet` is only ever created via the execution process. A `SelectionSet` that is initialized manually cannot be guaranteed to contain all the expected data for its field accessors, and as such, could cause crashes at run time. `SelectionSet`s returned from GraphQL execution are guaranteed to be safe.

## Nullable Arguments - `GraphQLNullable`
---

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

For each concrete type declared in your schema and referenced by any generated operation, an `Object` subclass is generated.

## `Interface` Types

For each interface type declared in your schema and referenced by any generated operation, an `Interface` subclass is generated. Interfaces wrap an underlying `Object` type and ensure that only objects of types that they are only initialized with a wrapped object of a type that implements the interface.

## `Union` Types

For each union type declared in your schema and referenced by any generated operation, a `UnionType` enum is generated. `UnionType` enums have cases representing each possible type in the union. Each case has an associated value of the `Object` type represented by that case. `UnionType` enums are referenced as fields by being wrapped in a `Union<UnionType>` enum that provides access to the underlying `UnionType` and unknown cases. See [Handling Unknown Types](#handling-unknown-types) for more information.

## `Schema` Metadata

A `SchemaConfiguration` object will also be generated for your schema. This object will have a function that maps the `Object` types in your schema to their `__typename` string. This allows the execution to convert data (from a network response from the cache) to the correct `Object` type at runtime.

For an example of generated schema metadata see [AnimalSchema.swift](Sources/ApolloAPI/AnimalSchema.swift).

# `InputObject` Generation

TODO

# `EnumType` Generation

TODO

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

```
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

# `Fragment` Generation

Fragments are used in GraphQL operations primarily for two reasons:

1. Sharing common `SelectionSet`s across multiple operations
2. Querying fields on a more specific type than the current parent type

## Fragment Structs

When sharing a common `SelectionSet` across multiple operations, a fragment can be used. This can reduce the size of your operation definition files. Additionally, and often more importantly, it allows you to reuse generated `SelectionSet` data objects across multiple operations. This can enable your code to consume fragments of an operation’s response data irrespective of the operation executed. Using fragments this way acts as a form of abstraction similar to protocols. It has often been proposed that fragments should be represented as generated protocols, however due to implementation details of the Swift language, this approach has serious limitations. See [Appendix A: Why Fragment Protocols Don’t Work](#appendix-a-why-fragment-protocols-dont-work) for more information.

Instead of protocols, fragments are generated as concrete `SelectionSet` structs that any `SelectionSet` that contains the fragment can then be converted to. 

**Fragment Definition:**

```
fragment AnimalDetails on Animal {
  species
}
```

**Query Input:**

```
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
  static var __parentType: ParentType { .Interface(.Animal) }
  let data: ResponseDict

  var species: String? { data["species"] }
}
```

`AllAnimalSpeciesQuery.swift` (`Animal` Object)

```swift
struct Animal: SelectionSet, HasFragments {
    static var __parentType: ParentType { .Interface(.Animal) }
    let data: ResponseDict
    
    var species: String? { data["species"] }
      
    struct Fragments: ResponseObject {
      let data: ResponseDict

      var animalDetails: AnimalDetails { _toFragment() }
    }
}
```

The query’s `Animal` struct conforms to `HasFragments`, which is a protocol that exposes a `fragments` property that exposes the nested `Fragments` struct. The fragments a `SelectionSet` contains are exposed in this `Fragments` struct via computed properties that utilize a `_toFragment()` helper function. This allows you to access the `AnimalDetails` fragment via `myAnimal.fragments.animalDetails`.

### Merging Fragment Fields Into Parent `SelectionSet`

In the above example you may note that the `species` field is accessible directly on the `Animal` object without having to access the `AnimalDetails` fragment first. This is because fields from fragments that have the same `__parentType` as the enclosing `SelectionSet` are automatically merged into the enclosing `SelectionSet`. 

In previous versions of the Code Generation tool, this functionality was exposed via the mergeInFieldsFromFragmentSpreads option, which defaulted to `false`. Merging in fragment fields provides for easier consumption of generated models, but it also increases the size of the generated code. Because the size of the generated code is being dramatically reduced with the new Code Generation tooling, we have opted to always merge in fragment fields. If generated code size becomes a concern with the new Code Generation, adding an option to disable fragment merging may be considered in the future.

## Inline Fragments

Inline fragments are fragments that are unnamed and defined within an individual operation. These fragments cannot be shared, and as such, individual fragment `SelectionSet`s are not generated. Inline fragments are used strictly for handling “Type Cases“.

# `TypeCase` Generation

When using a fragment to fetch fields on a more specific interface or type than the `SelectionSet`’s `__parentType`, we create a new `SelectionSet` for the more specific type. We refer to these more specific `SelectionSet`s as “Type Cases”. 


> Note: A Type Case can be defined using either an inline fragment or an independent, named fragment.


For example, an inline fragment `... on Pet { humanName }` would generate an `AsPet` object nested inside of the enclosing entity’s `SelectionSet`.

A Type Case is always represented as an optional property on the enclosing entity, as the enclosing entity may or may not be of a type that matches the fragment’s type.

Let’s take a look at an example of this:

**Query Input:**

```
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
    static var __parentType: ParentType { .Interface(.Animal) }
    let data: ResponseDict
    
    var asPet: AsPet? { _asType() }
    
    var species: String { data["species"] }
      
    struct AsPet: TypeCase {
      static var __parentType: ParentType { .Interface(.Pet) }
      let data: ResponseDict
      
      var species: String { data["species"] }
      var humanName: String{ data["humanName"] }      
    }
}
```

The computed property for `asPet` uses an internal function `_asType()`, which is defined in an extension on `SelectionSet`. This function checks the concrete `__objectType` against the  `__parentType` of the Type Case to see if the entity can be converted to the `SelectionSet` of the TypeCase. An `AsPet` struct will only be returned if the underlying entity for the `Animal` is a type that conforms to the `Pet` `Interface`, otherwise `asPet` will return `nil`. 

## Merging `TypeCase` Fields Into Children and Siblings

Similarly to merging in fragment fields, fields from a parent and any sibling `TypeCase`s that match the `__parentType` of a `TypeCase` are merged in as well. In the above example the `species` field that is selected by the `Animal` `SelectionSet` is merged into the child `AsPet` `TypeCase`. The `AsPet` represents the same entity as the `Animal`, and because we know that the `species` field will exist for the entity, it is merged in. 

Additionally, since any fields from other `TypeCases` defined on the parent `SelectionSet` that match the type of a `TypeCase` are guaranteed to exist, they are also merged in. This makes it much easier to consume the data on a generated `TypeCase`.

Expanding on the above example, we can see how sibling `TypeCase` selections can be merged.

**Query Input:**

```
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
    static var __parentType: ParentType { .Interface(.Animal) }
    let data: ResponseDict    
    
    var species: String { data["species"] }
    
    var asPet: AsPet? { _asType() }
    var asCat: AsCat? { _asType() }
      
    struct AsPet: TypeCase {
      static var __parentType: ParentType { .Interface(.Pet) }
      let data: ResponseDict
      
      var species: String { data["species"] }
      var humanName: String { data["humanName"] }      
    }
    
    struct AsCat: TypeCase {
      static var __parentType: ParentType { .Object(.Cat) }
      let data: ResponseDict
      
      var species: String { data["species"] }
      var humanName: String { data["humanName"] }      
      var isJellicle: Bool { data["isJellicle"] }      
    }
}
```

The `AsCat` `TypeCase` is on the `__parentType` “`Cat`" and the "`Cat`" object type implements the “`Pet`" `Interface`. Given this information the code generation engine can deduce that, any `AsCat` will also have the `humanName` field selected by the `AsPet` `TypeCase`. This field gets merged in and the `AsCat` has a field accessor for it.

# `Selection` Generation

Each `SelectionSet` includes an array of `Selection`s that indicate what fields should be “selected” during execution.
A parent `SelectionSet` will conditionally include its children’s selections as nested selections. The `GraphQLExecutor` determines if child selections should be included. 

While merged fields will be generated as  field accessors on children, the `selections` array for each `SelectionSet` does not merge in selections from parents, children, or siblings. The `selections` array will closely mirror the query operation definition that the generated objects are based upon.

`Selection` is an enum with cases representing different types of selections. A simple field selection is represented as a `Field`, but nested selections that are conditionally included are represented by additional types. 

## `Field` Selections

The `Selection.field(Field)` case represents a specific field that should be selected. It contains a `Field` struct that includes the field name; the field alias if it exists; any arguments the field takes, and the field’s type.

**Example:**

```
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

```
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

```
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

```
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

```
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
fragment AnimalDetails: RootSelectionSet, Fragment {
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

When a `SelectionSet` has a nested type case, the type case’s selections are only included if the `__typename` of the object matches a type that is compatible with the `TypeCase`’s `__parentType`. This is determined at runtime by the `GraphQLExecutor` during the process of executing the `selections` on each `SelectionSet`.

The `selections` for a `TypeCase` are included if:

* If the `__parentType`  is an `Object` type:
    * If the runtime type of the data object is equal to the object type.
* If the `__parentType`  is an `Interface` type:
    * If the runtime type of the data object is a type that implements the interface.
* If the `__parentType`  is a `Union` type:
    * If the runtime type of the data object is an object type in the union’s possible types.

**Inline TypeCase Example:**

```
query {
  allAnimals {
    species
    ... on Pet {
      humanName
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
  ]}
  
  struct AsPet: TypeCase {
    static var __parentType: ParentType { .Interface(.Pet) }
    static var selections: [Selection] {[
      .field("humanName", String.self),
    ]}
  }
}
```

**Named Fragment TypeCase Example:**

```
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
      .field("humanName", String.self),
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

# Field Accessor Generation

TODO

# Cache Key Resolution

TODO

# Handling Unknown Types

TODO: - Union<UnionType>

# Appendices

## Appendix A: Why Fragment Protocols Don’t Work

Consider the following fragment and queries.

```
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

## Appendix B: Nested Fragments for Composition of Multiple Types

Here we want to generate the `Pet` & `WarmBlooded` types, but we also want to generate an additional composed type that is both a `Pet & Warmblooded`. We do that by explicitly copying the referenced fragment into a nested field on the `Pet` `TypeCase`. 

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
public struct AllAnimals: RootSelectionSet: HasFragments {  
  var species: String { data["species"] }

  var asPet: AsPet? { _asType() }
  var asWarmBlooded: AsWarmBlooded? { _asType() }
  
  /// AllAnimals.AsPet 
  struct AsPet: TypeCase, HasFragments {
    var species: String { data["species"] }
    var humanName: String { data["humanName"] }
    var favoriteToy: String { data["favoriteToy"] }

    var asWarmBlooded: AsWarmBlooded? { _asType() }

    struct Fragments: ResponseObject {
        var PetDetails: PetDetails { _toFragment() }
    }
    /// AllAnimals.AsPet.AsWarmBlooded    
    struct AsWarmBlooded: TypeCase, HasFragments {
      var species: String { data["species"] }
      var humanName: String { data["humanName"] }
      var favoriteToy: String { data["favoriteToy"] }
      var bodyTemperature: Int { data["bodyTemperature"] }

      struct Fragments: ResponseObject {
        var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
      }
    }
  }

  /// AllAnimals.AsWarmBlooded  
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

## Concrete Subtypes as Enums

[@designatedNerd’s initial proposal includes enums with associated values for subtypes.](https://github.com/apollographql/StarWarsiOSMk2/blob/master/StarWarsMark2/Queries/HeroTypeDependentAliasedFieldQueryMk2.swift#L43)

These `SubType` enums thing works for concrete types, not interfaces (because a type could conform to multiple interfaces). We don't plan on generating all the Concrete types as data structures unless they are specifically enumerated (`... on Droid`)

It is undecided if we should implement these or not. They are only valuable in the specific scenario where you have inline fragments for multiple concrete types. 

We could easily generate the `asDroid: Droid?` and `asHuman: Human?`  properties on the object.

Given this query:

```graphql
query {
    hero {
         ... on Human {
            name
        }
        ... on Droid {
            primaryFunction
        }
    }
}
```

Without the `Subtypes` enum:

```swift
struct Hero: RootSelectionSet {
  var asHuman: AsHuman? { asType() }
  var asDroid: AsDroid? { asType() }
  
  struct AsHuman { ... }
  struct AsDroid { ... }
}
```

With the `Subtypes` enum:

```swift
struct Hero: RootSelectionSet {
  var asHuman: AsHuman? { asType() }
  var asDroid: AsDroid? { asType() }
  
  enum Subtype {
    case human(AsHuman)
    case droid(AsDroid)
    case _other(Hero)
  }

  var subtype: Subtype {
    switch __objectType {
    case is Human.Type: return .human(AsHuman(data: data))
    case is Droid.Type: return .droid(AsDroid(data: data))    
    default: return ._other(self)
    }
  }

  struct Human { ... }
  struct Droid { ... }
}
```

Possible Options:

* Don't implement the subtypes enum at all
* Use a directive `@generateSubTypeEnum` (or some other name) to inform us that the subtypes enum should be generated (if the directive is not present default is option #1.)    
    ```graphql
    query {
      hero @generateSubTypeEnum {
        ... on Human {
          name
        }
        ... on Droid {
          primaryFunction
        }
      }
    }
    ```
* Implement logic so that if your query has _**one or more**_ fragments on a concrete type, then we generate the subtypes (generate the enum with only 1 case + `_other`)
* Implement logic so that if your query has _**more than one**_ fragment on a concrete type, then we generate the subtypes



# Possible Future Additions

## Custom Field Validation

## Better Support For Types Added To Schema After Code Generation 

In order to cast new concrete types to type conditions, we would need to know the metadata about what interfaces the types implement. We could possibly use a schema introspection query to fetch additional types added to the schema after code generation.


