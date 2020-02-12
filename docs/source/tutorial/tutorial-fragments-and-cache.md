---
title: 9. Fragments and cache manipulation
---

🚧 THIS SECTION UNDER CONSTRUCTION 🚧

## Using a Fragment

```graphql:title=LaunchDetails.graphql
fragment LaunchDetails on Launch {
  id
  site
  mission {
    name
    missionPatch(size:LARGE)
  }
  rocket {
    name
    type
  }
  isBooked
}
```

```graphql:title=LaunchDetails.graphql
query LaunchDetails($id:ID!) {
  launch(id: $id) {
    ...LaunchDetails
  }
}
```

```graphql:title=BookTrip.graphql
mutation BookTrip($id:ID!) {
  bookTrips(launchIds: [$id]) {
    success
    message
    launches {
      ... LaunchDetails
    }
  }
}
```

```graphql:title=CancelTrip.graphql
mutation CancelTrip($id:ID!) {
  cancelTrip(launchId: $id) {
    success
    message
    launches {
      ... LaunchDetails
    }
  }
}
```


## Updating the cache yourself

```swift:title=DetailViewController.swift
private func updateCachedDetailQuery(with details: LaunchDetails) {
  DispatchQueue.global(qos: .background).async {
    Network.shared.apollo.store.withinReadWriteTransaction({ transaction in
      let query = LaunchDetailsQuery(id: details.id)
      try transaction.update(query: query) { (data: inout LaunchDetailsQuery.Data) in
        data.launch?.fragments.launchDetails = details
      }
    })
  }
}
```

Now go out and go back in again.
