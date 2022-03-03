**STRUCT**

# `ApolloCLI`

```swift
public struct ApolloCLI
```

Wrapper for calling the bundled node-based Apollo CLI.

## Properties
### `binaryFolderURL`

```swift
public let binaryFolderURL: URL
```

## Methods
### `createCLI(cliFolderURL:timeout:)`

```swift
public static func createCLI(cliFolderURL: URL, timeout: Double) throws -> ApolloCLI
```

Creates an instance of `ApolloCLI`, downloading and extracting if needed

- Parameters:
  - cliFolderURL: The URL to the folder which contains the zip file with the CLI.
  - timeout: The maximum time to wait before indicating that the download timed out, in seconds.

#### Parameters

| Name | Description |
| ---- | ----------- |
| cliFolderURL | The URL to the folder which contains the zip file with the CLI. |
| timeout | The maximum time to wait before indicating that the download timed out, in seconds. |

### `init(binaryFolderURL:)`

```swift
public init(binaryFolderURL: URL)
```

Designated initializer

- Parameter binaryFolderURL: The folder where the extracted binary files live.

#### Parameters

| Name | Description |
| ---- | ----------- |
| binaryFolderURL | The folder where the extracted binary files live. |

### `runApollo(with:from:)`

```swift
public func runApollo(with arguments: [String],
                      from folder: URL? = nil) throws -> String
```

Runs a command with the bundled Apollo CLI

NOTE: Will always run the `--version` command first for debugging purposes.
- Parameter arguments: The arguments to hand to the CLI
- Parameter folder: The folder to run the command from.

#### Parameters

| Name | Description |
| ---- | ----------- |
| arguments | The arguments to hand to the CLI |
| folder | The folder to run the command from. |