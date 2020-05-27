**EXTENSION**

# `Dictionary`
```swift
public extension Dictionary where Key: RawRepresentable, Key.RawValue == String, Value: Any
```

## Properties
### `apollo_toStringKeyedDict`

```swift
var apollo_toStringKeyedDict: [String: Any]
```

> Transforms a dictionary keyed by a String enum into a dictionary keyed by the
> string values of that enum.
