**STRUCT**

# `ApolloCodegenOptions`

```swift
public struct ApolloCodegenOptions
```

> An object to hold all the various options for running codegen

## Methods
### `init(includes:mergeInFieldsFromFragmentSpreads:namespace:only:operationIDsURL:outputFormat:passthroughCustomScalars:suppressSwiftMultilineStringLiterals:urlToSchemaFile:downloadTimeout:)`

```swift
public init(includes: String = "./**/*.graphql",
            mergeInFieldsFromFragmentSpreads: Bool = true,
            namespace: String? = nil,
            only: URL? = nil,
            operationIDsURL: URL? = nil,
            outputFormat: OutputFormat,
            passthroughCustomScalars: Bool = false,
            suppressSwiftMultilineStringLiterals: Bool = false,
            urlToSchemaFile: URL,
            downloadTimeout: Double = 30.0)
```

> Designated initializer.
>
> - Parameters:
>  - includes: Glob of files to search for GraphQL operations. This should be used to find queries *and* any client schema extensions. Defaults to `./**/*.graphql`, which will search for `.graphql` files throughout all subfolders of the folder where the script is run.
>  - mergeInFieldsFromFragmentSpreads: Set true to merge fragment fields onto its enclosing type. Defaults to true.
>  - namespace: [optional] The namespace to emit generated code into. Defaults to nil.
>  - only: [optional] Parse all input files, but only output generated code for the file at this URL if non-nil. Defaults to nil.
>  - operationIDsURL: [optional] Path to an operation id JSON map file. If specified, also stores the operation ids (hashes) as properties on operation types. Defaults to nil.
>  - outputFormat: The `OutputFormat` enum option to use to output generated code.
>  - passthroughCustomScalars: Set true to use your own types for custom scalars. Defaults to false.
>  - suppressSwiftMultilineStringLiterals: Don't use multi-line string literals when generating code. Defaults to false.
>  - urlToSchemaFile: The URL to your schema file.
>  - downloadTimeout: The maximum time to wait before indicating that the download timed out, in seconds. Defaults to 30 seconds.

### `init(targetRootURL:downloadTimeout:)`

```swift
public init(targetRootURL folder: URL, downloadTimeout: Double = 30.0)
```

> Convenience initializer that takes the root folder of a target and generates
> code with some default assumptions.
> Makes the following assumptions:
>   - Schema is at [folder]/schema.json
>   - Output is a single file to [folder]/API.swift
>   - You want operation IDs generated and output to [folder]/operationIDs.json
>
> - Parameters:
>  - folder: The root of the target.
>  - downloadTimeout: The maximum time to wait before indicating that the download timed out, in seconds. Defaults to 30 seconds
