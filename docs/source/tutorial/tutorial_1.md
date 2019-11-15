---
title: "Step 1: Setup"
---

In this step, you'll add the Apollo iOS SDK to a new project and generate your first code.

## Create a new project

1. Open Xcode and go to **File > New > Project**. The template chooser appears.

2. Under the set of iOS templates, choose **Master-Detail App**:

    ![select single view app template](images/master_detail_app.png)

4. Click **Next**. An options dialog for your app appears.

5. Name the project **RocketReserver**. Make sure the language is **Swift** and the User Interface is **Storyboard**:

    ![options for creating a new project](images/options_for_project.png)

6. Click **Next**. Select a location to save your new project and click **Finish**.

Xcode creates and opens your new project, which has the following structure:

<img alt="Initial project structure" src="images/initial_file_setup.png" width="300">

## Add the Apollo iOS SDK to your project

1. Go to **File > Swift Packages > Add Package Dependency**. A dialog to specify a package repository appears.

2. Specify `https://github.com/apollographql/apollo-ios.git` (don't forget the `.git`!) as the package repository:

![choose a repo to add a dependency](images/choose_repo.png)

3. Click **Next**. Xcode checks out the repository and analyzes the library. A package options dialog appears.

4. Select **Up to Next Minor** from the Version dropdown (because the Apollo iOS SDK is still a `0.x` release, breaking changes _can_ occur between minor versions):

    ![select next minor in drop-down](images/next_minor.png)

5. Click **Next**. A list of packages included in the library appears. For this tutorial, select the main **Apollo** target and the **ApolloWebSocket** target:

    ![select the first and third targets](images/select_libs.png)

6. Click **Finish**. Swift Package Manager (SPM) fetches your dependencies. When it completes, you can see them in the project navigator:

    ![screenshot of installed dependencies](images/installed_dependencies.png)

> **Note:** Because Swift Package Manager has not yet implemented [Target-Based Dependency Resolution](https://github.com/apple/swift-evolution/blob/master/proposals/0226-package-manager-target-based-dep-resolution.md), you'll see the `SQLite` dependency even though you didn't select it.

Now you've got your project set up, and the Apollo dependencies added. It's time to start pulling together the things you need to build your API!

## Downloading the schema

For this tutorial, you'll be working with a server that was set up based on [the Apollo full-stack tutorial](https://www.apollographql.com/docs/tutorial/introduction/)'s final project. You can find the site at [`https://n1kqy.sse.codesandbox.io/`](https://n1kqy.sse.codesandbox.io/) - if you click that link, you'll be taken to the `GraphiQL` query explorer: 

![the GraphiQL query explorer](images/graphiql.png)

Click on the green "Schema" on the right hand side, and you'll see a list of the possible queries and mutations you can run: 

![GraphiQL showing the schema](images/graphiql_show_schema.png)

While it's nice to have this available and visible for you to see on the web (and you'll get back to doing more with GraphiQL in a bit), in order for Apollo to generate code for you, you need to have a local copy of the schema. 

Fortunately, the Apollo Command Line Interface (aka our CLI) can handle this for you. It's the same tool that you'll need to run code generation, and it also includes a way to download a schema from a GraphQL endpoint which supports schema introspection (which fortunately, Apollo does!). 

In order to use the CLI, you'll need to set up a Run Script Build Phase with your application. To do that select the `xcodeproj` file in the Project Navigator, and then select the `RocketReserver` application target: 

![selecting the target](images/select_target.png)

A list of menu items will appear - select **Build Phases**: 

![the build phases menu item](images/build_phases.png)

In the top left hand corner there will be a small **+** button - click on it and select **New Run Script Phase**:

![creating a new run script build phase](images/new_run_script_phase.png)

This will add a new Run Script Build Phase to the bottom of your list of build phases. Drag that new phase up between "Dependencies" and "Compile Sources":

![where to drag the run script](images/drag_run_script.png)

Next, double click on the name of the script to rename it - when the highlight appears, rename it **Apollo CLI**:

![UI for renaming](images/rename_run_script.png)

Next, you'll need to add the run script for the Swift Package manager. It's a little long, but fortunately you can grab it from [the installation instructions for adding a code generation build phase to Swift Package Manager](https://www.apollographql.com/docs/ios/installation/#swift-package-manager-run-script) - hit the "Copy" button on the code block and it'll copy the whole thing. 

Go back to Xcode, and open the flippy triangle on the Apollo CLI build phase you just created. In the large text area, paste in the script you just copied. This is what you'll eventually use to generate code. 

However, first you need to download a schema in order to generate that code. Comment out the last line (don't delete it - you'll come need it in a minute), and then add the following below it: 

```sh
"${SCRIPT_PATH}"/run-bundled-codegen.sh schema:download --endpoint="https://n1kqy.sse.codesandbox.io/"
```

This calls the `schema:download` function of our Apollo CLI when you build your project, and automatically downloads the schema to the same level of your project as your `AppDelegate.swift` as a file called **schema.json**.

Build the project to actually execute the script, and if you navigate to the file that contains your `AppDelegate.swift` in Finder, you should now see the file downloaded. Drag this file from Finder into Xcode:

![where to drag the schema file](images/drag_schema_into_xcode.png)

When Xcode offers to add the schema file, make sure **all targets are unchecked**: 

![all targets unchecked in dialog](images/dont_add_to_target.png)

The schema file can get pretty huge depending on how extensive your schema is, and it's only needed for generating the Swift code that will eventually be in your application. Leaving it out of the application target helps reduce bundle bloat. 

You've now got the first piece of the puzzle needed to generate code: The schema. The schema defines the world of what is possible to request from your server. Now you need to create at least one **operation**, which tries to get or update information in your graph. 

## Creating a query

The simplest kind of operation is a **query**, which requests information from your graph based on the schema. If you go back to [the GraphiQL query explorer](https://n1kqy.sse.codesandbox.io/), you'll see the Schema tab you opened earlier. 

Click on the `launches` query at the top to get more details about the query:

![detail about launches query](images/launches_detail.png)

In the right panel, you see both the query itself, and information about what the query returns. You can use this information to write a query you'll eventually move to iOS. 

In the left hand section, add the following lines to start creating a query that will get a list of all the launches: 

```graphql
query LaunchList {
}
```

It's valid GraphQL for a query not to have a name, but for iOS, in order to generate code for queries, every query has to have a name, so you might as well add one here.

>**Note**: the word `Query` (or its equivalent for other operations) is automatically added by our iOS code generation. That means you don't need to add that to the name of your query, unless you want it to be called `LaunchListQueryQuery` 😆.

Next, between the curly braces, start typing `la`. You'll see the autocomplete box pop up and show you options based on what's in the schema:

![example of autocomplete](images/grapqhiql_autocomplete.png)

This is a really helpful feature of GraphiQL to help you create queries and check them quickly so you don't have to go through a million rounds of building with Xcode. 

>**Note**: There is a way to get syntax highlighting in Xcode for GraphQL files that uses the Schema to validate things, but changes in Xcode 11 have made this considerably more difficult to use and maintain. Please see [this issue on the Xcode-GraphQL repo](https://github.com/apollographql/xcode-graphql/issues/23) for more details, but for now, GraphiQL is probably going to be a better bet in the short term.

As you can see from the schema, the `launches` endpoint returns a `LaunchConnection` object that has both pagination information and a list of launches. To get the information out of an object which is returned from a query, you must add curly braces to the query, then start requesting fields from the returned object. 

What does this look like in practice? To just ask for the `cursor` and `hasMore` properties of a `LaunchConnection` object, update your query to look like this:


```graphql
query LaunchList {
  launches {
    cursor
    hasMore
  }  
}
```

If you run this query by pressing the big play button in GraphiQL, you'll get a very simple JSON structure in return on the right hand side of the page: 

![basic query JSON in GraphiQL](images/completed_basic_query.png)

This is great, but it doesn't give you any information about the launches! That's because that data is in the `LaunchConnection`'s `launches` property, which is an array of `Launch` objects. 

Similarly to how you need to use curly braces to indicate that you want to get the result of a query, you can use curly braces to indicate you want the same information for every item in that array. Update your query to get the `id` and `site` properties for every item in the array:


```graphql
query LaunchList {
  launches {
    cursor
    hasMore
    launches {
      id
      site
    }
  }  
}
```

Run the query again, and you'll now see that in addition to the information you got back before, you're also getting a list of launches with their ID and site information: 

![updated query JSON in GraphiQL](images/completed_id_query.png)

Neato! So how do you use this in your iOS application? First, head back to Xcode. Go to **File > New > File...** and scroll down until you see the **Empty** file template:

![](images/empty_file_template.png)

Select this template and hit **Next**. Name the file **LaunchList.graphql**, and make sure it's saved at the same level as your `schema.json` file, and that it is also not added to your target. 

This is for the same reason as the schema: It's used to create the code that allows you to have type-safe Swift code, but it isn't necessary to include in the bundle since the swift code will take care of that for you. 

Finally, copy your final query from GraphiQL, and paste it into this file. Now, you have both pieces which can be handed to the Apollo CLI to generate code - it's time to actually generate it.

## Running Code Generation

Go back to your Run Script Build Phase. At the bottom, comment out the line with `apollo:schema` - since you've already got the schema downloaded and it doesn't change frequently, you don't need to frequently fetch it. 

What you will need to do frequently is regenerate code based on queries as you've written them, so that when you add, change, or remove a query, the accompanying code is automatically updated. 

To do this, uncomment the line you commented out earlier containing `codegen:generate`. Now, build your project. It'll churn for a moment, and when it's done, you'll see a nice new **API.swift** file output in your project's directory at the same level as the `schema.json`. 

Drag this file into Xcode. This time, you **do** need to check the "Add to target" box for the `RocketReserver` app - this is the puzzle piece which will actually get included in your application's bundle and which will allow you to take advantage of all the work you just did. 

>**Note**: If you've got a super-giant API file and want it split into smaller files, there's [a way to do that with advanced code generation](https://www.apollographql.com/docs/ios/installation/#generate-multiple-files-in-a-folder-instead-of-one-giant-file). For the purposes of this tutorial though, it's not going to get *that* big. 

Take a look inside the `API.swift` file. You'll see that it has a root class, `LaunchListQuery`, and it's got a bunch of nested structs below it. Compare the structs to the JSON data returned in GraphiQL: It's the same structure! And these structs are set up to only have properties for fields you've requested. 

For instance, try commenting out the `id` property in `LaunchList.graphql`, saving, then building again. You'll see when the build completes that the innermost `Launch` now only has the built in `__typename` and the requested `site` properties. 

Comment `id` back in, rebuild, and the property for `id` comes back when the build finishes. This helps prevent you from accidentally trying to access a property which isn't included in the result for your particular query. 

Now that you've generated code and had a chance to see what's in there, it's time to get everything working end to end!

## Running a test query

To use the generated operations that get put into `API.swift`, you need to use an instance of `ApolloClient`. This is the thing which will take that generated code and use it to make raw network calls. 

Note that you need something to hang on to your instance of `ApolloClient`, or calls will self-terminate before completing. The easiest way to do this is to use a singleton, or a single static instance of a class you can access from anywhere in your codebase.

Start by creating a new Swift file called **Network.swift**, and copying the code in the [basic client creation section of our guide on creating a client](https://www.apollographql.com/docs/ios/initialization/#basic-client-creation). Make sure to add `import Apollo` at the top of the file. Update the URL string to be `https://n1kqy.sse.codesandbox.io/` instead of the `localhost` url shown in the example.

To make sure the Apollo client is communicating correctly with the server, add a call using your `LaunchListQuery` to `AppDelegate.swift` in the `application:didFinishLaunchingWithOptions` method so that it runs when the application is started. 

Just above the `return true`, in that method, add the following code: 

```swift
Network.shared.apollo.fetch(query: LaunchListQuery()) { result in
  switch result {
  case .success(let graphQLResult):
    print("Success! Result: \(graphQLResult)")
  case .failure(let error):
    print("Failure! Error: \(error)")
  }
}
```

Build and run your application. CodeSandbox may need to take ~10-30 seconds to spin up the application if nobody's been using it recently, but once it's spun up you should see a response pretty quickly which looks something like this: 

![success log barf](images/success_log_barf.png)

Hooray! You're now successfully fetching data from the network using the generated code!

## Recap

In this part of the tutorial, you have: 

- Created a new Xcode project and added the `apollo-ios` SDK to it using Swift Package Manager.
- Added a run script build phase so you can call the Apollo CLI easily.
- Downloaded the schema you're going to use to validate your operations.
- Created your first query.
- Set up code generation 
- Created a singleton to access your `ApolloClient`
- Used that singleton to run your query against the live server.

Now it's time to move on to [actually displaying some of those query results in your UI with Part 2](tutorial_2)!
