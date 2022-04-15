**STRUCT**

# `CodegenLogger`

```swift
public struct CodegenLogger
```

Helper to get logs printing to stdout so they can be read from the command line.

## Properties
### `level`

```swift
public static var level = LogLevel.debug
```

The `LogLevel` at which to print logs. Higher raw values than this will
be ignored. Defaults to `debug`.

## Methods
### `log(_:logLevel:file:line:)`

```swift
public static func log(_ logString: @autoclosure () -> String,
                       logLevel: LogLevel = .debug,
                       file: StaticString = #file,
                       line: UInt = #line)
```

Logs the given string if its `logLevel` is at or above `CodegenLogger.level`, otherwise ignores it.

- Parameter logString: The string to log out, as an autoclosure
- Parameter logLevel: The log level at which to print this specific log. Defaults to `debug`.
- Parameter file: The file where this function was called. Defaults to the direct caller.
- Parameter line: The line where this function was called. Defaults to the direct caller.

#### Parameters

| Name | Description |
| ---- | ----------- |
| logString | The string to log out, as an autoclosure |
| logLevel | The log level at which to print this specific log. Defaults to `debug`. |
| file | The file where this function was called. Defaults to the direct caller. |
| line | The line where this function was called. Defaults to the direct caller. |