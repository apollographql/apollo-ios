**CLASS**

# `ApolloCodegen`

```swift
public class ApolloCodegen
```

A class to facilitate running code generation

## Methods
### `run(from:with:options:)`

```swift
public static func run(from folder: URL,
                       with cliFolderURL: URL,
                       options: ApolloCodegenOptions) throws -> String
```

Runs code generation from the given folder with the passed-in options

- Parameters:
  - folder: The folder to run the script from. Should be the folder that at some depth, contains all `.graphql` files.
  - cliFolderURL: The folder where the Apollo CLI is/should be downloaded.
  - options: The options object to use to run the code generation.
- Returns: Output from a successful run

#### Parameters

| Name | Description |
| ---- | ----------- |
| folder | The folder to run the script from. Should be the folder that at some depth, contains all `.graphql` files. |
| cliFolderURL | The folder where the Apollo CLI is/should be downloaded. |
| options | The options object to use to run the code generation. |