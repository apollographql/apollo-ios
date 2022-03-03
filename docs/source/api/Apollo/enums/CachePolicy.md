**ENUM**

# `CachePolicy`

```swift
public enum CachePolicy
```

A cache policy that specifies whether results should be fetched from the server or loaded from the local cache.

## Cases
### `returnCacheDataElseFetch`

```swift
case returnCacheDataElseFetch
```

Return data from the cache if available, else fetch results from the server.

### `fetchIgnoringCacheData`

```swift
case fetchIgnoringCacheData
```

Always fetch results from the server.

### `fetchIgnoringCacheCompletely`

```swift
case fetchIgnoringCacheCompletely
```

Always fetch results from the server, and don't store these in the cache.

### `returnCacheDataDontFetch`

```swift
case returnCacheDataDontFetch
```

Return data from the cache if available, else return nil.

### `returnCacheDataAndFetch`

```swift
case returnCacheDataAndFetch
```

Return data from the cache if available, and always fetch results from the server.

## Properties
### `default`

```swift
public static var `default`: CachePolicy = .returnCacheDataElseFetch
```

The current default cache policy.
