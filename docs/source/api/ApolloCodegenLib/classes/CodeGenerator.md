**CLASS**

# `CodeGenerator`

```swift
public class CodeGenerator<Decoder: FlexibleDecoder>
```

## Methods
### `jsonGenerator(with:astOutputURL:)`

```swift
public class func jsonGenerator(with decoder: JSONDecoder = JSONDecoder(),  astOutputURL url: URL) throws -> CodeGenerator<JSONDecoder>
```

### `init(flexible:astOutputURL:)`

```swift
public init(flexible: Decoder,
            astOutputURL url: URL) throws
```

### `run(with:)`

```swift
public func run(with options: ApolloCodegenOptions) throws
```
