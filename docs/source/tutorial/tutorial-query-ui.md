---
title: Query-powered UI
---

`GraphQLResult` has both `data` property and an `errors` property. This is because GraphQL is designed to allow partial data to be returned if it's not non-null. 

In the example we're working with now, we could theoretically get a list of launches, and then an error stating that a launch with a particular ID could not be constructed. 

In the `success` case, replace the print statement with the following code: 


```swift
if let launches = graphQLResult.data?.launches {
  print("Launches: \(launches)")
}
    
if let errors = graphQLResult.errors {
  print("Errors: \(errors)")
}
```



```graphql
query LaunchList($cursor:String) {
  launches(after:$cursor) {
    hasMore
    cursor
    launches {
      id
      site
      mission {
        name
      }
    }
  }
}
```