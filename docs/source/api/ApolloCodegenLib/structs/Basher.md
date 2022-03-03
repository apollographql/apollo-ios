**STRUCT**

# `Basher`

```swift
public struct Basher
```

Bash command runner

## Methods
### `run(command:from:)`

```swift
public static func run(command: String, from url: URL?) throws -> String
```

Runs the given bash command as a string

- Parameters:
  - command: The bash command to run
  - url: [optional] The URL to set as the `currentDirectoryURL`.
- Returns: The result of the command.

#### Parameters

| Name | Description |
| ---- | ----------- |
| command | The bash command to run |
| url | [optional] The URL to set as the `currentDirectoryURL`. |