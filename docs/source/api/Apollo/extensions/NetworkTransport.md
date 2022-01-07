**EXTENSION**

# `NetworkTransport`
```swift
public extension NetworkTransport
```

## Properties
### `headerFieldNameApolloClientName`

```swift
static var headerFieldNameApolloClientName: String
```

The field name for the Apollo Client Name header

### `headerFieldNameApolloClientVersion`

```swift
static var headerFieldNameApolloClientVersion: String
```

The field name for the Apollo Client Version header

### `defaultClientName`

```swift
static var defaultClientName: String
```

The default client name to use when setting up the `clientName` property

### `clientName`

```swift
var clientName: String
```

### `defaultClientVersion`

```swift
static var defaultClientVersion: String
```

The default client version to use when setting up the `clientVersion` property.

### `clientVersion`

```swift
var clientVersion: String
```

## Methods
### `addApolloClientHeaders(to:)`

```swift
func addApolloClientHeaders(to request: inout URLRequest)
```

Adds the Apollo client headers for this instance of `NetworkTransport` to the given request
- Parameter request: A mutable URLRequest to add the headers to.

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | A mutable URLRequest to add the headers to. |