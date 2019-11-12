---
title: Working with Mutations
---

```graphql
mutation Login($email: String) {
  login(email: $email)
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
