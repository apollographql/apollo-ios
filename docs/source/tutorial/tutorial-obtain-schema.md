---
title: "2. Obtain your GraphQL schema"
---

This tutorial uses a modified version of the GraphQL server you build as part of [the Apollo full-stack tutorial](https://www.apollographql.com/docs/tutorial/introduction/). You can visit [`https://apollo-fullstack-tutorial.herokuapp.com/`](https://apollo-fullstack-tutorial.herokuapp.com/) to start it up and open the GraphiQL tool to explore its schema:

<img src="images/graphiql.png" alt="The GraphiQL query explorer" class="screenshot">
</img>

The schema defines which GraphQL operations your server can execute. Click **Schema** on the right-hand side to view a list of types you can query (and the types of fields on those types) along with any possible mutations or subscriptions:

<img src="images/graphiql_show_schema.png" alt="GraphiQL showing the schema" class="screenshot">
</img>

## Download your server's schema

The Apollo iOS SDK needs a local copy of your server's schema to generate code from it. To accomplish this, the Apollo CLI includes a `schema:download` command that enables you to fetch the schema from a GraphQL server.

To use the Apollo CLI from Xcode, add a **Run Script** build phase to your app:

1. Select the `xcodeproj` file in the Project Navigator, and then select the `RocketReserver` application target: 

    <img src="images/select_target.png" alt="Selecting application target" class="screenshot"></img>

2. A list of tabs appears. Select the **Build Phases** tab: 

    <img src="images/build_phases.png" alt="Build phases menu item" class="screenshot"></img>

3. Click the `+` button above the list of existing phases and select **New Run Script Phase**:

    <img src="images/new_run_script_phase.png" alt="Creating a new run script build phase" class="screenshot" width="300"></img>

    This adds a new Run Script build phase to the bottom of your list of build phases.
    
4. Drag the newly created phase up between "Dependencies" and "Compile Sources":

    <img src="images/drag_run_script.png" alt="Where to drag the run script" class="screenshot"></img>

5. Double-click the name of the build phase to rename it to **Apollo CLI**:

    <img src="images/rename_run_script.png" alt="UI for renaming" class="screenshot"></img>

6. Expand the Apollo CLI phase. Paste the **Swift Package Manager Run Script** from [Adding a code generation build step](/installation/#adding-a-code-generation-build-step) into the text area. This script uses your schema to generate the code that the Apollo iOS SDK uses to interact with your server.

7. Before the script can generate code, it needs a local copy of your GraphQL server's schema. For now, **comment out the last line** of the script you pasted and add the following line below it:

    ```
    "${SCRIPT_PATH}"/run-bundled-codegen.sh schema:download --endpoint="https://apollo-fullstack-tutorial.herokuapp.com/"
    ```

    This line runs the Apollo CLI's `schema:download` command, which downloads the schema to a `schema.json` file at the same level of your project as the `AppDelegate.swift` file.

8. Build your project to execute the script. In Finder, navigate to the folder that contains your `AppDelegate.swift` file. The folder should now include the downloaded `schema.json` file. Drag this file from Finder into Xcode:

    <img src="images/drag_schema_into_xcode.png" alt="Where to drag the schema file" class="screenshot" width="300"></img>

    When Xcode offers to add the schema file, make sure **all targets are unchecked** to reduce the size of your application bundle: 

    <img src="images/dont_add_to_target.png" alt="All targets unchecked in dialog" class="screenshot"></img>

    You don't need to add the schema to any targets, because it is only used to generate code that _is_ added to targets.

Your server's schema is now available locally. Next, you'll [create your first operation against the schema](./tutorial-execute-query).
