---
title: Working with Mutations
---

In this tutorial, you'll learn how to build authenticated mutations and handle information returned from those mutations. 

## Creating the booking mutation

Add the following in GraphiQL

```graphql
mutation BookTrip($tripID:ID!) {
  bookTrips(launchIds:[$tripID]) {
    success
    message
  }
}
```

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