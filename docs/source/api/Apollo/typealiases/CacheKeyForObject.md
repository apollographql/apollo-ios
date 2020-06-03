**TYPEALIAS**

# `CacheKeyForObject`

```swift
public typealias CacheKeyForObject = (_ object: JSONObject) -> JSONValue?
```

> A function that returns a cache key for a particular result object. If it returns `nil`, a default cache key based on the field path will be used.