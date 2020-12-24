**TYPEALIAS**

# `URLSessionClient.Completion`

```swift
public typealias Completion = (Result<(Data, HTTPURLResponse), Error>) -> Void
```

A completion block returning a result. On `.success` it will contain a tuple with non-nil `Data` and its corresponding `HTTPURLResponse`. On `.failure` it will contain an error.