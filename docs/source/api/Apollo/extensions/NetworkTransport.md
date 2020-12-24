**EXTENSION**

# `NetworkTransport`
```swift
public extension NetworkTransport
```

## Properties
### `clientName`

```swift
var clientName: String
```

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