---
title: Swift Scripting
---

⚠️ **PLEASE NOTE: THIS FUNCTIONALITY IS IN BETA** ⚠️

Some functions you used to have to call using Bash have been adapted to allow the use of Swift scripting with Swift Package Manager executables. 

This document will guide you through setting up your executable and then using it to: 

- Download a schema
- Generate Swift code for your model object based on your schema + operations

## Setting up a Swift Package Manager executable

To begin, you need to set up a Swift Package Manager executable. 

1. Using Terminal, `cd` into your project's `SRCROOT`. This is generally the folder containing your `.xcodeproj` or `.xcworkspace` file.
2. Create a new folder for the Codegen executable, change directories into the folder, then initialize an SPM executable using the following commands:

    ```
    mkdir Codegen
    cd Codegen
    swift package init --type executable 
    ```

3. Double click on the `Package.swift` in this new folder (or run `open Package.swift` in Terminal). This will open the package you've just created in Xcode. 

4. Update the `dependencies` section to grab the Apollo iOS library:

    ```swift
    .package(url: "https://github.com/apollographql/apollo-ios.git", 
             from: "0.22.0")
    ```
  **NOTE**: The version should be identical to the version you're using in your main project. 

5. For the main executable target in the `targets` section, add `ApolloCodegenLib` as a dependency: 

    ```swift
    .target(name: "Codegen",
            dependencies: ["ApolloCodegenLib"])
    ```
    
6. In `main.swift`, import the Codegen lib at the top of the file:

    ```swift:title=main.swift
    import ApolloCodegenLib
    ```

7. Run `swift run`. This will download dependencies, then build and run your package. This should create an output of `"Hello, world!"`, confirming that the package and its dependencies are set up correctly.

Now it's time to use the executable to do some stuff for you!

## Accessing your project's file tree

Because Swift Package manager doesn't have an environment, there's no good way to access the `$SRCROOT` variable if you're running it directly from the command line or using a scheme in Xcode. 

Since almost everything the code generation can do requires access to the file tree where your code lives, there needs to be an alternate method to pass this through. 

Fortunately, there's a class for that: `FileFinder` will automatically use the calling `#file` as a way to access the swift file you're currently editing. 

For example, let's take a `main.swift` in a folder in `apollo-ios/Codegen/Sources`, assuming `apollo-ios` is the source root. Here's how you'd grab the parent folder of the script, then use that to get back to your source root: 

```swift:title=main.swift
let parentFolderOfScriptFile = FileFinder.findParentFolder()
let sourceRootURL = parentFolderOfScriptFile
  .deletingLastPathComponent() // Sources
  .deletingLastPathComponent() // Codegen
  .deletingLastPathComponent() // apollo-ios
```

Then, you can use this to get the URL of the folder you plan to download the CLI to: 

```swift:title=main.swift
let cliFolderURL = sourceRootURL
  .appendingPathComponent("Codegen")
  .appendingPathComponent("ApolloCLI")
```    

Now, with access to both the `sourceRootURL` and the `cliFolderURL`, it's time to use your script to do neat stuff for you!

## Downloading a schema

One of the convenience wrappers available to you in the target is `ApolloSchemaDownloader`. This allows you to use an `ApolloSchemaOptions` object to set up how you would like to download the schema. 

1. Set up access to the endpoint you'll be downloading this from. This may be directly from your server or from [Apollo Graph Manager](https://engine.apollographql.com), but for this example, let's download directly from the server:

    ```swift:title=main.swift
    let endpoint = URL(string: "http://localhost:8080/graphql")!
    ```

2. Set up the URL for the folder where you would like the schema to be downloaded:

    ```swift:title=main.swift
    let output = sourceRootURL
        .appendingPathComponent("Sources")
        .appendingPathComponent("MyTarget")
    ```
    
    You may want to make sure the folder exists before proceeding:
    
    ```swift:title=main.swift
    try FileManager
      .default
      .apollo_createFolderIfNeeded(at: output)
    ```

3. Set up your `ApolloSchemaOptions` object. In this case, we'll use the [default arguments for all the constructor parameters which take them](./api/ApolloCodegenLib/structs/ApolloSchemaOptions#methods), and only pass in the endpoint to download from and the folder to put the downloaded file into: 

    ```swift:title=main.swift
    let options = ApolloSchemaOptions(endpointURL: endpoint,
                                      outputFolderURL: output)
    ```
    
    With these defaults, this will download a JSON file called `schema.json`. 
    
4. Add the code that will actually download the schema: 

    ```swift:title=main.swift
    do {
      try ApolloSchemaDownloader.run(with: cliFolderURL,
                                     options: options)
    } catch {
      exit(1)
    }
    ```
    Note that `catch`'ing and manually calling `exit` with a non-zero code leaves you with a much more legible error message than simply letting the method throw. 

5. Build and run using the Xcode project. Note that if you're on Catalina you may get a warning asking if your executable can access files in a particular folder like this:

   ![permission prompt](screenshot/would_like_to_access.png)
   
   Click the "OK" button. Your CLI output will look something like this: 
   
   ![log barf for successful run](screenshot/schema_download_success.png)
   
   Those last two lines - "Saving schema started" and "Saving schema completed" indicate that the schema has successfully downloaded. 

Note the warning: This isn't relevant for schema downloading, but it *is* relevant for generating code: In order to generate code, you need both the schema and some kind of operation. Now that you've got the schema, it's time to 

## Codegen theory + creating a `.graphql` file with an operation

Code generation takes a combination of the **schema**, which defines what it's *possible* for you to request from or send to your server, and your **operations**, which define what you are *actually* requesting from the server. 

An operation can be one of three things: 

- A **query**, which is a one-time request for specific data
- A **mutation**, which changes data on the server and then receives updated data back
- A **subscription**, which allows you to listen for changes to a particular object or type of object

The code generation takes your operations and compares them to the schema to validate that what you are asking for is, in fact, possible. If it's not possible, the whole process errors out. If it is possible, it generates Swift code that gives you end-to-end type safety for each operation. 

Thus, a simple equation can be used to describe generating code: 

`schema + operations = code`

If you're missing either of the first two parts, the code can't be generated. If there's operations but no schema, the operations can't be validated, so we can't know if code should be generated. If there's a schema but no operations, then there's nothing to validate or generate code for. 

Since you've already [downloaded a schema](#downloading-a-schema), you can now proceed to creating an operation. The easiest and most common type of operation to create is a Query. 

Identify where your server's [GraphiQL](https://github.com/graphql/graphiql) instance lives. GraphiQL is a simple web interface for interacting with and testing out a GraphQL server. This can generally be accessed by going to the same URL as your GraphQL endpoint in a web browser, but you may need to talk to your backend team if they've got it in a different place.

You'll see something that looks like this: 

![GraphiQL Empty](screenshot/graphiql_empty.png)

In the "Docs" tab on the right hand side, you should be able to access a list of the various queries you can make to your server: 

![docs tab](screenshot/graphiql_docs_tab.png)

You can then type out a GraphQL query on the left hand side and have it give you auto-completion for your queries and the properties you can ask for on the returned data. Clicking the play button will execute the query, so you can validate that the query works:

![completed query](screenshot/graphiql_query.png)

You can then create a new empty file in your Xcode project, give it the same name as your query and have the file end in `.graphql`,  and paste in the query. Here, for example, is what this looks like in a file for one of the queries in our [tutorial application](./tutorial/tutorial-introduction):

![launch list file](screenshot/graphql_file_launchlist.png)

>**NOTE** It's generally a good idea to put your query file in the filesystem somewhere above your `SRCROOT`, otherwise you'll need to manually pass the URL of your GraphQL files to your code generation step. 

## Generating code for a target

>**BEFORE YOU START**: Remember, you need to have a locally downloaded copy of your schema and at least one `.graphql` file containing an operation in your file tree. If you don't have **both** of these, code generation will fail. Read the section above if you don't have an operation set up!

1. Set up the URL for the folder where the root of your target that you wish to generate code for is:

    ```swift:title=main.swift
    let targetURL = sourceRootURL
                    .appendingPathComponent("Sources")
                    .appendingPathComponent("MyTarget")
    ```

    Again, you may want to make sure the folder exists before proceeding:

    ```swift:title=main.swift 
    try FileManager
          .default
          .apollo_createFolderIfNeeded(at: targetURL)
    ```

2. Set up your `ApolloCodegenOptions` object. In this case, we'll use the constructor that [sets a bunch of defaults for you automatically](./api/ApolloCodegenLib/structs/ApolloCodegenOptions#methods): 

    ```swift:title=main.swift
    let options = ApolloCodegenOptions(targetRootURL: targetRootURL)
    ```

    This will create a single file called `API.swift` in the target's root folder. 
    
3. Add the code to run code generation: 
    
    ```swift:title=main.swift
    do {
        try ApolloCodegen.run(from: targetURL,
                              with: cliFolderURL,
                              options: options)
    } catch {
        exit(1)
    }
    ```
   
   Note that again, `catch`'ing and manually calling `exit` with a non-zero code leaves you with a much more legible error message than simply letting the method throw.  

4. Build and run using the Xcode project. Note that if you're on Catalina you may get a warning asking if your executable can access files in a particular folder like this:

   ![permission prompt](screenshot/would_like_to_access.png)
   
   Click the "OK" button. Your CLI output will look something like this: 
   
   ![log barf for successful run](screenshot/codegen_success.png)
   
   The final lines about loading the Apollo project and generating query files are what indicate your code has been generated successfully. 
   
Now, you're able to generate code from a debuggable Swift Package Manager executable. All that's left to do is set it up to run from your Xcode project!

## Running Your Executable From Your Main Project

1. Select the target in your project or workspace you want to have run the code generation, and go to the `Build Phases` tab. 

2. Create a new Run Script Build Phase by selecting the **+** button in the upper left-hand corner:

  ![New run script build phase dialog](screenshot/new_run_script_phase.png)

3. Update the build phase run script to `cd` into the folder where your executable's code lives, then run `swift run`. 

    ```
    cd "${SRCROOT}"/Codegen
    swift run
    ```
    
    >**NOTE**: If your package ever seems to have problems with caching, run `swift package clean` before `swift run` for a totally clean build. It is not recommended to do this by default since it substantially increases build time.
    
4. Build your target. Since `swift run` is being called from within your target, all of the pieces of the environment, including `$SRCROOT`, will automatically be passed to the environment of the executable, and you don't have to worry about passing anything manually. 

Now, every time you build your project, this script will get called. Since Swift knows not to recompile everything unless something's changed, it should not have a significant impact on your build time. 

## Swift-specific troubleshooting

- If at any point you start seeing a bunch of errors around `SecTaskLoadEntitlements` resulting in an immediate exit of the script rather than showing the permission prompt, validate that all the folders you're looking for exist and are at the *exact* path you think they are. You may have a typo in one of your paths. 