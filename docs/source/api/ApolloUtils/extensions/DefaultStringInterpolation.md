**EXTENSION**

# `DefaultStringInterpolation`
```swift
public extension DefaultStringInterpolation
```

## Methods
### `appendInterpolation(indented:)`

```swift
mutating func appendInterpolation(indented string: String)
```

A String interpolation function that respects nested indentation.

Example:
```swift
class Root {
let children: [Root] = []
func description: String {
  var desc = "\(type(of: self)) {"
  children.forEach { child in
    desc += "\n  \(indented: child.debugDescription),"
  }
  if !children.isEmpty { desc += "\n" }
  desc += "\(indented: "}")"
  return desc
}
// Given classes A - E as subclasses of Root

let root = Root(children: [A(children: [B(), C(children: [D()])]), E()])
print(root.description)
```
This prints:
Root {
  A {
    B {}
    C {
      D {}
    }
  }
  E {}
}
