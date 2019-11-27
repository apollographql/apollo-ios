---
title: Working with Mutations
---


```graphql
mutation BookTrip($tripID:ID!) {
  bookTrips(launchIds:[$tripID]) {
    success
    message
    launches {
      id
      isBooked
    }
  }
}
```

```swift
{ "Authorization" :"[your token]"}
```


```swift
private func bookTrip(with id: GraphQLID) {

}
```

```swift
private func cancelTrip(with id: GraphQLID) {

}
```

```swift
if launch.isBooked == true {
  self.cancelTrip()
} else {
  self.bookTrip()
}
```