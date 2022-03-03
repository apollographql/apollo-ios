**ENUM**

# `GraphQLEnum`

```swift
public enum GraphQLEnum<T>: CaseIterable, Equatable, RawRepresentable
where T: RawRepresentable & CaseIterable, T.RawValue == String
```

A generic enum that wraps a generated enum from a GraphQL Schema.

`GraphQLEnum` provides an `__unknown` case that is used when the response returns a value that
is not recognized as a valid enum case. This is usually caused by future cases added to the enum
on the schema after code generation.

## Cases
### `case(_:)`

```swift
case `case`(T)
```

A recognized case of the wrapped enum.

### `__unknown(_:)`

```swift
case __unknown(String)
```

An unrecognized value for the enum.
The associated value exposes the raw `String` data from the response.

## Properties
### `value`

```swift
public var value: T?
```

The underlying enum case. If the value is `__unknown`, this will be `nil`.

### `rawValue`

```swift
public var rawValue: String
```

### `allCases`

```swift
public static var allCases: [GraphQLEnum<T>]
```

A collection of all known values of the wrapped enum.
This collection does not include the `__unknown` case.

## Methods
### `init(_:)`

```swift
public init(_ caseValue: T)
```

### `init(rawValue:)`

```swift
public init(rawValue: String)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| rawValue | The raw value to use for the new instance. |