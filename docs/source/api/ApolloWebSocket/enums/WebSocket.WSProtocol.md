**ENUM**

# `WebSocket.WSProtocol`

```swift
public enum WSProtocol: CustomStringConvertible
```

The GraphQL over WebSocket protocols supported by apollo-ios.

## Cases
### `graphql_ws`

```swift
case graphql_ws
```

WebSocket protocol `graphql-ws`. This is implemented by the [subscriptions-transport-ws](https://github.com/apollographql/subscriptions-transport-ws)
and AWS AppSync libraries.

### `graphql_transport_ws`

```swift
case graphql_transport_ws
```

WebSocket protocol `graphql-transport-ws`. This is implemented by the [graphql-ws](https://github.com/enisdenjo/graphql-ws)
library.

## Properties
### `description`

```swift
public var description: String
```
