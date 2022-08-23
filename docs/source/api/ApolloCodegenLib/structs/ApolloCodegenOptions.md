**STRUCT**

# `ApolloCodegenOptions`

```swift
public struct ApolloCodegenOptions
```

An object to hold all the various options for running codegen

## Methods
### `init(codegenEngine:includes:excludes:mergeInFieldsFromFragmentSpreads:modifier:namespace:omitDeprecatedEnumCases:only:operationIDsURL:outputFormat:customScalarFormat:suppressSwiftMultilineStringLiterals:urlToSchemaFile:downloadTimeout:)`

```swift
public init(codegenEngine: CodeGenerationEngine = .default,
            includes: String = "./**/*.graphql",
            excludes: String? = nil,
            mergeInFieldsFromFragmentSpreads: Bool = true,
            modifier: AccessModifier = .public,
            namespace: String? = nil,
            omitDeprecatedEnumCases: Bool = false,
            only: URL? = nil,
            operationIDsURL: URL? = nil,
            outputFormat: OutputFormat,
            customScalarFormat: CustomScalarFormat = .none,
            suppressSwiftMultilineStringLiterals: Bool = false,
            urlToSchemaFile: URL,
            downloadTimeout: Double = 30.0)
```

Designated initializer.

- Parameters:
 - codegenEngine: The code generation engine to use. Defaults to `CodeGenerationEngine.default`
 - includes: Glob of files to search for GraphQL operations. This should be used to find queries *and* any client schema extensions. Defaults to `./**/*.graphql`, which will search for `.graphql` files throughout all subfolders of the folder where the script is run.
 - excludes: Glob of files to exclude for GraphQL operations. Caveat: this doesn't currently work in watch mode
 - mergeInFieldsFromFragmentSpreads: Set true to merge fragment fields onto its enclosing type. Defaults to true.
 - modifier: [EXPERIMENTAL SWIFT CODEGEN ONLY] - The access modifier to use on everything created by this tool. Defaults to `.public`.
 - namespace: [optional] The namespace to emit generated code into. Defaults to nil.
 - omitDeprecatedEnumCases: Whether deprecated enum cases should be omitted from generated code. Defaults to false.
 - only: [optional] Parse all input files, but only output generated code for the file at this URL if non-nil. Defaults to nil.
 - operationIDsURL: [optional] Path to an operation id JSON map file. If specified, also stores the operation ids (hashes) as properties on operation types. Defaults to nil.
 - outputFormat: The `OutputFormat` enum option to use to output generated code.
 - customScalarFormat: How to handle properties using a custom scalar from the schema.
 - suppressSwiftMultilineStringLiterals: Don't use multi-line string literals when generating code. Defaults to false.
 - urlToSchemaFile: The URL to your schema file. Accepted file types are `.json` for JSON files, or either `.graphqls` or `.sdl` for Schema Definition Language files.
 - downloadTimeout: The maximum time to wait before indicating that the download timed out, in seconds. Defaults to 30 seconds.

### `init(targetRootURL:codegenEngine:downloadTimeout:)`

```swift
public init(targetRootURL folder: URL,
            codegenEngine: CodeGenerationEngine = .default,
            downloadTimeout: Double = 30.0)
```

Convenience initializer that takes the root folder of a target and generates
code with some default assumptions.
Makes the following assumptions:
  - Schema is at [folder]/schema.json
  - Output is a single file to [folder]/API.swift
  - You want operation IDs generated and output to [folder]/operationIDs.json

- Parameters:
 - folder: The root of the target.
 - codegenEngine: The code generation engine to use. Defaults to `CodeGenerationEngine.default`
 - downloadTimeout: The maximum time to wait before indicating that the download timed out, in seconds. Defaults to 30 seconds
