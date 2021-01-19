---
title: Downloading a schema
---

Apollo iOS requires a GraphQL schema file as input to the code generation process. A schema file is a JSON file that contains the results of an introspection query. Conventionally this file is called `schema.json`, and you store it next to the `.graphql` files in your target.

> 🚧 BETA ALERT 🚧 : Instead of writing the rest of this in Bash, try using our new [Swift Scripting Library](./swift-scripting), now in Beta! It supports downloading a schema and generating code.

You can use the [Apollo CLI](https://www.apollographql.com/docs/devtools/cli/) to download a GraphQL schema by sending an introspection query to the server.

If you've installed the CLI globally, you can use the following command to download your schema: 

```sh
apollo schema:download --endpoint=http://localhost:8080/graphql schema.json
```

Note that if you're using the local version set up for codegen, you'll want to use the same method you're using in the [Adding A Code Generation Build Step](installation#adding-a-code-generation-build-step) instructions to access that specific CLI. For example, if you're using CocoaPods, you can set it up like this to download your schema: 

```sh
SCRIPT_PATH="${PODS_ROOT}/Apollo/scripts"
cd "${SRCROOT}/${TARGET_NAME}"
"${SCRIPT_PATH}"/run-bundled-codegen.sh schema:download --endpoint=http://localhost:8080/graphql schema.json
```

If needed, you can use the `header` option to add additional HTTP headers to the request. For example, to include an authentication token, use `--header "Authorization: Bearer <token>"`:

```sh
[your apollo version] schema:download --endpoint=http://localhost:8080/graphql --header="Authorization: Bearer <token>"
```
